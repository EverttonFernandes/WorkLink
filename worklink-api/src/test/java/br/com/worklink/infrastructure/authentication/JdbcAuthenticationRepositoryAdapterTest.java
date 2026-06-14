package br.com.worklink.infrastructure.authentication;

import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;
import br.com.worklink.domain.authentication.AuthenticationRefreshSession;
import br.com.worklink.domain.authentication.CustomerAccount;
import br.com.worklink.domain.authentication.LocalAuthenticationAccount;
import br.com.worklink.domain.authentication.PasswordRecoveryChallenge;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcAuthenticationRepositoryAdapterTest {

    private static final Instant CURRENT_INSTANT = Instant.parse("2026-05-08T20:00:00Z");

    @Test
    @DisplayName("GIVEN desafio OTP WHEN salvar THEN deve usar JdbcTemplate")
    void shouldPersistAuthenticationOtpChallengeUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAuthenticationRepositoryAdapter adapter = new JdbcAuthenticationRepositoryAdapter(jdbcTemplate);
        AuthenticationOtpChallenge challenge = authenticationOtpChallenge();

        // WHEN
        AuthenticationOtpChallenge savedChallenge = adapter.saveAuthenticationOtpChallenge(challenge);

        // THEN
        assertThat(savedChallenge).isEqualTo(challenge);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(challenge.challengeIdentifier()),
                eq(challenge.phoneNumber()),
                eq(challenge.otpHash()),
                eq(Timestamp.from(challenge.expiresAt())),
                eq(challenge.failedAttempts()),
                eq(challenge.used()),
                eq(Timestamp.from(challenge.createdAt()))
        );
    }

    @Test
    @DisplayName("GIVEN telefone WHEN carregar desafio ativo THEN deve mapear resultado")
    void shouldLoadActiveAuthenticationOtpChallengeByPhoneNumber() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAuthenticationRepositoryAdapter adapter = new JdbcAuthenticationRepositoryAdapter(jdbcTemplate);
        AuthenticationOtpChallenge challenge = authenticationOtpChallenge();
        ResultSet resultSet = authenticationOtpChallengeResultSet(challenge);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(challenge.phoneNumber()))).thenAnswer(invocation -> {
            RowMapper<AuthenticationOtpChallenge> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        Optional<AuthenticationOtpChallenge> loadedChallenge =
                adapter.loadActiveAuthenticationOtpChallengeByPhoneNumber(challenge.phoneNumber());

        // THEN
        assertThat(loadedChallenge).contains(challenge);
    }

    @Test
    @DisplayName("GIVEN cliente WHEN salvar e carregar THEN deve mapear conta")
    void shouldPersistAndLoadCustomerAccount() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAuthenticationRepositoryAdapter adapter = new JdbcAuthenticationRepositoryAdapter(jdbcTemplate);
        CustomerAccount customerAccount = CustomerAccount.registerCustomerAccount("51999999999", CURRENT_INSTANT);
        ResultSet resultSet = customerAccountResultSet(customerAccount);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(customerAccount.phoneNumber()))).thenAnswer(invocation -> {
            RowMapper<CustomerAccount> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        CustomerAccount savedCustomerAccount = adapter.saveCustomerAccount(customerAccount);
        Optional<CustomerAccount> loadedCustomerAccount = adapter.loadCustomerAccountByPhoneNumber(customerAccount.phoneNumber());

        // THEN
        assertThat(savedCustomerAccount).isEqualTo(customerAccount);
        assertThat(loadedCustomerAccount).contains(customerAccount);
    }

    @Test
    @DisplayName("GIVEN sessao refresh WHEN salvar carregar e revogar THEN deve mapear sessao")
    void shouldPersistLoadAndUpdateRefreshSession() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAuthenticationRepositoryAdapter adapter = new JdbcAuthenticationRepositoryAdapter(jdbcTemplate);
        AuthenticationRefreshSession refreshSession = authenticationRefreshSession();
        when(jdbcTemplate.update(any(String.class), org.mockito.ArgumentMatchers.<Object[]>any())).thenReturn(1);
        ResultSet resultSet = authenticationRefreshSessionResultSet(refreshSession);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(refreshSession.refreshTokenHash()))).thenAnswer(invocation -> {
            RowMapper<AuthenticationRefreshSession> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        AuthenticationRefreshSession savedRefreshSession = adapter.saveRefreshSession(refreshSession);
        Optional<AuthenticationRefreshSession> loadedRefreshSession =
                adapter.loadRefreshSessionByTokenHash(refreshSession.refreshTokenHash());
        AuthenticationRefreshSession revokedRefreshSession = adapter.updateRefreshSession(refreshSession.revoke());
        boolean revokedConditionally = adapter.revokeRefreshSessionIfActive(refreshSession);

        // THEN
        assertThat(savedRefreshSession).isEqualTo(refreshSession);
        assertThat(loadedRefreshSession).contains(refreshSession);
        assertThat(revokedRefreshSession.revoked()).isTrue();
        assertThat(revokedConditionally).isTrue();
    }

    @Test
    @DisplayName("GIVEN credencial local WHEN salvar carregar e atualizar THEN deve mapear todos os dados")
    void shouldPersistLoadAndUpdateLocalAuthenticationAccount() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAuthenticationRepositoryAdapter adapter = new JdbcAuthenticationRepositoryAdapter(jdbcTemplate);
        LocalAuthenticationAccount account = localAuthenticationAccount();
        ResultSet resultSet = localAuthenticationAccountResultSet(account);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(account.normalizedEmailAddress())))
                .thenAnswer(invocation -> {
                    RowMapper<LocalAuthenticationAccount> rowMapper = invocation.getArgument(1);
                    return List.of(rowMapper.mapRow(resultSet, 0));
                });
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(account.customerIdentifier())))
                .thenAnswer(invocation -> {
                    RowMapper<LocalAuthenticationAccount> rowMapper = invocation.getArgument(1);
                    return List.of(rowMapper.mapRow(resultSet, 0));
                });

        // WHEN
        LocalAuthenticationAccount savedAccount = adapter.save(account);
        Optional<LocalAuthenticationAccount> accountLoadedByEmail =
                adapter.loadByNormalizedEmailAddress(account.normalizedEmailAddress());
        Optional<LocalAuthenticationAccount> accountLoadedByCustomer =
                adapter.loadByCustomerIdentifier(account.customerIdentifier());
        LocalAuthenticationAccount updatedAccount = adapter.update(account.clearLoginFailures(CURRENT_INSTANT));

        // THEN
        assertThat(savedAccount).isEqualTo(account);
        assertThat(accountLoadedByEmail).contains(account);
        assertThat(accountLoadedByCustomer).contains(account);
        assertThat(updatedAccount.failedLoginAttempts()).isZero();
    }

    @Test
    @DisplayName("GIVEN recuperacao WHEN salvar carregar usar e revogar sessoes THEN deve persistir transicoes")
    void shouldPersistPasswordRecoveryAndRevokeCustomerSessions() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAuthenticationRepositoryAdapter adapter = new JdbcAuthenticationRepositoryAdapter(jdbcTemplate);
        when(jdbcTemplate.update(any(String.class), org.mockito.ArgumentMatchers.<Object[]>any())).thenReturn(1);
        PasswordRecoveryChallenge challenge = PasswordRecoveryChallenge.request(
                UUID.randomUUID(),
                "recovery-token-hash",
                CURRENT_INSTANT.plusSeconds(1800),
                CURRENT_INSTANT
        );
        ResultSet resultSet = passwordRecoveryChallengeResultSet(challenge);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(challenge.tokenHash())))
                .thenAnswer(invocation -> {
                    RowMapper<PasswordRecoveryChallenge> rowMapper = invocation.getArgument(1);
                    return List.of(rowMapper.mapRow(resultSet, 0));
                });

        // WHEN
        PasswordRecoveryChallenge savedChallenge = adapter.save(challenge);
        Optional<PasswordRecoveryChallenge> loadedChallenge = adapter.loadByTokenHash(challenge.tokenHash());
        PasswordRecoveryChallenge usedChallenge = adapter.update(challenge.use());
        boolean challengeMarkedAsUsed = adapter.markAsUsedIfActive(challenge.challengeIdentifier());
        adapter.deleteExpiredOrUsedChallenges(CURRENT_INSTANT.plusSeconds(1));
        adapter.revokeAllCustomerRefreshSessions(challenge.customerIdentifier());

        // THEN
        assertThat(savedChallenge).isEqualTo(challenge);
        assertThat(loadedChallenge).contains(challenge);
        assertThat(usedChallenge.used()).isTrue();
        assertThat(challengeMarkedAsUsed).isTrue();
        verify(jdbcTemplate).update(
                "UPDATE worklink.authentication_refresh_sessions SET revoked = true WHERE customer_identifier = ?",
                challenge.customerIdentifier()
        );
    }

    @Test
    @DisplayName("GIVEN consultas sem resultado WHEN carregar entidades THEN deve retornar vazio")
    void shouldReturnEmptyWhenAuthenticationEntitiesDoNotExist() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAuthenticationRepositoryAdapter adapter = new JdbcAuthenticationRepositoryAdapter(jdbcTemplate);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), any(Object.class)))
                .thenReturn(List.of());

        // WHEN / THEN
        assertThat(adapter.loadCustomerAccountByIdentifier(UUID.randomUUID())).isEmpty();
        assertThat(adapter.loadByNormalizedEmailAddress("ausente@example.com")).isEmpty();
        assertThat(adapter.loadByTokenHash("token-ausente")).isEmpty();
    }

    private AuthenticationOtpChallenge authenticationOtpChallenge() {
        return AuthenticationOtpChallenge.requestOtpChallenge(
                "51999999999",
                "otp-hash",
                CURRENT_INSTANT.plusSeconds(300),
                CURRENT_INSTANT
        );
    }

    private AuthenticationRefreshSession authenticationRefreshSession() {
        return AuthenticationRefreshSession.startSession(
                UUID.randomUUID(),
                "refresh-token-hash",
                CURRENT_INSTANT.plusSeconds(2_592_000),
                CURRENT_INSTANT
        );
    }

    private LocalAuthenticationAccount localAuthenticationAccount() {
        return LocalAuthenticationAccount.restore(
                UUID.randomUUID(),
                "Cliente Exemplo",
                "51999999999",
                "cliente@example.com",
                "bcrypt-hash",
                true,
                false,
                2,
                CURRENT_INSTANT.plusSeconds(900),
                CURRENT_INSTANT.minusSeconds(60),
                CURRENT_INSTANT
        );
    }

    private ResultSet authenticationOtpChallengeResultSet(AuthenticationOtpChallenge challenge) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("challenge_identifier", UUID.class)).thenReturn(challenge.challengeIdentifier());
        when(resultSet.getString("phone_number")).thenReturn(challenge.phoneNumber());
        when(resultSet.getString("otp_hash")).thenReturn(challenge.otpHash());
        when(resultSet.getTimestamp("expires_at")).thenReturn(Timestamp.from(challenge.expiresAt()));
        when(resultSet.getInt("failed_attempts")).thenReturn(challenge.failedAttempts());
        when(resultSet.getBoolean("used")).thenReturn(challenge.used());
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(challenge.createdAt()));
        return resultSet;
    }

    private ResultSet customerAccountResultSet(CustomerAccount customerAccount) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("customer_identifier", UUID.class)).thenReturn(customerAccount.customerIdentifier());
        when(resultSet.getString("phone_number")).thenReturn(customerAccount.phoneNumber());
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(customerAccount.createdAt()));
        return resultSet;
    }

    private ResultSet authenticationRefreshSessionResultSet(AuthenticationRefreshSession refreshSession) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("session_identifier", UUID.class)).thenReturn(refreshSession.sessionIdentifier());
        when(resultSet.getObject("customer_identifier", UUID.class)).thenReturn(refreshSession.customerIdentifier());
        when(resultSet.getString("refresh_token_hash")).thenReturn(refreshSession.refreshTokenHash());
        when(resultSet.getTimestamp("expires_at")).thenReturn(Timestamp.from(refreshSession.expiresAt()));
        when(resultSet.getBoolean("revoked")).thenReturn(refreshSession.revoked());
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(refreshSession.createdAt()));
        return resultSet;
    }

    private ResultSet localAuthenticationAccountResultSet(LocalAuthenticationAccount account) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("customer_identifier", UUID.class)).thenReturn(account.customerIdentifier());
        when(resultSet.getString("full_name")).thenReturn(account.fullName());
        when(resultSet.getString("phone_number")).thenReturn(account.phoneNumber());
        when(resultSet.getString("normalized_email_address")).thenReturn(account.normalizedEmailAddress());
        when(resultSet.getString("password_hash")).thenReturn(account.passwordHash());
        when(resultSet.getBoolean("legal_accepted")).thenReturn(account.legalAccepted());
        when(resultSet.getBoolean("phone_verified")).thenReturn(account.phoneVerified());
        when(resultSet.getInt("failed_login_attempts")).thenReturn(account.failedLoginAttempts());
        when(resultSet.getTimestamp("blocked_until")).thenReturn(Timestamp.from(account.blockedUntil()));
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(account.createdAt()));
        when(resultSet.getTimestamp("updated_at")).thenReturn(Timestamp.from(account.updatedAt()));
        return resultSet;
    }

    private ResultSet passwordRecoveryChallengeResultSet(PasswordRecoveryChallenge challenge) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("challenge_identifier", UUID.class)).thenReturn(challenge.challengeIdentifier());
        when(resultSet.getObject("customer_identifier", UUID.class)).thenReturn(challenge.customerIdentifier());
        when(resultSet.getString("token_hash")).thenReturn(challenge.tokenHash());
        when(resultSet.getTimestamp("expires_at")).thenReturn(Timestamp.from(challenge.expiresAt()));
        when(resultSet.getBoolean("used")).thenReturn(challenge.used());
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(challenge.createdAt()));
        return resultSet;
    }
}
