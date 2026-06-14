package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.ExecuteInTransactionPort;
import br.com.worklink.application.authentication.port.LocalAuthenticationAccountRepositoryPort;
import br.com.worklink.application.authentication.port.PasswordHashingPort;
import br.com.worklink.application.authentication.port.PasswordRecoveryChallengeRepositoryPort;
import br.com.worklink.application.authentication.port.RevokeAllCustomerRefreshSessionsPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.authentication.LocalAuthenticationAccount;
import br.com.worklink.domain.authentication.PasswordRecoveryChallenge;

import java.time.Instant;

public class ResetPasswordUseCase {

    private static final String GENERIC_FAILURE_MESSAGE = "Nao foi possivel redefinir a senha.";

    private final PasswordRecoveryChallengeRepositoryPort challengeRepository;
    private final LocalAuthenticationAccountRepositoryPort accountRepository;
    private final PasswordHashingPort passwordHashingPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;
    private final RevokeAllCustomerRefreshSessionsPort revokeAllSessionsPort;
    private final CurrentTimePort currentTimePort;
    private final ExecuteInTransactionPort executeInTransactionPort;

    public ResetPasswordUseCase(
            PasswordRecoveryChallengeRepositoryPort challengeRepository,
            LocalAuthenticationAccountRepositoryPort accountRepository,
            PasswordHashingPort passwordHashingPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            RevokeAllCustomerRefreshSessionsPort revokeAllSessionsPort,
            CurrentTimePort currentTimePort,
            ExecuteInTransactionPort executeInTransactionPort
    ) {
        this.challengeRepository = challengeRepository;
        this.accountRepository = accountRepository;
        this.passwordHashingPort = passwordHashingPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
        this.revokeAllSessionsPort = revokeAllSessionsPort;
        this.currentTimePort = currentTimePort;
        this.executeInTransactionPort = executeInTransactionPort;
    }

    public void resetPassword(ResetPasswordRequest request) {
        executeInTransactionPort.execute(() -> {
            String password = LocalAuthenticationPasswordPolicy.requireValidPassword(request.newPassword());
            String tokenHash = protectSensitiveValuePort.protectSensitiveValue(
                    request.recoveryToken(), ProtectedSensitiveValuePurpose.PASSWORD_RECOVERY_TOKEN
            );
            PasswordRecoveryChallenge challenge = challengeRepository.loadByTokenHash(tokenHash)
                    .orElseThrow(ResetPasswordUseCase::genericFailure);
            Instant currentInstant = currentTimePort.currentInstant();
            if (challenge.used() || challenge.isExpiredAt(currentInstant)) {
                throw genericFailure();
            }
            if (!challengeRepository.markAsUsedIfActive(challenge.challengeIdentifier())) {
                throw genericFailure();
            }
            LocalAuthenticationAccount account = accountRepository.loadByCustomerIdentifier(challenge.customerIdentifier())
                    .orElseThrow(ResetPasswordUseCase::genericFailure);
            accountRepository.update(account.changePassword(passwordHashingPort.hashPassword(password), currentInstant));
            revokeAllSessionsPort.revokeAllCustomerRefreshSessions(account.customerIdentifier());
            return null;
        });
    }

    private static ApplicationRuleViolationException genericFailure() {
        return new ApplicationRuleViolationException(GENERIC_FAILURE_MESSAGE);
    }
}
