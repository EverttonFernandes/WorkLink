package br.com.worklink.infrastructure.professional;

import br.com.worklink.domain.professional.ProfessionalPortfolioItem;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcProfessionalPortfolioRepositoryAdapterTest {

    @Test
    @DisplayName("GIVEN item de portfolio WHEN salvar THEN deve persistir metadados do vinculo")
    void shouldPersistPortfolioItemMetadataWhenSavingPortfolioItem() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalPortfolioRepositoryAdapter adapter =
                new JdbcProfessionalPortfolioRepositoryAdapter(jdbcTemplate);
        ProfessionalPortfolioItem portfolioItem = ProfessionalPortfolioItem.addProfessionalPortfolioItem(
                UUID.randomUUID(),
                UUID.randomUUID(),
                "Quadro eletrico residencial",
                "Instalacao concluida em apartamento.",
                1
        );

        // WHEN
        ProfessionalPortfolioItem savedPortfolioItem = adapter.saveProfessionalPortfolioItem(portfolioItem);

        // THEN
        assertThat(savedPortfolioItem).isEqualTo(portfolioItem);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(portfolioItem.portfolioItemIdentifier()),
                eq(portfolioItem.professionalIdentifier()),
                eq(portfolioItem.fileIdentifier()),
                eq(portfolioItem.title()),
                eq(portfolioItem.description()),
                eq(portfolioItem.displayOrder()),
                eq(portfolioItem.active())
        );
    }

    @Test
    @DisplayName("GIVEN profissional WHEN listar portfolio THEN deve filtrar itens ativos por profissional")
    void shouldFilterActivePortfolioItemsByProfessionalWhenListingPortfolio() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        UUID professionalIdentifier = UUID.randomUUID();
        UUID portfolioItemIdentifier = UUID.randomUUID();
        UUID fileIdentifier = UUID.randomUUID();
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(professionalIdentifier)))
                .thenAnswer(invocation -> {
                    RowMapper<ProfessionalPortfolioItem> rowMapper = invocation.getArgument(1);
                    ResultSet resultSet = portfolioResultSet(
                            portfolioItemIdentifier,
                            professionalIdentifier,
                            fileIdentifier
                    );
                    return java.util.List.of(rowMapper.mapRow(resultSet, 0));
                });
        JdbcProfessionalPortfolioRepositoryAdapter adapter =
                new JdbcProfessionalPortfolioRepositoryAdapter(jdbcTemplate);

        // WHEN
        java.util.List<ProfessionalPortfolioItem> portfolioItems =
                adapter.listActiveProfessionalPortfolioItems(professionalIdentifier);

        // THEN
        assertThat(portfolioItems).hasSize(1);
        assertThat(portfolioItems.getFirst().portfolioItemIdentifier()).isEqualTo(portfolioItemIdentifier);
        verify(jdbcTemplate).query(any(String.class), any(RowMapper.class), eq(professionalIdentifier));
    }

    private ResultSet portfolioResultSet(
            UUID portfolioItemIdentifier,
            UUID professionalIdentifier,
            UUID fileIdentifier
    ) throws java.sql.SQLException {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("portfolio_item_identifier", UUID.class)).thenReturn(portfolioItemIdentifier);
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(professionalIdentifier);
        when(resultSet.getObject("file_identifier", UUID.class)).thenReturn(fileIdentifier);
        when(resultSet.getString("title")).thenReturn("Quadro eletrico residencial");
        when(resultSet.getString("description")).thenReturn("Instalacao concluida em apartamento.");
        when(resultSet.getInt("display_order")).thenReturn(1);
        when(resultSet.getBoolean("active")).thenReturn(true);
        return resultSet;
    }
}
