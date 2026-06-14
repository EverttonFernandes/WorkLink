package br.com.worklink.domain.authentication;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class LocalAuthenticationAccountTest {

    private static final Instant CURRENT_INSTANT = Instant.parse("2026-06-11T12:00:00Z");

    @Test
    @DisplayName("GIVEN cadastro valido WHEN registrar THEN deve normalizar email e iniciar sem verificacao")
    void shouldRegisterValidLocalAuthenticationAccount() {
        // GIVEN / WHEN
        LocalAuthenticationAccount account = LocalAuthenticationAccount.register(
                UUID.randomUUID(),
                " Cliente Exemplo ",
                " 51999999999 ",
                " Cliente@Example.COM ",
                " bcrypt-hash ",
                true,
                CURRENT_INSTANT
        );

        // THEN
        assertThat(account.fullName()).isEqualTo("Cliente Exemplo");
        assertThat(account.phoneNumber()).isEqualTo("51999999999");
        assertThat(account.normalizedEmailAddress()).isEqualTo("cliente@example.com");
        assertThat(account.passwordHash()).isEqualTo("bcrypt-hash");
        assertThat(account.phoneVerified()).isFalse();
        assertThat(account.failedLoginAttempts()).isZero();
    }

    @Test
    @DisplayName("GIVEN falhas de login WHEN atingir limite THEN deve bloquear e permitir limpeza")
    void shouldBlockAndClearFailedLogins() {
        // GIVEN
        LocalAuthenticationAccount account = validAccount();

        // WHEN
        LocalAuthenticationAccount blockedAccount = account
                .recordFailedLogin(2, Duration.ofMinutes(15), CURRENT_INSTANT)
                .recordFailedLogin(2, Duration.ofMinutes(15), CURRENT_INSTANT);
        LocalAuthenticationAccount clearedAccount =
                blockedAccount.clearLoginFailures(CURRENT_INSTANT.plusSeconds(60));

        // THEN
        assertThat(blockedAccount.isBlockedAt(CURRENT_INSTANT.plusSeconds(1))).isTrue();
        assertThat(blockedAccount.isBlockedAt(CURRENT_INSTANT.plus(Duration.ofMinutes(16)))).isFalse();
        assertThat(clearedAccount.failedLoginAttempts()).isZero();
        assertThat(clearedAccount.blockedUntil()).isNull();
    }

    @Test
    @DisplayName("GIVEN nova senha WHEN alterar THEN deve limpar bloqueio e atualizar hash")
    void shouldChangePasswordAndClearBlockingState() {
        // GIVEN
        LocalAuthenticationAccount account = validAccount()
                .recordFailedLogin(1, Duration.ofMinutes(15), CURRENT_INSTANT);

        // WHEN
        LocalAuthenticationAccount changedAccount =
                account.changePassword("novo-bcrypt-hash", CURRENT_INSTANT.plusSeconds(1));

        // THEN
        assertThat(changedAccount.passwordHash()).isEqualTo("novo-bcrypt-hash");
        assertThat(changedAccount.failedLoginAttempts()).isZero();
        assertThat(changedAccount.blockedUntil()).isNull();
    }

    @Test
    @DisplayName("GIVEN dados invalidos WHEN registrar ou restaurar THEN deve rejeitar")
    void shouldRejectInvalidLocalAuthenticationAccountData() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> LocalAuthenticationAccount.register(
                UUID.randomUUID(), "Cliente", "51999999999", "cliente@example.com",
                "bcrypt-hash", false, CURRENT_INSTANT
        )).isInstanceOf(BusinessRuleViolationException.class);
        assertThatThrownBy(() -> LocalAuthenticationAccount.normalizeEmailAddress("email-invalido"))
                .isInstanceOf(BusinessRuleViolationException.class);
        assertThatThrownBy(() -> LocalAuthenticationAccount.restore(
                null, "Cliente", "51999999999", "cliente@example.com", "hash",
                true, false, 0, null, CURRENT_INSTANT, CURRENT_INSTANT
        )).isInstanceOf(BusinessRuleViolationException.class);
        assertThatThrownBy(() -> LocalAuthenticationAccount.restore(
                UUID.randomUUID(), "Cliente", "51999999999", "cliente@example.com", "hash",
                true, false, -1, null, CURRENT_INSTANT, CURRENT_INSTANT
        )).isInstanceOf(BusinessRuleViolationException.class);
        assertThatThrownBy(() -> LocalAuthenticationAccount.register(
                UUID.randomUUID(), " ", "51999999999", "cliente@example.com",
                "hash", true, CURRENT_INSTANT
        )).isInstanceOf(BusinessRuleViolationException.class);
        assertThatThrownBy(() -> LocalAuthenticationAccount.register(
                UUID.randomUUID(), "Cliente", "51999999999", "cliente@example.com",
                "hash", true, null
        )).isInstanceOf(BusinessRuleViolationException.class);
    }

    private LocalAuthenticationAccount validAccount() {
        return LocalAuthenticationAccount.register(
                UUID.randomUUID(),
                "Cliente Exemplo",
                "51999999999",
                "cliente@example.com",
                "bcrypt-hash",
                true,
                CURRENT_INSTANT
        );
    }
}
