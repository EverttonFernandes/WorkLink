package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.LoadActiveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.authentication.port.UpdateAuthenticationOtpChallengePort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;
import br.com.worklink.domain.authentication.CustomerAccount;

import java.security.MessageDigest;
import java.time.Duration;
import java.time.Instant;

public class VerifyAuthenticationOtpUseCase {

    private static final int MAXIMUM_FAILED_ATTEMPTS = 3;
    private static final String GENERIC_AUTHENTICATION_FAILURE = "Nao foi possivel concluir a autenticacao.";

    private final LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort;
    private final UpdateAuthenticationOtpChallengePort updateAuthenticationOtpChallengePort;
    private final LoadCustomerAccountByPhoneNumberPort loadCustomerAccountByPhoneNumberPort;
    private final SaveCustomerAccountPort saveCustomerAccountPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;
    private final CurrentTimePort currentTimePort;
    private final AuthenticationSessionTokenFactory authenticationSessionTokenFactory;
    private final boolean enabled;

    public VerifyAuthenticationOtpUseCase(
            LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort,
            UpdateAuthenticationOtpChallengePort updateAuthenticationOtpChallengePort,
            LoadCustomerAccountByPhoneNumberPort loadCustomerAccountByPhoneNumberPort,
            SaveCustomerAccountPort saveCustomerAccountPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            CurrentTimePort currentTimePort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            Duration refreshTokenDuration
    ) {
        this(
                loadActiveAuthenticationOtpChallengePort, updateAuthenticationOtpChallengePort,
                loadCustomerAccountByPhoneNumberPort, saveCustomerAccountPort, protectSensitiveValuePort,
                currentTimePort, issueAccessTokenPort, generateSecureTokenPort, saveRefreshSessionPort,
                refreshTokenDuration, true
        );
    }

    public VerifyAuthenticationOtpUseCase(
            LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort,
            UpdateAuthenticationOtpChallengePort updateAuthenticationOtpChallengePort,
            LoadCustomerAccountByPhoneNumberPort loadCustomerAccountByPhoneNumberPort,
            SaveCustomerAccountPort saveCustomerAccountPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            CurrentTimePort currentTimePort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            Duration refreshTokenDuration,
            boolean enabled
    ) {
        this.loadActiveAuthenticationOtpChallengePort = loadActiveAuthenticationOtpChallengePort;
        this.updateAuthenticationOtpChallengePort = updateAuthenticationOtpChallengePort;
        this.loadCustomerAccountByPhoneNumberPort = loadCustomerAccountByPhoneNumberPort;
        this.saveCustomerAccountPort = saveCustomerAccountPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
        this.currentTimePort = currentTimePort;
        this.authenticationSessionTokenFactory = new AuthenticationSessionTokenFactory(
                issueAccessTokenPort,
                generateSecureTokenPort,
                protectSensitiveValuePort,
                saveRefreshSessionPort,
                refreshTokenDuration
        );
        this.enabled = enabled;
    }

    public AuthenticationTokenResponse verifyAuthenticationOtp(VerifyAuthenticationOtpRequest request) {
        if (!enabled) {
            throw new ApplicationRuleViolationException("A autenticacao por codigo esta indisponivel.");
        }
        String normalizedPhoneNumber = AuthenticationPhoneNumberNormalizer.normalizePhoneNumber(request.phoneNumber());
        Instant currentInstant = currentTimePort.currentInstant();
        AuthenticationOtpChallenge authenticationOtpChallenge = loadActiveAuthenticationOtpChallengePort
                .loadActiveAuthenticationOtpChallengeByPhoneNumber(normalizedPhoneNumber)
                .orElseThrow(() -> new ApplicationRuleViolationException(GENERIC_AUTHENTICATION_FAILURE));

        if (authenticationOtpChallenge.used() || authenticationOtpChallenge.isExpiredAt(currentInstant)) {
            throw new ApplicationRuleViolationException(GENERIC_AUTHENTICATION_FAILURE);
        }

        String providedOneTimePasswordHash = protectSensitiveValuePort.protectSensitiveValue(
                request.oneTimePassword(),
                ProtectedSensitiveValuePurpose.ONE_TIME_PASSWORD
        );
        if (!constantTimeEquals(providedOneTimePasswordHash, authenticationOtpChallenge.otpHash())) {
            updateAuthenticationOtpChallengePort.updateAuthenticationOtpChallenge(
                    authenticationOtpChallenge.recordFailedAttempt(MAXIMUM_FAILED_ATTEMPTS)
            );
            throw new ApplicationRuleViolationException(GENERIC_AUTHENTICATION_FAILURE);
        }

        updateAuthenticationOtpChallengePort.updateAuthenticationOtpChallenge(authenticationOtpChallenge.markAsUsed());
        CustomerAccount customerAccount = loadCustomerAccountByPhoneNumberPort
                .loadCustomerAccountByPhoneNumber(normalizedPhoneNumber)
                .orElseGet(() -> saveCustomerAccountPort.saveCustomerAccount(
                        CustomerAccount.registerCustomerAccount(normalizedPhoneNumber, currentInstant)
                ));
        return authenticationSessionTokenFactory.createTokenResponse(customerAccount.customerIdentifier(), currentInstant);
    }

    private static boolean constantTimeEquals(String firstValue, String secondValue) {
        return MessageDigest.isEqual(firstValue.getBytes(java.nio.charset.StandardCharsets.UTF_8),
                secondValue.getBytes(java.nio.charset.StandardCharsets.UTF_8));
    }
}
