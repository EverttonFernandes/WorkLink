package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.GenerateOneTimePasswordPort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.IssuedAccessToken;
import br.com.worklink.application.authentication.port.LoadActiveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.LoadRefreshSessionByTokenHashPort;
import br.com.worklink.application.authentication.port.SaveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.authentication.port.UpdateAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.UpdateRefreshSessionPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;
import br.com.worklink.domain.authentication.AuthenticationRefreshSession;
import br.com.worklink.domain.authentication.CustomerAccount;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Queue;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class AuthenticationUseCaseTest {

    private static final Instant CURRENT_INSTANT = Instant.parse("2026-05-08T20:00:00Z");
    private static final Duration OTP_DURATION = Duration.ofMinutes(5);
    private static final Duration REFRESH_TOKEN_DURATION = Duration.ofDays(30);

    @Test
    @DisplayName("GIVEN telefone WHEN solicitar OTP THEN deve persistir apenas hash e resposta generica")
    void shouldPersistOnlyOneTimePasswordHashWhenRequestingAuthenticationOtp() {
        // GIVEN
        InMemoryAuthenticationGateway gateway = new InMemoryAuthenticationGateway(CURRENT_INSTANT);
        RequestAuthenticationOtpUseCase useCase = new RequestAuthenticationOtpUseCase(
                () -> "123456",
                gateway,
                gateway,
                gateway,
                OTP_DURATION
        );

        // WHEN
        AuthenticationOtpRequestResponse response = useCase.requestAuthenticationOtp(
                new RequestAuthenticationOtpRequest("(51) 99999-9999", "WHATSAPP", null)
        );

        // THEN
        assertThat(response.message())
                .isEqualTo("Se os dados puderem ser autenticados, um codigo sera enviado pelo canal escolhido.");
        assertThat(response.expiresAt()).isEqualTo(CURRENT_INSTANT.plus(OTP_DURATION));
        assertThat(response.deliveryChannels()).containsExactly("SMS", "WHATSAPP", "EMAIL");
        assertThat(response.simulatedDelivery()).isTrue();
        assertThat(gateway.savedAuthenticationOtpChallenge.phoneNumber()).isEqualTo("51999999999");
        assertThat(gateway.savedAuthenticationOtpChallenge.otpHash()).isEqualTo("protected-ONE_TIME_PASSWORD-123456");
        assertThat(gateway.savedAuthenticationOtpChallenge.otpHash()).isNotEqualTo("123456");
    }

    @Test
    @DisplayName("GIVEN OTP correto WHEN verificar THEN deve criar cliente e emitir tokens")
    void shouldCreateCustomerAndIssueTokensWhenOtpIsValid() {
        // GIVEN
        InMemoryAuthenticationGateway gateway = new InMemoryAuthenticationGateway(CURRENT_INSTANT);
        gateway.authenticationOtpChallenge = AuthenticationOtpChallenge.requestOtpChallenge(
                "51999999999",
                "protected-ONE_TIME_PASSWORD-123456",
                CURRENT_INSTANT.plus(OTP_DURATION),
                CURRENT_INSTANT
        );
        VerifyAuthenticationOtpUseCase useCase = verifyAuthenticationOtpUseCase(gateway);

        // WHEN
        AuthenticationTokenResponse response = useCase.verifyAuthenticationOtp(
                new VerifyAuthenticationOtpRequest("51999999999", "123456")
        );

        // THEN
        assertThat(gateway.authenticationOtpChallenge.used()).isTrue();
        assertThat(gateway.savedCustomerAccount.phoneNumber()).isEqualTo("51999999999");
        assertThat(response.customerIdentifier()).isEqualTo(gateway.savedCustomerAccount.customerIdentifier());
        assertThat(response.accessToken()).isEqualTo("access-token-CUSTOMER");
        assertThat(response.refreshToken()).isEqualTo("refresh-token-1");
        assertThat(gateway.savedRefreshSessions.getFirst().refreshTokenHash())
                .isEqualTo("protected-REFRESH_TOKEN-refresh-token-1");
    }

    @Test
    @DisplayName("GIVEN cliente existente WHEN verificar OTP correto THEN deve autenticar sem duplicar conta")
    void shouldAuthenticateExistingCustomerWithoutCreatingDuplicateAccountWhenOtpIsValid() {
        // GIVEN
        InMemoryAuthenticationGateway gateway = new InMemoryAuthenticationGateway(CURRENT_INSTANT);
        CustomerAccount existingCustomerAccount = CustomerAccount.registerCustomerAccount(
                "51999999999",
                CURRENT_INSTANT.minus(Duration.ofDays(10))
        );
        gateway.customerAccount = existingCustomerAccount;
        gateway.authenticationOtpChallenge = AuthenticationOtpChallenge.requestOtpChallenge(
                "51999999999",
                "protected-ONE_TIME_PASSWORD-123456",
                CURRENT_INSTANT.plus(OTP_DURATION),
                CURRENT_INSTANT
        );
        VerifyAuthenticationOtpUseCase useCase = verifyAuthenticationOtpUseCase(gateway);

        // WHEN
        AuthenticationTokenResponse response = useCase.verifyAuthenticationOtp(
                new VerifyAuthenticationOtpRequest("51999999999", "123456")
        );

        // THEN
        assertThat(gateway.savedCustomerAccount).isNull();
        assertThat(response.customerIdentifier()).isEqualTo(existingCustomerAccount.customerIdentifier());
        assertThat(response.accessToken()).isEqualTo("access-token-CUSTOMER");
        assertThat(response.refreshToken()).isEqualTo("refresh-token-1");
    }

    @Test
    @DisplayName("GIVEN OTP expirado WHEN verificar THEN deve falhar sem revelar existencia do telefone")
    void shouldRejectExpiredOtpWithoutRevealingPhoneNumberExistence() {
        // GIVEN
        InMemoryAuthenticationGateway gateway = new InMemoryAuthenticationGateway(CURRENT_INSTANT);
        gateway.authenticationOtpChallenge = AuthenticationOtpChallenge.requestOtpChallenge(
                "51999999999",
                "protected-ONE_TIME_PASSWORD-123456",
                CURRENT_INSTANT.minusSeconds(1),
                CURRENT_INSTANT.minus(OTP_DURATION)
        );

        // WHEN / THEN
        assertThatThrownBy(() -> verifyAuthenticationOtpUseCase(gateway).verifyAuthenticationOtp(
                new VerifyAuthenticationOtpRequest("51999999999", "123456")
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("Nao foi possivel concluir a autenticacao.");
    }

    @Test
    @DisplayName("GIVEN falhas recorrentes WHEN verificar OTP errado THEN deve bloquear desafio")
    void shouldBlockOtpChallengeAfterRecurringFailures() {
        // GIVEN
        InMemoryAuthenticationGateway gateway = new InMemoryAuthenticationGateway(CURRENT_INSTANT);
        gateway.authenticationOtpChallenge = AuthenticationOtpChallenge.requestOtpChallenge(
                "51999999999",
                "protected-ONE_TIME_PASSWORD-123456",
                CURRENT_INSTANT.plus(OTP_DURATION),
                CURRENT_INSTANT
        );
        VerifyAuthenticationOtpUseCase useCase = verifyAuthenticationOtpUseCase(gateway);

        // WHEN / THEN
        for (int attemptNumber = 1; attemptNumber <= 3; attemptNumber++) {
            assertThatThrownBy(() -> useCase.verifyAuthenticationOtp(
                    new VerifyAuthenticationOtpRequest("51999999999", "000000")
            )).isInstanceOf(ApplicationRuleViolationException.class);
        }
        assertThat(gateway.authenticationOtpChallenge.failedAttempts()).isEqualTo(3);
        assertThat(gateway.authenticationOtpChallenge.used()).isTrue();
    }

    @Test
    @DisplayName("GIVEN refresh token valido WHEN renovar sessao THEN deve rotacionar token")
    void shouldRotateRefreshTokenWhenRefreshingAuthenticationSession() {
        // GIVEN
        InMemoryAuthenticationGateway gateway = new InMemoryAuthenticationGateway(CURRENT_INSTANT);
        UUID customerIdentifier = UUID.randomUUID();
        gateway.refreshSession = AuthenticationRefreshSession.startSession(
                customerIdentifier,
                "protected-REFRESH_TOKEN-refresh-token-old",
                CURRENT_INSTANT.plus(REFRESH_TOKEN_DURATION),
                CURRENT_INSTANT
        );
        RefreshAuthenticationSessionUseCase useCase = refreshAuthenticationSessionUseCase(gateway);

        // WHEN
        AuthenticationTokenResponse response = useCase.refreshAuthenticationSession(
                new RefreshAuthenticationSessionRequest("refresh-token-old")
        );

        // THEN
        assertThat(gateway.revokedRefreshSession.revoked()).isTrue();
        assertThat(response.customerIdentifier()).isEqualTo(customerIdentifier);
        assertThat(response.refreshToken()).isEqualTo("refresh-token-1");
        assertThat(gateway.savedRefreshSessions.getFirst().refreshTokenHash())
                .isEqualTo("protected-REFRESH_TOKEN-refresh-token-1");
    }

    @Test
    @DisplayName("GIVEN refresh token valido WHEN revogar sessao THEN deve marcar sessao como revogada")
    void shouldRevokeSessionWhenRefreshTokenExists() {
        // GIVEN
        InMemoryAuthenticationGateway gateway = new InMemoryAuthenticationGateway(CURRENT_INSTANT);
        gateway.refreshSession = AuthenticationRefreshSession.startSession(
                UUID.randomUUID(),
                "protected-REFRESH_TOKEN-refresh-token-old",
                CURRENT_INSTANT.plus(REFRESH_TOKEN_DURATION),
                CURRENT_INSTANT
        );

        // WHEN
        new RevokeAuthenticationSessionUseCase(gateway, gateway, gateway).revokeAuthenticationSession(
                new RevokeAuthenticationSessionRequest("refresh-token-old")
        );

        // THEN
        assertThat(gateway.revokedRefreshSession.revoked()).isTrue();
    }

    private VerifyAuthenticationOtpUseCase verifyAuthenticationOtpUseCase(InMemoryAuthenticationGateway gateway) {
        return new VerifyAuthenticationOtpUseCase(
                gateway,
                gateway,
                gateway,
                gateway,
                gateway,
                gateway,
                gateway,
                gateway,
                gateway,
                REFRESH_TOKEN_DURATION
        );
    }

    private RefreshAuthenticationSessionUseCase refreshAuthenticationSessionUseCase(InMemoryAuthenticationGateway gateway) {
        return new RefreshAuthenticationSessionUseCase(
                gateway,
                gateway,
                gateway,
                gateway,
                gateway,
                gateway,
                gateway,
                REFRESH_TOKEN_DURATION
        );
    }

    private static class InMemoryAuthenticationGateway implements
            ProtectSensitiveValuePort,
            CurrentTimePort,
            LoadActiveAuthenticationOtpChallengePort,
            SaveAuthenticationOtpChallengePort,
            UpdateAuthenticationOtpChallengePort,
            LoadCustomerAccountByPhoneNumberPort,
            SaveCustomerAccountPort,
            IssueAccessTokenPort,
            GenerateSecureTokenPort,
            SaveRefreshSessionPort,
            LoadRefreshSessionByTokenHashPort,
            UpdateRefreshSessionPort {

        private final Instant currentInstant;
        private final Queue<String> secureTokens = new ArrayDeque<>(List.of("refresh-token-1", "refresh-token-2"));
        private final List<AuthenticationRefreshSession> savedRefreshSessions = new ArrayList<>();
        private AuthenticationOtpChallenge authenticationOtpChallenge;
        private AuthenticationOtpChallenge savedAuthenticationOtpChallenge;
        private CustomerAccount customerAccount;
        private CustomerAccount savedCustomerAccount;
        private AuthenticationRefreshSession refreshSession;
        private AuthenticationRefreshSession revokedRefreshSession;

        InMemoryAuthenticationGateway(Instant currentInstant) {
            this.currentInstant = currentInstant;
        }

        @Override
        public String protectSensitiveValue(
                String rawSensitiveValue,
                br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose purpose
        ) {
            return "protected-%s-%s".formatted(purpose.name(), rawSensitiveValue);
        }

        @Override
        public Instant currentInstant() {
            return currentInstant;
        }

        @Override
        public Optional<AuthenticationOtpChallenge> loadActiveAuthenticationOtpChallengeByPhoneNumber(String phoneNumber) {
            return Optional.ofNullable(authenticationOtpChallenge)
                    .filter(challenge -> challenge.phoneNumber().equals(phoneNumber))
                    .filter(challenge -> !challenge.used());
        }

        @Override
        public AuthenticationOtpChallenge saveAuthenticationOtpChallenge(AuthenticationOtpChallenge authenticationOtpChallenge) {
            this.authenticationOtpChallenge = authenticationOtpChallenge;
            this.savedAuthenticationOtpChallenge = authenticationOtpChallenge;
            return authenticationOtpChallenge;
        }

        @Override
        public AuthenticationOtpChallenge updateAuthenticationOtpChallenge(AuthenticationOtpChallenge authenticationOtpChallenge) {
            this.authenticationOtpChallenge = authenticationOtpChallenge;
            return authenticationOtpChallenge;
        }

        @Override
        public Optional<CustomerAccount> loadCustomerAccountByPhoneNumber(String phoneNumber) {
            return Optional.ofNullable(customerAccount)
                    .filter(account -> account.phoneNumber().equals(phoneNumber));
        }

        @Override
        public CustomerAccount saveCustomerAccount(CustomerAccount customerAccount) {
            this.customerAccount = customerAccount;
            this.savedCustomerAccount = customerAccount;
            return customerAccount;
        }

        @Override
        public IssuedAccessToken issueAccessToken(UUID customerIdentifier, String profile, Instant issuedAt) {
            return new IssuedAccessToken("access-token-%s".formatted(profile), issuedAt.plus(Duration.ofMinutes(15)));
        }

        @Override
        public String generateSecureToken() {
            return secureTokens.remove();
        }

        @Override
        public AuthenticationRefreshSession saveRefreshSession(AuthenticationRefreshSession authenticationRefreshSession) {
            savedRefreshSessions.add(authenticationRefreshSession);
            refreshSession = authenticationRefreshSession;
            return authenticationRefreshSession;
        }

        @Override
        public Optional<AuthenticationRefreshSession> loadRefreshSessionByTokenHash(String refreshTokenHash) {
            return Optional.ofNullable(refreshSession)
                    .filter(session -> session.refreshTokenHash().equals(refreshTokenHash));
        }

        @Override
        public AuthenticationRefreshSession updateRefreshSession(AuthenticationRefreshSession authenticationRefreshSession) {
            revokedRefreshSession = authenticationRefreshSession;
            if (refreshSession != null && refreshSession.sessionIdentifier().equals(authenticationRefreshSession.sessionIdentifier())) {
                refreshSession = authenticationRefreshSession;
            }
            return authenticationRefreshSession;
        }
    }
}
