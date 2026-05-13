package br.com.worklink.infrastructure.professional;

import br.com.worklink.application.professional.port.ListProfessionalPortfolioItemsPort;
import br.com.worklink.application.professional.port.SaveProfessionalPortfolioItemPort;
import br.com.worklink.domain.professional.ProfessionalPortfolioItem;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

@Repository
public class JdbcProfessionalPortfolioRepositoryAdapter implements
        SaveProfessionalPortfolioItemPort,
        ListProfessionalPortfolioItemsPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcProfessionalPortfolioRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ProfessionalPortfolioItem saveProfessionalPortfolioItem(
            ProfessionalPortfolioItem professionalPortfolioItem
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.professional_portfolio_items (
                    portfolio_item_identifier,
                    professional_identifier,
                    file_identifier,
                    title,
                    description,
                    display_order,
                    active
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                professionalPortfolioItem.portfolioItemIdentifier(),
                professionalPortfolioItem.professionalIdentifier(),
                professionalPortfolioItem.fileIdentifier(),
                professionalPortfolioItem.title(),
                professionalPortfolioItem.description(),
                professionalPortfolioItem.displayOrder(),
                professionalPortfolioItem.active()
        );
        return professionalPortfolioItem;
    }

    @Override
    public List<ProfessionalPortfolioItem> listActiveProfessionalPortfolioItems(UUID professionalIdentifier) {
        return jdbcTemplate.query(
                """
                SELECT portfolio_item_identifier,
                       professional_identifier,
                       file_identifier,
                       title,
                       description,
                       display_order,
                       active
                  FROM worklink.professional_portfolio_items
                 WHERE professional_identifier = ?
                   AND active = TRUE
              ORDER BY display_order ASC, created_at ASC
                """,
                (resultSet, rowNumber) -> mapProfessionalPortfolioItem(resultSet),
                professionalIdentifier
        );
    }

    private ProfessionalPortfolioItem mapProfessionalPortfolioItem(ResultSet resultSet) throws SQLException {
        return ProfessionalPortfolioItem.restoreProfessionalPortfolioItem(
                resultSet.getObject("portfolio_item_identifier", UUID.class),
                resultSet.getObject("professional_identifier", UUID.class),
                resultSet.getObject("file_identifier", UUID.class),
                resultSet.getString("title"),
                resultSet.getString("description"),
                resultSet.getInt("display_order"),
                resultSet.getBoolean("active")
        );
    }
}
