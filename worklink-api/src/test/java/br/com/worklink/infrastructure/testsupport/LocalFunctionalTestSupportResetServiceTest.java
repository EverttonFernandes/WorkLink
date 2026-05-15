package br.com.worklink.infrastructure.testsupport;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.List;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class LocalFunctionalTestSupportResetServiceTest {

    @Test
    @DisplayName("GIVEN tabelas funcionais locais existentes WHEN resetar cenario THEN deve truncar todas exceto historico do flyway")
    void shouldTruncateAllFunctionalTablesWhenResettingScenarioState() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        when(jdbcTemplate.queryForList(eq(
                """
                SELECT tablename
                FROM pg_tables
                WHERE schemaname = 'worklink'
                  AND tablename <> 'flyway_schema_history'
                ORDER BY tablename ASC
                """
        ), eq(String.class))).thenReturn(List.of("customer_account", "professional"));
        LocalFunctionalTestSupportResetService service = new LocalFunctionalTestSupportResetService(jdbcTemplate);

        // WHEN
        service.resetScenarioState();

        // THEN
        verify(jdbcTemplate).execute(
                "TRUNCATE TABLE worklink.customer_account, worklink.professional CASCADE"
        );
    }

    @Test
    @DisplayName("GIVEN nenhuma tabela funcional local WHEN resetar cenario THEN nao deve executar truncate")
    void shouldSkipTruncateWhenThereAreNoFunctionalTablesToReset() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        when(jdbcTemplate.queryForList(eq(
                """
                SELECT tablename
                FROM pg_tables
                WHERE schemaname = 'worklink'
                  AND tablename <> 'flyway_schema_history'
                ORDER BY tablename ASC
                """
        ), eq(String.class))).thenReturn(List.of());
        LocalFunctionalTestSupportResetService service = new LocalFunctionalTestSupportResetService(jdbcTemplate);

        // WHEN
        service.resetScenarioState();

        // THEN
        verify(jdbcTemplate, never()).execute(org.mockito.ArgumentMatchers.anyString());
    }
}
