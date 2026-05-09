package br.com.worklink.infrastructure.metrics;

import br.com.worklink.application.metrics.port.LoadFunctionalMetricsPort;
import br.com.worklink.application.metrics.port.SaveProfessionalSearchEventPort;
import br.com.worklink.application.metrics.usecase.ContactMetricResponse;
import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;
import br.com.worklink.application.metrics.usecase.ProfessionalSearchEvent;
import br.com.worklink.application.metrics.usecase.ReputationMetricResponse;
import br.com.worklink.application.metrics.usecase.ResponsivenessMetricResponse;

import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Repository
public class JdbcFunctionalMetricsRepositoryAdapter
        implements SaveProfessionalSearchEventPort, LoadFunctionalMetricsPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcFunctionalMetricsRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ProfessionalSearchEvent saveProfessionalSearchEvent(ProfessionalSearchEvent professionalSearchEvent) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.professional_search_events (
                    professional_search_event_identifier,
                    category_identifier,
                    keyword,
                    result_count,
                    created_at
                )
                VALUES (?, ?, ?, ?, ?)
                """,
                professionalSearchEvent.professionalSearchEventIdentifier(),
                professionalSearchEvent.categoryIdentifier(),
                professionalSearchEvent.keyword(),
                professionalSearchEvent.resultCount(),
                professionalSearchEvent.createdAt()
        );
        insertSearchEventCities(
                professionalSearchEvent.professionalSearchEventIdentifier(),
                professionalSearchEvent.cityIdentifiers()
        );
        return professionalSearchEvent;
    }

    @Override
    public FunctionalMetricsResponse loadFunctionalMetrics() {
        return new FunctionalMetricsResponse(
                countFrom("SELECT COUNT(*) FROM worklink.professional_search_events"),
                countFrom("SELECT COUNT(*) FROM worklink.contact_intentions"),
                countFrom("SELECT COUNT(*) FROM worklink.post_contact_feedbacks"),
                countFrom("SELECT COUNT(*) FROM worklink.professional_reviews"),
                countFrom(
                        """
                        SELECT COUNT(*)
                        FROM worklink.professionals
                        WHERE blocked = FALSE
                          AND availability_status = 'ACCEPTING_NEW_CLIENTS'
                        """
                ),
                countFrom(
                        """
                        SELECT COUNT(*)
                        FROM worklink.professionals
                        WHERE blocked = FALSE
                          AND availability_status = 'AVAILABLE_TODAY'
                        """
                ),
                false,
                contactsByProfessional(),
                contactsByCategory(),
                contactsByCity(),
                responsivenessSignals(),
                reputationSignals()
        );
    }

    private void insertSearchEventCities(UUID searchEventIdentifier, Set<UUID> cityIdentifiers) {
        List<UUID> selectedCityIdentifiers = new ArrayList<>(cityIdentifiers);
        jdbcTemplate.batchUpdate(
                """
                INSERT INTO worklink.professional_search_event_cities (
                    professional_search_event_identifier,
                    city_identifier
                )
                VALUES (?, ?)
                """,
                new BatchPreparedStatementSetter() {
                    @Override
                    public void setValues(PreparedStatement preparedStatement, int index) throws SQLException {
                        preparedStatement.setObject(1, searchEventIdentifier);
                        preparedStatement.setObject(2, selectedCityIdentifiers.get(index));
                    }

                    @Override
                    public int getBatchSize() {
                        return selectedCityIdentifiers.size();
                    }
                }
        );
    }

    private long countFrom(String sql) {
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return count == null ? 0L : count;
    }

    private List<ContactMetricResponse> contactsByProfessional() {
        return jdbcTemplate.query(
                """
                SELECT professional_identifier AS metric_identifier,
                       COUNT(*) AS contact_count
                FROM worklink.contact_intentions
                GROUP BY professional_identifier
                ORDER BY contact_count DESC, professional_identifier ASC
                """,
                (resultSet, rowNumber) -> new ContactMetricResponse(
                        resultSet.getObject("metric_identifier", UUID.class),
                        resultSet.getLong("contact_count")
                )
        );
    }

    private List<ContactMetricResponse> contactsByCategory() {
        return jdbcTemplate.query(
                """
                SELECT professionals.category_identifier AS metric_identifier,
                       COUNT(*) AS contact_count
                FROM worklink.contact_intentions contact_intentions
                JOIN worklink.professionals professionals
                  ON professionals.professional_identifier = contact_intentions.professional_identifier
                GROUP BY professionals.category_identifier
                ORDER BY contact_count DESC, professionals.category_identifier ASC
                """,
                (resultSet, rowNumber) -> new ContactMetricResponse(
                        resultSet.getObject("metric_identifier", UUID.class),
                        resultSet.getLong("contact_count")
                )
        );
    }

    private List<ContactMetricResponse> contactsByCity() {
        return jdbcTemplate.query(
                """
                SELECT professionals.city_identifier AS metric_identifier,
                       COUNT(*) AS contact_count
                FROM worklink.contact_intentions contact_intentions
                JOIN worklink.professionals professionals
                  ON professionals.professional_identifier = contact_intentions.professional_identifier
                GROUP BY professionals.city_identifier
                ORDER BY contact_count DESC, professionals.city_identifier ASC
                """,
                (resultSet, rowNumber) -> new ContactMetricResponse(
                        resultSet.getObject("metric_identifier", UUID.class),
                        resultSet.getLong("contact_count")
                )
        );
    }

    private List<ResponsivenessMetricResponse> responsivenessSignals() {
        return jdbcTemplate.query(
                """
                SELECT contact_responsiveness,
                       COUNT(*) AS feedback_count
                FROM worklink.post_contact_feedbacks
                GROUP BY contact_responsiveness
                ORDER BY feedback_count DESC, contact_responsiveness ASC
                """,
                (resultSet, rowNumber) -> new ResponsivenessMetricResponse(
                        resultSet.getString("contact_responsiveness"),
                        resultSet.getLong("feedback_count")
                )
        );
    }

    private List<ReputationMetricResponse> reputationSignals() {
        return jdbcTemplate.query(
                """
                SELECT professional_identifier,
                       ROUND(AVG(star_rating)::numeric, 2) AS average_rating,
                       COUNT(*) AS review_count
                FROM worklink.professional_reviews
                GROUP BY professional_identifier
                ORDER BY average_rating DESC, review_count DESC, professional_identifier ASC
                """,
                (resultSet, rowNumber) -> new ReputationMetricResponse(
                        resultSet.getObject("professional_identifier", UUID.class),
                        resultSet.getDouble("average_rating"),
                        resultSet.getLong("review_count")
                )
        );
    }
}
