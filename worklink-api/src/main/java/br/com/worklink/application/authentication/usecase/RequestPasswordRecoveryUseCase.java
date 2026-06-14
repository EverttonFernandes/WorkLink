package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.DeliverPasswordRecoveryTokenPort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.LocalAuthenticationAccountRepositoryPort;
import br.com.worklink.application.authentication.port.PasswordRecoveryChallengeRepositoryPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.authentication.LocalAuthenticationAccount;
import br.com.worklink.domain.authentication.PasswordRecoveryChallenge;

import java.time.Duration;
import java.time.Instant;

public class RequestPasswordRecoveryUseCase {

    private static final String GENERIC_MESSAGE =
            "Se o e-mail estiver cadastrado, enviaremos instrucoes para redefinir a senha.";

    private final LocalAuthenticationAccountRepositoryPort accountRepository;
    private final PasswordRecoveryChallengeRepositoryPort challengeRepository;
    private final GenerateSecureTokenPort generateSecureTokenPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;
    private final DeliverPasswordRecoveryTokenPort deliveryPort;
    private final CurrentTimePort currentTimePort;
    private final Duration tokenDuration;

    public RequestPasswordRecoveryUseCase(
            LocalAuthenticationAccountRepositoryPort accountRepository,
            PasswordRecoveryChallengeRepositoryPort challengeRepository,
            GenerateSecureTokenPort generateSecureTokenPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            DeliverPasswordRecoveryTokenPort deliveryPort,
            CurrentTimePort currentTimePort,
            Duration tokenDuration
    ) {
        this.accountRepository = accountRepository;
        this.challengeRepository = challengeRepository;
        this.generateSecureTokenPort = generateSecureTokenPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
        this.deliveryPort = deliveryPort;
        this.currentTimePort = currentTimePort;
        this.tokenDuration = tokenDuration;
    }

    public PasswordRecoveryRequestResponse requestRecovery(RequestPasswordRecoveryRequest request) {
        String normalizedEmailAddress;
        try {
            normalizedEmailAddress = LocalAuthenticationAccount.normalizeEmailAddress(request.emailAddress());
        } catch (RuntimeException exception) {
            return new PasswordRecoveryRequestResponse(GENERIC_MESSAGE);
        }
        if (!deliveryPort.isDeliveryAvailable()) {
            throw new ApplicationRuleViolationException("A recuperacao de senha esta indisponivel.");
        }
        Instant currentInstant = currentTimePort.currentInstant();
        challengeRepository.deleteExpiredOrUsedChallenges(currentInstant);
        String rawToken = generateSecureTokenPort.generateSecureToken();
        String tokenHash = protectSensitiveValuePort.protectSensitiveValue(
                rawToken, ProtectedSensitiveValuePurpose.PASSWORD_RECOVERY_TOKEN
        );
        accountRepository.loadByNormalizedEmailAddress(normalizedEmailAddress).ifPresent(account -> {
            challengeRepository.save(PasswordRecoveryChallenge.request(
                    account.customerIdentifier(), tokenHash, currentInstant.plus(tokenDuration), currentInstant
            ));
            deliveryPort.deliverPasswordRecoveryToken(normalizedEmailAddress, rawToken);
        });
        return new PasswordRecoveryRequestResponse(GENERIC_MESSAGE);
    }
}
