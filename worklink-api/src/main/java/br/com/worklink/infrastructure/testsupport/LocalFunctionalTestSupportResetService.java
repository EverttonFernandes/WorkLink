package br.com.worklink.infrastructure.testsupport;

import br.com.worklink.application.testsupport.port.ResetLocalFunctionalScenarioPort;

import org.springframework.context.annotation.Profile;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.List;

@Profile("local")
@Component
public class LocalFunctionalTestSupportResetService implements ResetLocalFunctionalScenarioPort {

    private final JdbcTemplate jdbcTemplate;

    public LocalFunctionalTestSupportResetService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void resetScenarioState() {
        List<String> tableNames = jdbcTemplate.queryForList(
                """
                SELECT tablename
                FROM pg_tables
                WHERE schemaname = 'worklink'
                  AND tablename <> 'flyway_schema_history'
                ORDER BY tablename ASC
                """,
                String.class
        );
        if (tableNames.isEmpty()) {
            return;
        }
        jdbcTemplate.execute("TRUNCATE TABLE %s CASCADE".formatted(qualifiedTableNames(tableNames)));
    }

    private String qualifiedTableNames(List<String> tableNames) {
        return tableNames.stream()
                .map(tableName -> "worklink.%s".formatted(tableName))
                .reduce((left, right) -> "%s, %s".formatted(left, right))
                .orElseThrow();
    }
}
