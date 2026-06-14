package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.DeliverPasswordRecoveryTokenPort;
import br.com.worklink.application.authentication.port.ExecuteInTransactionPort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.IssuedAccessToken;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.LocalAuthenticationAccountRepositoryPort;
import br.com.worklink.application.authentication.port.PasswordHashingPort;
import br.com.worklink.application.authentication.port.PasswordRecoveryChallengeRepositoryPort;
import br.com.worklink.application.authentication.port.RevokeAllCustomerRefreshSessionsPort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.domain.authentication.CustomerAccount;
import br.com.worklink.domain.authentication.LocalAuthenticationAccount;
import br.com.worklink.domain.authentication.PasswordRecoveryChallenge;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import java.util.function.Supplier;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LocalAuthenticationUseCaseTest {

    private static final Instant CURRENT_INSTANT = Instant.parse("2026-06-11T12:00:00Z");
    private static final Duration REFRESH_DURATION = Duration.ofDays(30);
    private static final String PASSWORD = "senha-segura-123";

    @Test
    @DisplayName("GIVEN cadastro valido WHEN cadastrar THEN deve normalizar email proteger senha e emitir sessao")
    void shouldRegisterLocalAccountAndIssueSession() {
        // GIVEN
        Fixture fixture = new Fixture();
        RegisterLocalAuthenticationUseCase useCase = fixture.registerUseCase();

        // WHEN
        AuthenticationTokenResponse response = useCase.register(new RegisterLocalAuthenticationRequest(
                "Cliente Exemplo", "51999999999", " Cliente@Example.COM ", PASSWORD, true
        ));

        // THEN
        ArgumentCaptor<LocalAuthenticationAccount> accountCaptor =
                ArgumentCaptor.forClass(LocalAuthenticationAccount.class);
        verify(fixture.accountRepository).save(accountCaptor.capture());
        assertThat(accountCaptor.getValue().normalizedEmailAddress()).isEqualTo("cliente@example.com");
        assertThat(accountCaptor.getValue().passwordHash()).isEqualTo("bcrypt-hash");
        assertThat(accountCaptor.getValue().phoneVerified()).isFalse();
        assertThat(response.accessToken()).isEqualTo("access-token");
    }

    @Test
    @DisplayName("GIVEN telefone legado existente WHEN cadastrar THEN deve rejeitar sem vincular senha")
    void shouldRejectRegisteringPasswordAgainstLegacyPhoneNumber() {
        // GIVEN
        Fixture fixture = new Fixture();
        when(fixture.loadCustomerByPhone.loadCustomerAccountByPhoneNumber("51999999999"))
                .thenReturn(Optional.of(CustomerAccount.restore(
                        fixture.customerIdentifier, "51999999999", CURRENT_INSTANT.minusSeconds(60)
                )));

        // WHEN / THEN
        assertThatThrownBy(() -> fixture.registerUseCase().register(new RegisterLocalAuthenticationRequest(
                "Cliente Exemplo", "51999999999", "cliente@example.com", PASSWORD, true
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("Este telefone ja pertence a uma conta existente. Entre com o canal ja cadastrado.");
        verify(fixture.accountRepository, never()).save(any());
    }

    @Test
    @DisplayName("GIVEN cinco senhas incorretas WHEN autenticar THEN deve bloquear por quinze minutos")
    void shouldBlockAccountAfterFiveFailedLogins() {
        // GIVEN
        Fixture fixture = new Fixture();
        LocalAuthenticationAccount account = fixture.accountWithFailures(4);
        when(fixture.accountRepository.loadByNormalizedEmailAddress("cliente@example.com"))
                .thenReturn(Optional.of(account));
        when(fixture.passwordHashingPort.matchesPassword("senha-incorreta", "bcrypt-hash")).thenReturn(false);

        // WHEN / THEN
        assertThatThrownBy(() -> fixture.loginUseCase().login(
                new LoginLocalAuthenticationRequest("cliente@example.com", "senha-incorreta")
        )).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("E-mail ou senha invalidos.");
        ArgumentCaptor<LocalAuthenticationAccount> accountCaptor =
                ArgumentCaptor.forClass(LocalAuthenticationAccount.class);
        verify(fixture.accountRepository).update(accountCaptor.capture());
        assertThat(accountCaptor.getValue().failedLoginAttempts()).isEqualTo(5);
        assertThat(accountCaptor.getValue().blockedUntil()).isEqualTo(CURRENT_INSTANT.plus(Duration.ofMinutes(15)));
    }

    @Test
    @DisplayName("GIVEN email inexistente WHEN solicitar recuperacao THEN deve responder igual sem criar token")
    void shouldNotRevealUnknownEmailDuringPasswordRecovery() {
        // GIVEN
        Fixture fixture = new Fixture();

        // WHEN
        PasswordRecoveryRequestResponse response = fixture.recoveryUseCase().requestRecovery(
                new RequestPasswordRecoveryRequest("unknown@example.com")
        );

        // THEN
        assertThat(response.message()).startsWith("Se o e-mail estiver cadastrado");
        verify(fixture.challengeRepository, never()).save(any());
        verify(fixture.deliveryPort, never()).deliverPasswordRecoveryToken(any(), any());
    }

    @Test
    @DisplayName("GIVEN provedor de recuperacao indisponivel WHEN solicitar recuperacao THEN deve falhar genericamente")
    void shouldRejectPasswordRecoveryWhenDeliveryProviderIsUnavailable() {
        // GIVEN
        Fixture fixture = new Fixture();
        when(fixture.deliveryPort.isDeliveryAvailable()).thenReturn(false);

        // WHEN / THEN
        assertThatThrownBy(() -> fixture.recoveryUseCase().requestRecovery(
                new RequestPasswordRecoveryRequest("cliente@example.com")
        )).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A recuperacao de senha esta indisponivel.");
        verify(fixture.challengeRepository, never()).save(any());
    }

    @Test
    @DisplayName("GIVEN token valido WHEN redefinir senha THEN deve usar token uma vez e revogar sessoes")
    void shouldResetPasswordAndRevokeAllSessions() {
        // GIVEN
        Fixture fixture = new Fixture();
        LocalAuthenticationAccount account = fixture.accountWithFailures(0);
        PasswordRecoveryChallenge challenge = PasswordRecoveryChallenge.request(
                account.customerIdentifier(), "recovery-hash", CURRENT_INSTANT.plus(Duration.ofMinutes(30)),
                CURRENT_INSTANT.minusSeconds(30)
        );
        when(fixture.challengeRepository.loadByTokenHash("recovery-hash")).thenReturn(Optional.of(challenge));
        when(fixture.challengeRepository.markAsUsedIfActive(challenge.challengeIdentifier())).thenReturn(true);
        when(fixture.accountRepository.loadByCustomerIdentifier(account.customerIdentifier()))
                .thenReturn(Optional.of(account));

        // WHEN
        fixture.resetUseCase().resetPassword(new ResetPasswordRequest("raw-token", "nova-senha-segura-123"));

        // THEN
        verify(fixture.accountRepository).update(any(LocalAuthenticationAccount.class));
        verify(fixture.challengeRepository).markAsUsedIfActive(challenge.challengeIdentifier());
        verify(fixture.revokeAllSessionsPort).revokeAllCustomerRefreshSessions(account.customerIdentifier());
    }

    private static class Fixture {

        private final UUID customerIdentifier = UUID.randomUUID();
        private final LocalAuthenticationAccountRepositoryPort accountRepository =
                mock(LocalAuthenticationAccountRepositoryPort.class);
        private final LoadCustomerAccountByPhoneNumberPort loadCustomerByPhone =
                mock(LoadCustomerAccountByPhoneNumberPort.class);
        private final SaveCustomerAccountPort saveCustomer = mock(SaveCustomerAccountPort.class);
        private final PasswordHashingPort passwordHashingPort = mock(PasswordHashingPort.class);
        private final CurrentTimePort currentTimePort = mock(CurrentTimePort.class);
        private final ExecuteInTransactionPort executeInTransactionPort = new InlineTransactionPort();
        private final IssueAccessTokenPort issueAccessTokenPort = mock(IssueAccessTokenPort.class);
        private final GenerateSecureTokenPort generateSecureTokenPort = mock(GenerateSecureTokenPort.class);
        private final ProtectSensitiveValuePort protectSensitiveValuePort = mock(ProtectSensitiveValuePort.class);
        private final SaveRefreshSessionPort saveRefreshSessionPort = mock(SaveRefreshSessionPort.class);
        private final PasswordRecoveryChallengeRepositoryPort challengeRepository =
                mock(PasswordRecoveryChallengeRepositoryPort.class);
        private final DeliverPasswordRecoveryTokenPort deliveryPort = mock(DeliverPasswordRecoveryTokenPort.class);
        private final RevokeAllCustomerRefreshSessionsPort revokeAllSessionsPort =
                mock(RevokeAllCustomerRefreshSessionsPort.class);

        Fixture() {
            CustomerAccount customerAccount = CustomerAccount.restore(
                    customerIdentifier, "51999999999", CURRENT_INSTANT
            );
            when(currentTimePort.currentInstant()).thenReturn(CURRENT_INSTANT);
            when(loadCustomerByPhone.loadCustomerAccountByPhoneNumber("51999999999"))
                    .thenReturn(Optional.empty());
            when(saveCustomer.saveCustomerAccount(any())).thenAnswer(invocation -> invocation.getArgument(0));
            when(passwordHashingPort.hashPassword(any())).thenReturn("bcrypt-hash");
            when(passwordHashingPort.matchesPassword(any(), any()))
                    .thenAnswer(invocation -> {
                        String rawPassword = invocation.getArgument(0, String.class);
                        String storedHash = invocation.getArgument(1, String.class);
                        return PASSWORD.equals(rawPassword) && "bcrypt-hash".equals(storedHash);
                    });
            when(deliveryPort.isDeliveryAvailable()).thenReturn(true);
            when(generateSecureTokenPort.generateSecureToken()).thenReturn("raw-token");
            when(protectSensitiveValuePort.protectSensitiveValue(any(), any()))
                    .thenAnswer(invocation -> invocation.getArgument(0).equals("raw-token")
                            ? "recovery-hash"
                            : "refresh-hash");
            when(issueAccessTokenPort.issueAccessToken(any(), any(), any()))
                    .thenAnswer(invocation -> new IssuedAccessToken(
                            "access-token",
                            invocation.getArgument(2, Instant.class).plus(Duration.ofMinutes(15))
                    ));
        }

        RegisterLocalAuthenticationUseCase registerUseCase() {
            return new RegisterLocalAuthenticationUseCase(
                    accountRepository, loadCustomerByPhone, saveCustomer, passwordHashingPort, currentTimePort,
                    executeInTransactionPort,
                    issueAccessTokenPort, generateSecureTokenPort, protectSensitiveValuePort, saveRefreshSessionPort,
                    REFRESH_DURATION, true
            );
        }

        LoginLocalAuthenticationUseCase loginUseCase() {
            return new LoginLocalAuthenticationUseCase(
                    accountRepository, passwordHashingPort, currentTimePort, issueAccessTokenPort,
                    generateSecureTokenPort, protectSensitiveValuePort, saveRefreshSessionPort,
                    REFRESH_DURATION, 5, Duration.ofMinutes(15), true
            );
        }

        RequestPasswordRecoveryUseCase recoveryUseCase() {
            return new RequestPasswordRecoveryUseCase(
                    accountRepository, challengeRepository, generateSecureTokenPort, protectSensitiveValuePort,
                    deliveryPort, currentTimePort, Duration.ofMinutes(30)
            );
        }

        ResetPasswordUseCase resetUseCase() {
            return new ResetPasswordUseCase(
                    challengeRepository, accountRepository, passwordHashingPort, protectSensitiveValuePort,
                    revokeAllSessionsPort, currentTimePort, executeInTransactionPort
            );
        }

        LocalAuthenticationAccount accountWithFailures(int failedAttempts) {
            return LocalAuthenticationAccount.restore(
                    customerIdentifier, "Cliente Exemplo", "51999999999", "cliente@example.com",
                    "bcrypt-hash", true, false, failedAttempts, null, CURRENT_INSTANT, CURRENT_INSTANT
            );
        }
    }

    private static class InlineTransactionPort implements ExecuteInTransactionPort {

        @Override
        public <T> T execute(Supplier<T> action) {
            return action.get();
        }
    }
}
