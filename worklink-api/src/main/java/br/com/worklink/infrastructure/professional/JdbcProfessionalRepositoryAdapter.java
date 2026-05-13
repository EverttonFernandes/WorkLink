package br.com.worklink.infrastructure.professional;

import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalAvailabilityStatus;
import br.com.worklink.domain.professional.ProfessionalProfileClassification;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Repository
public class JdbcProfessionalRepositoryAdapter implements
        SaveProfessionalPort,
        ListProfessionalsPort,
        LoadProfessionalByIdentifierPort,
        UpdateProfessionalPort {

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
                    profile_photo_file_identifier,
                    document_number_hash,
                    useful_link,
                    portfolio_description,
                    service_description,
                    profile_completeness_percentage,
                    profile_classification,
                    availability_status,
                    phone_number_verified,
                    quality_guarantee,
                    blocked
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                professional.professionalIdentifier(),
                professional.professionalName(),
                professional.whatsappNumber(),
                professional.cityIdentifier(),
                professional.categoryIdentifier(),
                professional.shortDescription(),
                professional.profilePhotoFileIdentifier(),
                professional.documentNumberHash(),
                professional.usefulLink(),
                professional.portfolioDescription(),
                professional.serviceDescription(),
                professional.profileCompletenessPercentage(),
                professional.profileClassification().name(),
                professional.availabilityStatus().name(),
                professional.phoneNumberVerified(),
                professional.qualityGuarantee(),
                professional.blocked()
        );
        return professional;
    }

    @Override
    public Optional<Professional> loadProfessionalByIdentifier(UUID professionalIdentifier) {
        return jdbcTemplate.query(
                """
                SELECT professional_identifier,
                       professional_name,
                       whatsapp_number,
                       city_identifier,
                       category_identifier,
                       short_description,
                       profile_photo_file_identifier,
                       document_number_hash,
                       useful_link,
                       portfolio_description,
                       service_description,
                       profile_completeness_percentage,
                       profile_classification,
                       availability_status,
                       phone_number_verified,
                       quality_guarantee,
                       blocked
                FROM worklink.professionals
                WHERE professional_identifier = ?
                """,
                (resultSet, rowNumber) -> mapProfessional(resultSet),
                professionalIdentifier
        ).stream().findFirst();
    }

    @Override
    public Professional updateProfessional(Professional professional) {
        jdbcTemplate.update(
                """
                UPDATE worklink.professionals
                SET profile_photo_file_identifier = ?,
                    document_number_hash = ?,
                    useful_link = ?,
                    portfolio_description = ?,
                    service_description = ?,
                    profile_completeness_percentage = ?,
                    profile_classification = ?,
                    availability_status = ?,
                    phone_number_verified = ?,
                    quality_guarantee = ?,
                    blocked = ?
                WHERE professional_identifier = ?
                """,
                professional.profilePhotoFileIdentifier(),
                professional.documentNumberHash(),
                professional.usefulLink(),
                professional.portfolioDescription(),
                professional.serviceDescription(),
                professional.profileCompletenessPercentage(),
                professional.profileClassification().name(),
                professional.availabilityStatus().name(),
                professional.phoneNumberVerified(),
                professional.qualityGuarantee(),
                professional.blocked(),
                professional.professionalIdentifier()
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
                       profile_photo_file_identifier,
                       document_number_hash,
                       useful_link,
                       portfolio_description,
                       service_description,
                       profile_completeness_percentage,
                       profile_classification,
                       availability_status,
                       phone_number_verified,
                       quality_guarantee,
                       blocked
                FROM worklink.professionals
                WHERE blocked = FALSE
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
        sqlBuilder.append("""
                 ORDER BY CASE WHEN availability_status = 'TEMPORARILY_UNAVAILABLE' THEN 1 ELSE 0 END,
                          professional_name ASC
                """);

        return jdbcTemplate.query(
                sqlBuilder.toString(),
                (resultSet, rowNumber) -> mapProfessional(resultSet),
                queryParameters.toArray()
        );
    }

    private Professional mapProfessional(java.sql.ResultSet resultSet) throws java.sql.SQLException {
        return Professional.restoreProfessional(
                resultSet.getObject("professional_identifier", UUID.class),
                resultSet.getString("professional_name"),
                resultSet.getString("whatsapp_number"),
                resultSet.getObject("city_identifier", UUID.class),
                resultSet.getObject("category_identifier", UUID.class),
                resultSet.getString("short_description"),
                resultSet.getObject("profile_photo_file_identifier", UUID.class),
                resultSet.getString("document_number_hash"),
                resultSet.getString("useful_link"),
                resultSet.getString("portfolio_description"),
                resultSet.getString("service_description"),
                resultSet.getInt("profile_completeness_percentage"),
                ProfessionalProfileClassification.valueOf(resultSet.getString("profile_classification")),
                ProfessionalAvailabilityStatus.valueOf(resultSet.getString("availability_status")),
                resultSet.getBoolean("phone_number_verified"),
                resultSet.getBoolean("quality_guarantee"),
                resultSet.getBoolean("blocked")
        );
    }
}
