package br.com.worklink.infrastructure.admin;

import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;
import br.com.worklink.domain.report.ProfessionalReport;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class JdbcAdministrativeRepositoryAdapterTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("GIVEN dados administrativos WHEN listar profissionais THEN deve mapear bloqueio")
    void shouldListAdministrativeProfessionals() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAdministrativeRepositoryAdapter adapter = new JdbcAdministrativeRepositoryAdapter(jdbcTemplate);
        Professional professional = validProfessional().blockProfessional();
        ResultSet resultSet = professionalResultSet(professional);
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class))).thenAnswer(invocation -> {
            RowMapper<Professional> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        List<Professional> professionals = adapter.listAdministrativeProfessionals();

        // THEN
        assertThat(professionals).containsExactly(professional);
        assertThat(professionals.getFirst().blocked()).isTrue();
    }

    @Test
    @DisplayName("GIVEN denuncias WHEN listar admin THEN deve mapear motivo e gravidade")
    void shouldListAdministrativeProfessionalReports() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAdministrativeRepositoryAdapter adapter = new JdbcAdministrativeRepositoryAdapter(jdbcTemplate);
        UUID reportIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("professional_report_identifier", UUID.class)).thenReturn(reportIdentifier);
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(professionalIdentifier);
        when(resultSet.getObject("reporter_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getString("report_reason")).thenReturn("THREAT");
        when(resultSet.getString("description")).thenReturn("Ameaca");
        when(resultSet.getObject("evidence_file_identifier", UUID.class)).thenReturn(null);
        when(resultSet.getBoolean("serious_case")).thenReturn(true);
        when(resultSet.getString("authority_guidance")).thenReturn("Procure autoridades.");
        when(resultSet.getString("moderation_status")).thenReturn("PENDING");
        when(resultSet.getString("moderation_decision")).thenReturn(null);
        when(resultSet.getString("moderation_notes")).thenReturn(null);
        when(resultSet.getTimestamp("decided_at")).thenReturn(null);
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(Instant.parse("2026-05-09T10:00:00Z")));
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class))).thenAnswer(invocation -> {
            RowMapper<ProfessionalReport> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        List<ProfessionalReport> reports = adapter.listAdministrativeProfessionalReports();

        // THEN
        assertThat(reports).hasSize(1);
        assertThat(reports.getFirst().professionalReportIdentifier()).isEqualTo(reportIdentifier);
        assertThat(reports.getFirst().seriousCase()).isTrue();
        assertThat(reports.getFirst().moderationStatus()).isEqualTo(ModerationStatus.PENDING);
    }

    @Test
    @DisplayName("GIVEN contestacoes WHEN listar admin THEN deve mapear solicitacoes")
    void shouldListAdministrativeReviewAnalysisRequests() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAdministrativeRepositoryAdapter adapter = new JdbcAdministrativeRepositoryAdapter(jdbcTemplate);
        UUID requestIdentifier = UUID.randomUUID();
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("review_analysis_request_identifier", UUID.class)).thenReturn(requestIdentifier);
        when(resultSet.getObject("professional_review_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getObject("requested_by_professional_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getString("reason")).thenReturn("Comentario indevido");
        when(resultSet.getString("moderation_status")).thenReturn("PENDING");
        when(resultSet.getString("moderation_decision")).thenReturn(null);
        when(resultSet.getString("moderation_notes")).thenReturn(null);
        when(resultSet.getTimestamp("decided_at")).thenReturn(null);
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(Instant.parse("2026-05-09T10:00:00Z")));
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class))).thenAnswer(invocation -> {
            RowMapper<ProfessionalReviewAnalysisRequest> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        List<ProfessionalReviewAnalysisRequest> requests = adapter.listAdministrativeReviewAnalysisRequests();

        // THEN
        assertThat(requests).hasSize(1);
        assertThat(requests.getFirst().reviewAnalysisRequestIdentifier()).isEqualTo(requestIdentifier);
        assertThat(requests.getFirst().moderationStatus()).isEqualTo(ModerationStatus.PENDING);
    }

    @Test
    @DisplayName("GIVEN denuncia existente WHEN moderar THEN deve retornar denuncia atualizada")
    void shouldModerateProfessionalReport() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAdministrativeRepositoryAdapter adapter = new JdbcAdministrativeRepositoryAdapter(jdbcTemplate);
        UUID reportIdentifier = UUID.randomUUID();
        ResultSet resultSet = mock(ResultSet.class);
        when(jdbcTemplate.update(any(String.class), any(), any(), any(), any(), eq(reportIdentifier))).thenReturn(1);
        when(resultSet.getObject("professional_report_identifier", UUID.class)).thenReturn(reportIdentifier);
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getObject("reporter_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getString("report_reason")).thenReturn("FRAUD");
        when(resultSet.getString("description")).thenReturn("Perfil falso");
        when(resultSet.getObject("evidence_file_identifier", UUID.class)).thenReturn(null);
        when(resultSet.getBoolean("serious_case")).thenReturn(false);
        when(resultSet.getString("authority_guidance")).thenReturn(null);
        when(resultSet.getString("moderation_status")).thenReturn("RESOLVED");
        when(resultSet.getString("moderation_decision")).thenReturn("KEEP_AS_IS");
        when(resultSet.getString("moderation_notes")).thenReturn("Caso encerrado");
        when(resultSet.getTimestamp("decided_at")).thenReturn(Timestamp.from(Instant.parse("2026-05-10T09:00:00Z")));
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(Instant.parse("2026-05-09T10:00:00Z")));
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(reportIdentifier))).thenAnswer(invocation -> {
            RowMapper<ProfessionalReport> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        Optional<ProfessionalReport> report = adapter.moderateProfessionalReport(
                reportIdentifier,
                ModerationStatus.RESOLVED,
                ModerationDecision.KEEP_AS_IS,
                "Caso encerrado",
                Instant.parse("2026-05-10T09:00:00Z")
        );

        // THEN
        assertThat(report).isPresent();
        assertThat(report.orElseThrow().moderationStatus()).isEqualTo(ModerationStatus.RESOLVED);
        assertThat(report.orElseThrow().moderationDecision()).isEqualTo(ModerationDecision.KEEP_AS_IS);
    }

    @Test
    @DisplayName("GIVEN contestacao existente WHEN moderar THEN deve retornar solicitacao atualizada")
    void shouldModerateReviewAnalysisRequest() throws Exception {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAdministrativeRepositoryAdapter adapter = new JdbcAdministrativeRepositoryAdapter(jdbcTemplate);
        UUID requestIdentifier = UUID.randomUUID();
        ResultSet resultSet = mock(ResultSet.class);
        when(jdbcTemplate.update(any(String.class), any(), any(), any(), any(), eq(requestIdentifier))).thenReturn(1);
        when(resultSet.getObject("review_analysis_request_identifier", UUID.class)).thenReturn(requestIdentifier);
        when(resultSet.getObject("professional_review_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getObject("professional_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getObject("requested_by_professional_identifier", UUID.class)).thenReturn(UUID.randomUUID());
        when(resultSet.getString("reason")).thenReturn("Comentario indevido");
        when(resultSet.getString("moderation_status")).thenReturn("ACTION_REQUIRED");
        when(resultSet.getString("moderation_decision")).thenReturn("HIDE_FROM_PUBLIC");
        when(resultSet.getString("moderation_notes")).thenReturn("Ocultada");
        when(resultSet.getTimestamp("decided_at")).thenReturn(Timestamp.from(Instant.parse("2026-05-10T11:00:00Z")));
        when(resultSet.getTimestamp("created_at")).thenReturn(Timestamp.from(Instant.parse("2026-05-09T10:00:00Z")));
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(requestIdentifier))).thenAnswer(invocation -> {
            RowMapper<ProfessionalReviewAnalysisRequest> rowMapper = invocation.getArgument(1);
            return List.of(rowMapper.mapRow(resultSet, 0));
        });

        // WHEN
        Optional<ProfessionalReviewAnalysisRequest> request = adapter.moderateReviewAnalysisRequest(
                requestIdentifier,
                ModerationStatus.ACTION_REQUIRED,
                ModerationDecision.HIDE_FROM_PUBLIC,
                "Ocultada",
                Instant.parse("2026-05-10T11:00:00Z")
        );

        // THEN
        assertThat(request).isPresent();
        assertThat(request.orElseThrow().moderationDecision()).isEqualTo(ModerationDecision.HIDE_FROM_PUBLIC);
    }

    @Test
    @DisplayName("GIVEN dados administrativos WHEN contar metricas THEN deve consultar contadores")
    void shouldCountAdministrativeMetrics() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAdministrativeRepositoryAdapter adapter = new JdbcAdministrativeRepositoryAdapter(jdbcTemplate);
        when(jdbcTemplate.queryForObject(any(String.class), org.mockito.ArgumentMatchers.eq(Long.class))).thenReturn(7L);

        // WHEN / THEN
        assertThat(adapter.countProfessionals()).isEqualTo(7L);
        assertThat(adapter.countBlockedProfessionals()).isEqualTo(7L);
        assertThat(adapter.countProfessionalReports()).isEqualTo(7L);
        assertThat(adapter.countReviewAnalysisRequests()).isEqualTo(7L);
        assertThat(adapter.countServiceCategories()).isEqualTo(7L);
    }

    @Test
    @DisplayName("GIVEN contador nulo WHEN contar metricas THEN deve retornar zero")
    void shouldReturnZeroWhenCounterIsNull() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcAdministrativeRepositoryAdapter adapter = new JdbcAdministrativeRepositoryAdapter(jdbcTemplate);
        when(jdbcTemplate.queryForObject(any(String.class), org.mockito.ArgumentMatchers.eq(Long.class))).thenReturn(null);

        // WHEN / THEN
        assertThat(adapter.countProfessionals()).isZero();
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
        when(resultSet.getBoolean("blocked")).thenReturn(professional.blocked());
        return resultSet;
    }
}
