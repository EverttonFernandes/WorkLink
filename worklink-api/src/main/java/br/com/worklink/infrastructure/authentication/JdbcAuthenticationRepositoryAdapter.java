package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.LoadActiveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByIdentifierPort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.LoadRefreshSessionByTokenHashPort;
import br.com.worklink.application.authentication.port.SaveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.authentication.port.UpdateAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.UpdateRefreshSessionPort;
import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;
import br.com.worklink.domain.authentication.AuthenticationRefreshSession;
import br.com.worklink.domain.authentication.CustomerAccount;

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
        UpdateRefreshSessionPort {

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
