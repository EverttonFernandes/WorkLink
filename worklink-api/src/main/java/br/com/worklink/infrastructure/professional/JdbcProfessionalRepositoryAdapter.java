package br.com.worklink.infrastructure.professional;

import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalProfileClassification;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Repository
public class JdbcProfessionalRepositoryAdapter implements SaveProfessionalPort, ListProfessionalsPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcProfessionalRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public Professional saveProfessional(Professional professional) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.professionals (
                    professional_identifier,
                    professional_name,
                    whatsapp_number,
                    city_identifier,
                    category_identifier,
                    short_description,
                    profile_classification,
                    quality_guarantee
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                professional.professionalIdentifier(),
                professional.professionalName(),
                professional.whatsappNumber(),
                professional.cityIdentifier(),
                professional.categoryIdentifier(),
                professional.shortDescription(),
                professional.profileClassification().name(),
                professional.qualityGuarantee()
        );
        return professional;
    }

    @Override
    public List<Professional> listProfessionals(ProfessionalSearchCriteria professionalSearchCriteria) {
        StringBuilder sqlBuilder = new StringBuilder("""
                SELECT professional_identifier,
                       professional_name,
                       whatsapp_number,
                       city_identifier,
                       category_identifier,
                       short_description,
                       profile_classification,
                       quality_guarantee
                FROM worklink.professionals
                WHERE 1 = 1
                """);
        List<Object> queryParameters = new ArrayList<>();

        professionalSearchCriteria.categoryIdentifier().ifPresent(categoryIdentifier -> {
            sqlBuilder.append(" AND category_identifier = ?");
            queryParameters.add(categoryIdentifier);
        });
        if (!professionalSearchCriteria.cityIdentifiers().isEmpty()) {
            String cityIdentifierPlaceholders = professionalSearchCriteria.cityIdentifiers().stream()
                    .map(cityIdentifier -> "?")
                    .collect(Collectors.joining(","));
            sqlBuilder.append(" AND city_identifier IN (%s)".formatted(cityIdentifierPlaceholders));
            queryParameters.addAll(professionalSearchCriteria.cityIdentifiers());
        }
        professionalSearchCriteria.keyword().ifPresent(keyword -> {
            sqlBuilder.append(" AND (LOWER(professional_name) LIKE ? OR LOWER(short_description) LIKE ?)");
            String keywordPattern = "%" + keyword.toLowerCase() + "%";
            queryParameters.add(keywordPattern);
            queryParameters.add(keywordPattern);
        });
        sqlBuilder.append(" ORDER BY professional_name ASC");

        return jdbcTemplate.query(
                sqlBuilder.toString(),
                (resultSet, rowNumber) -> Professional.restoreProfessional(
                        resultSet.getObject("professional_identifier", UUID.class),
                        resultSet.getString("professional_name"),
                        resultSet.getString("whatsapp_number"),
                        resultSet.getObject("city_identifier", UUID.class),
                        resultSet.getObject("category_identifier", UUID.class),
                        resultSet.getString("short_description"),
                        ProfessionalProfileClassification.valueOf(resultSet.getString("profile_classification")),
                        resultSet.getBoolean("quality_guarantee")
                ),
                queryParameters.toArray()
        );
    }
}
