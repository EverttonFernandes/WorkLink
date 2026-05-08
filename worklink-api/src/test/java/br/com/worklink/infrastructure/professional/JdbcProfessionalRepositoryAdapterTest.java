package br.com.worklink.infrastructure.professional;

import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalAvailabilityStatus;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class JdbcProfessionalRepositoryAdapterTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("Deve persistir profissional usando JdbcTemplate")
    void shouldPersistProfessionalUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalRepositoryAdapter adapter = new JdbcProfessionalRepositoryAdapter(jdbcTemplate);
        Professional professional = validProfessional();

        // WHEN
        Professional savedProfessional = adapter.saveProfessional(professional);

        // THEN
        assertThat(savedProfessional).isEqualTo(professional);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(professional.professionalIdentifier()),
                eq(professional.professionalName()),
                eq(professional.whatsappNumber()),
                eq(professional.cityIdentifier()),
                eq(professional.categoryIdentifier()),
                eq(professional.shortDescription()),
                eq(professional.profilePhotoFileIdentifier()),
                eq(professional.documentNumberHash()),
                eq(professional.usefulLink()),
                eq(professional.portfolioDescription()),
                eq(professional.serviceDescription()),
                eq(professional.profileCompletenessPercentage()),
                eq(professional.profileClassification().name()),
                eq(professional.availabilityStatus().name()),
                eq(professional.qualityGuarantee())
        );
    }

    @Test
    @DisplayName("Deve carregar profissional por identificador usando JdbcTemplate")
    void shouldLoadProfessionalByIdentifierUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalRepositoryAdapter adapter = new JdbcProfessionalRepositoryAdapter(jdbcTemplate);
        Professional professional = validProfessional();
        ResultSet resultSet = professionalResultSet(professional);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(professional.professionalIdentifier())))
                .thenAnswer(invocation -> {
                    RowMapper<Professional> rowMapper = invocation.getArgument(1);
                    return List.of(rowMapper.mapRow(resultSet, 0));
                });

        // WHEN
        Optional<Professional> loadedProfessional = adapter.loadProfessionalByIdentifier(professional.professionalIdentifier());

        // THEN
        assertThat(loadedProfessional).contains(professional);
    }

    @Test
    @DisplayName("Deve atualizar perfil progressivo do profissional usando JdbcTemplate")
    void shouldUpdateProgressiveProfessionalProfileUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalRepositoryAdapter adapter = new JdbcProfessionalRepositoryAdapter(jdbcTemplate);
        Professional professional = validProfessional().completeProgressiveProfile(
                UUID.randomUUID(),
                "protected-document-hash",
                "https://worklink.example/maria-eletricista",
                "Portifolio residencial.",
                "Instalacoes eletricas.",
                ProfessionalAvailabilityStatus.AVAILABLE_TODAY
        );

        // WHEN
        Professional updatedProfessional = adapter.updateProfessional(professional);

        // THEN
        assertThat(updatedProfessional).isEqualTo(professional);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(professional.profilePhotoFileIdentifier()),
                eq(professional.documentNumberHash()),
                eq(professional.usefulLink()),
                eq(professional.portfolioDescription()),
                eq(professional.serviceDescription()),
                eq(professional.profileCompletenessPercentage()),
                eq(professional.profileClassification().name()),
                eq(professional.availabilityStatus().name()),
                eq(professional.qualityGuarantee()),
                eq(professional.professionalIdentifier())
        );
    }

    @Test
    @DisplayName("Deve listar profissionais filtrando por cidade e categoria usando JdbcTemplate")
    void shouldListProfessionalsFilteringByCityAndCategoryUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalRepositoryAdapter adapter = new JdbcProfessionalRepositoryAdapter(jdbcTemplate);
        Professional professional = validProfessional();
        ResultSet resultSet = professionalResultSet(professional);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), any(Object[].class))).thenAnswer(invocation -> {
            RowMapper<Professional> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });
        ProfessionalSearchCriteria professionalSearchCriteria = new ProfessionalSearchCriteria(
                Optional.of(CATEGORY_IDENTIFIER),
                Set.of(CITY_IDENTIFIER),
                Optional.empty()
        );

        // WHEN
        List<Professional> professionals = adapter.listProfessionals(professionalSearchCriteria);

        // THEN
        assertThat(professionals).containsExactly(professional);
    }

    @Test
    @DisplayName("Deve listar profissionais filtrando por palavra-chave usando JdbcTemplate")
    void shouldListProfessionalsFilteringByKeywordUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalRepositoryAdapter adapter = new JdbcProfessionalRepositoryAdapter(jdbcTemplate);
        Professional professional = validProfessional();
        ResultSet resultSet = professionalResultSet(professional);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), any(Object[].class))).thenAnswer(invocation -> {
            RowMapper<Professional> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });
        ProfessionalSearchCriteria professionalSearchCriteria = new ProfessionalSearchCriteria(
                Optional.empty(),
                Set.of(),
                Optional.of("residencial")
        );

        // WHEN
        List<Professional> professionals = adapter.listProfessionals(professionalSearchCriteria);

        // THEN
        assertThat(professionals).containsExactly(professional);
    }

    @Test
    @DisplayName("Deve listar profissionais sem filtros usando JdbcTemplate")
    void shouldListProfessionalsWithoutFiltersUsingJdbcTemplate() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalRepositoryAdapter adapter = new JdbcProfessionalRepositoryAdapter(jdbcTemplate);
        Professional professional = validProfessional();
        ResultSet resultSet = professionalResultSet(professional);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), any(Object[].class))).thenAnswer(invocation -> {
            RowMapper<Professional> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        List<Professional> professionals = adapter.listProfessionals(ProfessionalSearchCriteria.withoutFilters());

        // THEN
        assertThat(professionals).containsExactly(professional);
    }

    private Professional validProfessional() {
        return Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
    }

    private ResultSet professionalResultSet(Professional professional) throws Exception {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(professional.professionalIdentifier());
        when(resultSet.getString("professional_name")).thenReturn(professional.professionalName());
        when(resultSet.getString("whatsapp_number")).thenReturn(professional.whatsappNumber());
        when(resultSet.getObject("city_identifier", UUID.class)).thenReturn(professional.cityIdentifier());
        when(resultSet.getObject("category_identifier", UUID.class)).thenReturn(professional.categoryIdentifier());
        when(resultSet.getString("short_description")).thenReturn(professional.shortDescription());
        when(resultSet.getObject("profile_photo_file_identifier", UUID.class)).thenReturn(professional.profilePhotoFileIdentifier());
        when(resultSet.getString("document_number_hash")).thenReturn(professional.documentNumberHash());
        when(resultSet.getString("useful_link")).thenReturn(professional.usefulLink());
        when(resultSet.getString("portfolio_description")).thenReturn(professional.portfolioDescription());
        when(resultSet.getString("service_description")).thenReturn(professional.serviceDescription());
        when(resultSet.getInt("profile_completeness_percentage")).thenReturn(professional.profileCompletenessPercentage());
        when(resultSet.getString("profile_classification")).thenReturn(professional.profileClassification().name());
        when(resultSet.getString("availability_status")).thenReturn(professional.availabilityStatus().name());
        when(resultSet.getBoolean("quality_guarantee")).thenReturn(professional.qualityGuarantee());
        return resultSet;
    }
}
