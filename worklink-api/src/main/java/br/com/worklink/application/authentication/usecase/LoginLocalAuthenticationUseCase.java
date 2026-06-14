package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.InvalidAuthenticationCredentialsException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.LocalAuthenticationAccountRepositoryPort;
import br.com.worklink.application.authentication.port.PasswordHashingPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.domain.authentication.LocalAuthenticationAccount;

import java.time.Duration;
import java.time.Instant;

public class LoginLocalAuthenticationUseCase {

    private static final String GENERIC_FAILURE_MESSAGE = "E-mail ou senha invalidos.";
    private static final String DUMMY_PASSWORD_HASH =
            "$2a$12$0A1c3JbTsvFQ.nwzXSBk6u6W8S8hQvRazS4HOXEusGIE2jkx2VnZK";

    private final LocalAuthenticationAccountRepositoryPort accountRepository;
    private final PasswordHashingPort passwordHashingPort;
    private final CurrentTimePort currentTimePort;
    private final AuthenticationSessionTokenFactory tokenFactory;
    private final int maximumFailedAttempts;
    private final Duration blockingDuration;
    private final boolean enabled;

    public LoginLocalAuthenticationUseCase(
            LocalAuthenticationAccountRepositoryPort accountRepository,
            PasswordHashingPort passwordHashingPort,
            CurrentTimePort currentTimePort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            Duration refreshTokenDuration,
            int maximumFailedAttempts,
            Duration blockingDuration,
            boolean enabled
    ) {
        this.accountRepository = accountRepository;
        this.passwordHashingPort = passwordHashingPort;
        this.currentTimePort = currentTimePort;
        this.tokenFactory = new AuthenticationSessionTokenFactory(
                issueAccessTokenPort, generateSecureTokenPort, protectSensitiveValuePort,
                saveRefreshSessionPort, refreshTokenDuration
        );
        this.maximumFailedAttempts = maximumFailedAttempts;
        this.blockingDuration = blockingDuration;
        this.enabled = enabled;
    }

    public AuthenticationTokenResponse login(LoginLocalAuthenticationRequest request) {
        requireEnabled();
        String normalizedEmailAddress = normalizeForLookup(request.emailAddress());
        LocalAuthenticationAccount account = accountRepository.loadByNormalizedEmailAddress(normalizedEmailAddress)
                .orElse(null);
        Instant currentInstant = currentTimePort.currentInstant();
        String passwordHash = account == null ? DUMMY_PASSWORD_HASH : account.passwordHash();
        boolean passwordMatches = passwordHashingPort.matchesPassword(request.password(), passwordHash);
        if (account == null) {
            throw genericFailure();
        }
        if (account.isBlockedAt(currentInstant)) {
            throw genericFailure();
        }
        if (!passwordMatches) {
            accountRepository.update(account.recordFailedLogin(
                    maximumFailedAttempts, blockingDuration, currentInstant
            ));
            throw genericFailure();
        }
        accountRepository.update(account.clearLoginFailures(currentInstant));
        return tokenFactory.createTokenResponse(account.customerIdentifier(), currentInstant);
    }

    private static String normalizeForLookup(String emailAddress) {
        try {
            return LocalAuthenticationAccount.normalizeEmailAddress(emailAddress);
        } catch (RuntimeException exception) {
            throw genericFailure();
        }
    }

    private void requireEnabled() {
        if (!enabled) {
            throw new ApplicationRuleViolationException("A autenticacao local esta indisponivel.");
        }
    }

    private static InvalidAuthenticationCredentialsException genericFailure() {
        return new InvalidAuthenticationCredentialsException(GENERIC_FAILURE_MESSAGE);
    }
}
