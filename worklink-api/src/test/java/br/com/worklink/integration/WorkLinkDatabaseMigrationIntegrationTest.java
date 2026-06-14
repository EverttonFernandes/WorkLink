package br.com.worklink.integration;

import org.flywaydb.core.Flyway;
import org.flywaydb.core.api.output.MigrateResult;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class WorkLinkDatabaseMigrationIntegrationTest {

    private static final String WORKLINK_SCHEMA = "worklink";
    private static final String MIGRATION_MARKER_TABLE = "database_migration_marker";
    private static final String SERVICE_CATEGORIES_TABLE = "service_categories";
    private static final String SERVICE_CITIES_TABLE = "service_cities";
    private static final String PROFESSIONALS_TABLE = "professionals";
    private static final String LOCAL_AUTHENTICATION_ACCOUNTS_TABLE = "local_authentication_accounts";
    private static final String PASSWORD_RECOVERY_CHALLENGES_TABLE = "password_recovery_challenges";
    private static final String DATABASE_URL = System.getenv().getOrDefault(
            "WORKLINK_DATABASE_URL",
            "jdbc:postgresql://postgres:5432/worklink"
    );
    private static final String DATABASE_USERNAME = System.getenv().getOrDefault(
            "WORKLINK_DATABASE_USERNAME",
            "worklink"
    );
    private static final String DATABASE_PASSWORD = System.getenv().getOrDefault(
            "WORKLINK_DATABASE_PASSWORD",
            "change-me-local-postgres-password"
    );

    @Test
    @DisplayName("Deve aplicar migrations no PostgreSQL real usando container Docker")
    void shouldApplyMigrationsOnRealPostgreSqlUsingDockerContainer() throws Exception {
        // GIVEN
        Flyway flyway = Flyway.configure()
                .dataSource(DATABASE_URL, DATABASE_USERNAME, DATABASE_PASSWORD)
                .schemas(WORKLINK_SCHEMA)
                .createSchemas(true)
                .locations("classpath:db/migration")
                .cleanDisabled(false)
                .load();

        // WHEN
        flyway.clean();
        MigrateResult migrateResult = flyway.migrate();

        // THEN
        assertThat(migrateResult.success).isTrue();
        assertThat(migrateResult.migrationsExecuted).isGreaterThanOrEqualTo(2);
        assertThat(tableExists(MIGRATION_MARKER_TABLE)).isTrue();
        assertThat(tableExists(SERVICE_CATEGORIES_TABLE)).isTrue();
        assertThat(tableExists(SERVICE_CITIES_TABLE)).isTrue();
        assertThat(tableExists(PROFESSIONALS_TABLE)).isTrue();
        assertThat(tableExists(LOCAL_AUTHENTICATION_ACCOUNTS_TABLE)).isTrue();
        assertThat(tableExists(PASSWORD_RECOVERY_CHALLENGES_TABLE)).isTrue();
    }

    @Test
    @DisplayName("Deve preservar contas antigas ao evoluir da V021 para a V022")
    void shouldPreserveLegacyCustomerAccountsWhenMigratingFromVersion21ToVersion22() throws Exception {
        // GIVEN
        Flyway baselineFlyway = Flyway.configure()
                .dataSource(DATABASE_URL, DATABASE_USERNAME, DATABASE_PASSWORD)
                .schemas(WORKLINK_SCHEMA)
                .createSchemas(true)
                .locations("classpath:db/migration")
                .target("21")
                .cleanDisabled(false)
                .load();
        baselineFlyway.clean();
        baselineFlyway.migrate();
        UUID legacyCustomerIdentifier = UUID.randomUUID();
        insertLegacyCustomerAccount(legacyCustomerIdentifier, "51911112222");

        Flyway latestFlyway = Flyway.configure()
                .dataSource(DATABASE_URL, DATABASE_USERNAME, DATABASE_PASSWORD)
                .schemas(WORKLINK_SCHEMA)
                .createSchemas(true)
                .locations("classpath:db/migration")
                .cleanDisabled(false)
                .load();

        // WHEN
        latestFlyway.migrate();

        // THEN
        assertThat(tableExists(LOCAL_AUTHENTICATION_ACCOUNTS_TABLE)).isTrue();
        assertThat(tableExists(PASSWORD_RECOVERY_CHALLENGES_TABLE)).isTrue();
        assertThat(customerAccountExists(legacyCustomerIdentifier, "51911112222")).isTrue();
    }

    private void insertLegacyCustomerAccount(UUID customerIdentifier, String phoneNumber) throws Exception {
        try (Connection connection = DriverManager.getConnection(
                DATABASE_URL,
                DATABASE_USERNAME,
                DATABASE_PASSWORD
        );
             PreparedStatement preparedStatement = connection.prepareStatement("""
                     INSERT INTO worklink.customer_accounts (
                         customer_identifier,
                         phone_number,
                         created_at
                     ) VALUES (?, ?, CURRENT_TIMESTAMP)
                     """)) {
            preparedStatement.setObject(1, customerIdentifier);
            preparedStatement.setString(2, phoneNumber);
            preparedStatement.executeUpdate();
        }
    }

    private boolean customerAccountExists(UUID customerIdentifier, String phoneNumber) throws Exception {
        try (Connection connection = DriverManager.getConnection(
                DATABASE_URL,
                DATABASE_USERNAME,
                DATABASE_PASSWORD
        );
             PreparedStatement preparedStatement = connection.prepareStatement("""
                     SELECT EXISTS (
                         SELECT 1
                         FROM worklink.customer_accounts
                         WHERE customer_identifier = ?
                           AND phone_number = ?
                     )
                     """)) {
            preparedStatement.setObject(1, customerIdentifier);
            preparedStatement.setString(2, phoneNumber);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                assertThat(resultSet.next()).isTrue();
                return resultSet.getBoolean(1);
            }
        }
    }

    private boolean tableExists(String tableName) throws Exception {
        try (Connection connection = DriverManager.getConnection(
                DATABASE_URL,
                DATABASE_USERNAME,
                DATABASE_PASSWORD
        );
             PreparedStatement preparedStatement = connection.prepareStatement("""
                     SELECT EXISTS (
                         SELECT 1
                         FROM information_schema.tables
                         WHERE table_schema = ?
                         AND table_name = ?
                     )
                     """)) {
            preparedStatement.setString(1, WORKLINK_SCHEMA);
            preparedStatement.setString(2, tableName);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                assertThat(resultSet.next()).isTrue();
                return resultSet.getBoolean(1);
            }
        }
    }
}
