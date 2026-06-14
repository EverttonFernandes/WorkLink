package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.LoadActiveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByIdentifierPort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.LoadRefreshSessionByTokenHashPort;
import br.com.worklink.application.authentication.port.LocalAuthenticationAccountRepositoryPort;
import br.com.worklink.application.authentication.port.PasswordRecoveryChallengeRepositoryPort;
import br.com.worklink.application.authentication.port.RevokeAllCustomerRefreshSessionsPort;
import br.com.worklink.application.authentication.port.SaveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.authentication.port.UpdateAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.UpdateRefreshSessionPort;
import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;
import br.com.worklink.domain.authentication.AuthenticationRefreshSession;
import br.com.worklink.domain.authentication.CustomerAccount;
import br.com.worklink.domain.authentication.LocalAuthenticationAccount;
import br.com.worklink.domain.authentication.PasswordRecoveryChallenge;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcAuthenticationRepositoryAdapter implements
        SaveAuthenticationOtpChallengePort,
        LoadActiveAuthenticationOtpChallengePort,
        UpdateAuthenticationOtpChallengePort,
        LoadCustomerAccountByPhoneNumberPort,
        LoadCustomerAccountByIdentifierPort,
        SaveCustomerAccountPort,
        SaveRefreshSessionPort,
        LoadRefreshSessionByTokenHashPort,
        UpdateRefreshSessionPort,
        LocalAuthenticationAccountRepositoryPort,
        PasswordRecoveryChallengeRepositoryPort,
        RevokeAllCustomerRefreshSessionsPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcAuthenticationRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public AuthenticationOtpChallenge saveAuthenticationOtpChallenge(AuthenticationOtpChallenge authenticationOtpChallenge) {
        jdbcTemplate.update(
                """
                        INSERT INTO worklink.authentication_otp_challenges (
                            challenge_identifier,
                            phone_number,
                            otp_hash,
                            expires_at,
                            failed_attempts,
                            used,
                            created_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?)
                        """,
                authenticationOtpChallenge.challengeIdentifier(),
                authenticationOtpChallenge.phoneNumber(),
                authenticationOtpChallenge.otpHash(),
                Timestamp.from(authenticationOtpChallenge.expiresAt()),
                authenticationOtpChallenge.failedAttempts(),
                authenticationOtpChallenge.used(),
                Timestamp.from(authenticationOtpChallenge.createdAt())
        );
        return authenticationOtpChallenge;
    }

    @Override
    public Optional<AuthenticationOtpChallenge> loadActiveAuthenticationOtpChallengeByPhoneNumber(String phoneNumber) {
        List<AuthenticationOtpChallenge> authenticationOtpChallenges = jdbcTemplate.query(
                """
                        SELECT challenge_identifier,
                               phone_number,
                               otp_hash,
                               expires_at,
                               failed_attempts,
                               used,
                               created_at
                          FROM worklink.authentication_otp_challenges
                         WHERE phone_number = ?
                           AND used = false
                         ORDER BY created_at DESC
                         LIMIT 1
                        """,
                (resultSet, rowNumber) -> mapAuthenticationOtpChallenge(resultSet),
                phoneNumber
        );
        return authenticationOtpChallenges.stream().findFirst();
    }

    @Override
    public AuthenticationOtpChallenge updateAuthenticationOtpChallenge(AuthenticationOtpChallenge authenticationOtpChallenge) {
        jdbcTemplate.update(
                """
                        UPDATE worklink.authentication_otp_challenges
                           SET failed_attempts = ?,
                               used = ?
                         WHERE challenge_identifier = ?
                        """,
                authenticationOtpChallenge.failedAttempts(),
                authenticationOtpChallenge.used(),
                authenticationOtpChallenge.challengeIdentifier()
        );
        return authenticationOtpChallenge;
    }

    @Override
    public Optional<CustomerAccount> loadCustomerAccountByPhoneNumber(String phoneNumber) {
        List<CustomerAccount> customerAccounts = jdbcTemplate.query(
                """
                        SELECT customer_identifier,
                               phone_number,
                               created_at
                          FROM worklink.customer_accounts
                         WHERE phone_number = ?
                        """,
                (resultSet, rowNumber) -> mapCustomerAccount(resultSet),
                phoneNumber
        );
        return customerAccounts.stream().findFirst();
    }

    @Override
    public Optional<CustomerAccount> loadCustomerAccountByIdentifier(UUID customerIdentifier) {
        List<CustomerAccount> customerAccounts = jdbcTemplate.query(
                """
                        SELECT customer_identifier,
                               phone_number,
                               created_at
                          FROM worklink.customer_accounts
                         WHERE customer_identifier = ?
                        """,
                (resultSet, rowNumber) -> mapCustomerAccount(resultSet),
                customerIdentifier
        );
        return customerAccounts.stream().findFirst();
    }

    @Override
    public CustomerAccount saveCustomerAccount(CustomerAccount customerAccount) {
        jdbcTemplate.update(
                """
                        INSERT INTO worklink.customer_accounts (
                            customer_identifier,
                            phone_number,
                            created_at
                        ) VALUES (?, ?, ?)
                        """,
                customerAccount.customerIdentifier(),
                customerAccount.phoneNumber(),
                Timestamp.from(customerAccount.createdAt())
        );
        return customerAccount;
    }

    @Override
    public AuthenticationRefreshSession saveRefreshSession(AuthenticationRefreshSession authenticationRefreshSession) {
        jdbcTemplate.update(
                """
                        INSERT INTO worklink.authentication_refresh_sessions (
                            session_identifier,
                            customer_identifier,
                            refresh_token_hash,
                            expires_at,
                            revoked,
                            created_at
                        ) VALUES (?, ?, ?, ?, ?, ?)
                        """,
                authenticationRefreshSession.sessionIdentifier(),
                authenticationRefreshSession.customerIdentifier(),
                authenticationRefreshSession.refreshTokenHash(),
                Timestamp.from(authenticationRefreshSession.expiresAt()),
                authenticationRefreshSession.revoked(),
                Timestamp.from(authenticationRefreshSession.createdAt())
        );
        return authenticationRefreshSession;
    }

    @Override
    public Optional<AuthenticationRefreshSession> loadRefreshSessionByTokenHash(String refreshTokenHash) {
        List<AuthenticationRefreshSession> authenticationRefreshSessions = jdbcTemplate.query(
                """
                        SELECT session_identifier,
                               customer_identifier,
                               refresh_token_hash,
                               expires_at,
                               revoked,
                               created_at
                          FROM worklink.authentication_refresh_sessions
                         WHERE refresh_token_hash = ?
                        """,
                (resultSet, rowNumber) -> mapAuthenticationRefreshSession(resultSet),
                refreshTokenHash
        );
        return authenticationRefreshSessions.stream().findFirst();
    }

    @Override
    public AuthenticationRefreshSession updateRefreshSession(AuthenticationRefreshSession authenticationRefreshSession) {
        jdbcTemplate.update(
                """
                        UPDATE worklink.authentication_refresh_sessions
                           SET revoked = ?
                         WHERE session_identifier = ?
                        """,
                authenticationRefreshSession.revoked(),
                authenticationRefreshSession.sessionIdentifier()
        );
        return authenticationRefreshSession;
    }

    @Override
    public boolean revokeRefreshSessionIfActive(AuthenticationRefreshSession authenticationRefreshSession) {
        int affectedRows = jdbcTemplate.update(
                """
                        UPDATE worklink.authentication_refresh_sessions
                           SET revoked = true
                         WHERE session_identifier = ?
                           AND revoked = false
                        """,
                authenticationRefreshSession.sessionIdentifier()
        );
        return affectedRows == 1;
    }

    @Override
    public Optional<LocalAuthenticationAccount> loadByNormalizedEmailAddress(String normalizedEmailAddress) {
        return loadLocalAccounts("normalized_email_address", normalizedEmailAddress).stream().findFirst();
    }

    @Override
    public Optional<LocalAuthenticationAccount> loadByCustomerIdentifier(UUID customerIdentifier) {
        return loadLocalAccounts("customer_identifier", customerIdentifier).stream().findFirst();
    }

    @Override
    public LocalAuthenticationAccount save(LocalAuthenticationAccount account) {
        jdbcTemplate.update(
                """
                        INSERT INTO worklink.local_authentication_accounts (
                            customer_identifier, full_name, phone_number, normalized_email_address,
                            password_hash, legal_accepted, phone_verified, failed_login_attempts,
                            blocked_until, created_at, updated_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                account.customerIdentifier(), account.fullName(), account.phoneNumber(),
                account.normalizedEmailAddress(), account.passwordHash(), account.legalAccepted(),
                account.phoneVerified(), account.failedLoginAttempts(), timestampOrNull(account.blockedUntil()),
                Timestamp.from(account.createdAt()), Timestamp.from(account.updatedAt())
        );
        return account;
    }

    @Override
    public LocalAuthenticationAccount update(LocalAuthenticationAccount account) {
        jdbcTemplate.update(
                """
                        UPDATE worklink.local_authentication_accounts
                           SET password_hash = ?,
                               failed_login_attempts = ?,
                               blocked_until = ?,
                               updated_at = ?
                         WHERE customer_identifier = ?
                        """,
                account.passwordHash(), account.failedLoginAttempts(), timestampOrNull(account.blockedUntil()),
                Timestamp.from(account.updatedAt()), account.customerIdentifier()
        );
        return account;
    }

    @Override
    public PasswordRecoveryChallenge save(PasswordRecoveryChallenge challenge) {
        jdbcTemplate.update(
                """
                        INSERT INTO worklink.password_recovery_challenges (
                            challenge_identifier, customer_identifier, token_hash, expires_at, used, created_at
                        ) VALUES (?, ?, ?, ?, ?, ?)
                        """,
                challenge.challengeIdentifier(), challenge.customerIdentifier(), challenge.tokenHash(),
                Timestamp.from(challenge.expiresAt()), challenge.used(), Timestamp.from(challenge.createdAt())
        );
        return challenge;
    }

    @Override
    public Optional<PasswordRecoveryChallenge> loadByTokenHash(String tokenHash) {
        List<PasswordRecoveryChallenge> challenges = jdbcTemplate.query(
                """
                        SELECT challenge_identifier, customer_identifier, token_hash, expires_at, used, created_at
                          FROM worklink.password_recovery_challenges
                         WHERE token_hash = ?
                        """,
                (resultSet, rowNumber) -> mapPasswordRecoveryChallenge(resultSet),
                tokenHash
        );
        return challenges.stream().findFirst();
    }

    @Override
    public PasswordRecoveryChallenge update(PasswordRecoveryChallenge challenge) {
        jdbcTemplate.update(
                "UPDATE worklink.password_recovery_challenges SET used = ? WHERE challenge_identifier = ?",
                challenge.used(), challenge.challengeIdentifier()
        );
        return challenge;
    }

    @Override
    public boolean markAsUsedIfActive(UUID challengeIdentifier) {
        int affectedRows = jdbcTemplate.update(
                """
                        UPDATE worklink.password_recovery_challenges
                           SET used = true
                         WHERE challenge_identifier = ?
                           AND used = false
                        """,
                challengeIdentifier
        );
        return affectedRows == 1;
    }

    @Override
    public void deleteExpiredOrUsedChallenges(java.time.Instant currentInstant) {
        jdbcTemplate.update(
                """
                        DELETE FROM worklink.password_recovery_challenges
                         WHERE used = true
                            OR expires_at <= ?
                        """,
                Timestamp.from(currentInstant)
        );
    }

    @Override
    public void revokeAllCustomerRefreshSessions(UUID customerIdentifier) {
        jdbcTemplate.update(
                "UPDATE worklink.authentication_refresh_sessions SET revoked = true WHERE customer_identifier = ?",
                customerIdentifier
        );
    }

    private List<LocalAuthenticationAccount> loadLocalAccounts(String columnName, Object value) {
        String query = """
                SELECT customer_identifier, full_name, phone_number, normalized_email_address,
                       password_hash, legal_accepted, phone_verified, failed_login_attempts,
                       blocked_until, created_at, updated_at
                  FROM worklink.local_authentication_accounts
                 WHERE %s = ?
                """.formatted(columnName);
        return jdbcTemplate.query(query, (resultSet, rowNumber) -> mapLocalAuthenticationAccount(resultSet), value);
    }

    private static LocalAuthenticationAccount mapLocalAuthenticationAccount(ResultSet resultSet)
            throws java.sql.SQLException {
        Timestamp blockedUntil = resultSet.getTimestamp("blocked_until");
        return LocalAuthenticationAccount.restore(
                resultSet.getObject("customer_identifier", UUID.class),
                resultSet.getString("full_name"),
                resultSet.getString("phone_number"),
                resultSet.getString("normalized_email_address"),
                resultSet.getString("password_hash"),
                resultSet.getBoolean("legal_accepted"),
                resultSet.getBoolean("phone_verified"),
                resultSet.getInt("failed_login_attempts"),
                blockedUntil == null ? null : blockedUntil.toInstant(),
                resultSet.getTimestamp("created_at").toInstant(),
                resultSet.getTimestamp("updated_at").toInstant()
        );
    }

    private static PasswordRecoveryChallenge mapPasswordRecoveryChallenge(ResultSet resultSet)
            throws java.sql.SQLException {
        return PasswordRecoveryChallenge.restore(
                resultSet.getObject("challenge_identifier", UUID.class),
                resultSet.getObject("customer_identifier", UUID.class),
                resultSet.getString("token_hash"),
                resultSet.getTimestamp("expires_at").toInstant(),
                resultSet.getBoolean("used"),
                resultSet.getTimestamp("created_at").toInstant()
        );
    }

    private static Timestamp timestampOrNull(java.time.Instant instant) {
        return instant == null ? null : Timestamp.from(instant);
    }

    private static AuthenticationOtpChallenge mapAuthenticationOtpChallenge(ResultSet resultSet) throws java.sql.SQLException {
        return AuthenticationOtpChallenge.restore(
                resultSet.getObject("challenge_identifier", UUID.class),
                resultSet.getString("phone_number"),
                resultSet.getString("otp_hash"),
                resultSet.getTimestamp("expires_at").toInstant(),
                resultSet.getInt("failed_attempts"),
                resultSet.getBoolean("used"),
                resultSet.getTimestamp("created_at").toInstant()
        );
    }

    private static CustomerAccount mapCustomerAccount(ResultSet resultSet) throws java.sql.SQLException {
        return CustomerAccount.restore(
                resultSet.getObject("customer_identifier", UUID.class),
                resultSet.getString("phone_number"),
                resultSet.getTimestamp("created_at").toInstant()
        );
    }

    private static AuthenticationRefreshSession mapAuthenticationRefreshSession(ResultSet resultSet) throws java.sql.SQLException {
        return AuthenticationRefreshSession.restore(
                resultSet.getObject("session_identifier", UUID.class),
                resultSet.getObject("customer_identifier", UUID.class),
                resultSet.getString("refresh_token_hash"),
                resultSet.getTimestamp("expires_at").toInstant(),
                resultSet.getBoolean("revoked"),
                resultSet.getTimestamp("created_at").toInstant()
        );
    }
}
