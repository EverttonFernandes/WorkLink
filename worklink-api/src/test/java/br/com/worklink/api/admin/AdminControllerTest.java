package br.com.worklink.api.admin;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.admin.usecase.AdministrativeMetricsResponse;
import br.com.worklink.application.admin.usecase.AdministrativeProfessionalReportResponse;
import br.com.worklink.application.admin.usecase.AdministrativeProfessionalResponse;
import br.com.worklink.application.admin.usecase.AdministrativeReviewAnalysisRequestResponse;
import br.com.worklink.application.admin.usecase.BlockProfessionalUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeProfessionalReportsUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeProfessionalsUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeReviewAnalysisRequestsUseCase;
import br.com.worklink.application.admin.usecase.LoadAdministrativeMetricsUseCase;
import br.com.worklink.application.admin.usecase.ModerateProfessionalReportUseCase;
import br.com.worklink.application.admin.usecase.ModerateReviewAnalysisRequestUseCase;
import br.com.worklink.application.admin.usecase.UnblockProfessionalUseCase;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.authorization.usecase.AuthorizeSensitiveActionUseCase;
import br.com.worklink.application.authorization.usecase.SensitiveAction;
import br.com.worklink.application.metrics.usecase.ContactMetricResponse;
import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;
import br.com.worklink.application.metrics.usecase.LoadFunctionalMetricsUseCase;
import br.com.worklink.application.metrics.usecase.ReputationMetricResponse;
import br.com.worklink.application.metrics.usecase.ResponsivenessMetricResponse;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.http.MediaType;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AdminController.class)
class AdminControllerTest {

    private static final String AUTHORIZATION_HEADER = "Bearer admin-token";

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;

    @MockBean
    private RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    @MockBean
    private ListAdministrativeProfessionalsUseCase listAdministrativeProfessionalsUseCase;

    @MockBean
    private BlockProfessionalUseCase blockProfessionalUseCase;

    @MockBean
    private UnblockProfessionalUseCase unblockProfessionalUseCase;

    @MockBean
    private ListAdministrativeProfessionalReportsUseCase listAdministrativeProfessionalReportsUseCase;

    @MockBean
    private ListAdministrativeReviewAnalysisRequestsUseCase listAdministrativeReviewAnalysisRequestsUseCase;

    @MockBean
    private ModerateProfessionalReportUseCase moderateProfessionalReportUseCase;

    @MockBean
    private ModerateReviewAnalysisRequestUseCase moderateReviewAnalysisRequestUseCase;

    @MockBean
    private LoadAdministrativeMetricsUseCase loadAdministrativeMetricsUseCase;

    @MockBean
    private LoadFunctionalMetricsUseCase loadFunctionalMetricsUseCase;

    @Test
    @DisplayName("GIVEN administrador WHEN listar profissionais THEN deve retornar status de bloqueio")
    void shouldListAdministrativeProfessionals() throws Exception {
        // GIVEN
        AuthenticatedPrincipal administratorPrincipal = administratorPrincipal();
        UUID professionalIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal);
        when(listAdministrativeProfessionalsUseCase.listAdministrativeProfessionals()).thenReturn(List.of(
                new AdministrativeProfessionalResponse(
                        professionalIdentifier,
                        "Maria Eletricista",
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        "BASIC_PROFILE",
                        "ACCEPTING_NEW_CLIENTS",
                        true
                )
        ));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/admin/professionals").header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].professionalIdentifier").value(professionalIdentifier.toString()))
                .andExpect(jsonPath("$[0].blocked").value(true));
        verify(authorizeSensitiveActionUseCase).authorizeSensitiveAction(
                administratorPrincipal,
                SensitiveAction.ACCESS_ADMINISTRATIVE_DATA
        );
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.sensitiveAuditAction() == SensitiveAuditAction.ACCESS_ADMINISTRATIVE_DATA
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.PROFESSIONAL_PROFILE
        ));
    }

    @Test
    @DisplayName("GIVEN administrador WHEN bloquear profissional THEN deve auditar acao sensivel")
    void shouldBlockProfessionalAndAuditSensitiveAction() throws Exception {
        // GIVEN
        AuthenticatedPrincipal administratorPrincipal = administratorPrincipal();
        UUID professionalIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal);
        when(blockProfessionalUseCase.blockProfessional(professionalIdentifier)).thenReturn(
                new AdministrativeProfessionalResponse(
                        professionalIdentifier,
                        "Maria Eletricista",
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        "BASIC_PROFILE",
                        "ACCEPTING_NEW_CLIENTS",
                        true
                )
        );

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/admin/professionals/{professionalIdentifier}/block", professionalIdentifier)
                        .header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.blocked").value(true));
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(administratorPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.BLOCK_PROFESSIONAL
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.PROFESSIONAL_PROFILE
                        && auditRequest.targetIdentifier().equals(professionalIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("GIVEN administrador WHEN desbloquear profissional THEN deve retornar ativo")
    void shouldUnblockProfessional() throws Exception {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal());
        when(unblockProfessionalUseCase.unblockProfessional(professionalIdentifier)).thenReturn(
                new AdministrativeProfessionalResponse(
                        professionalIdentifier,
                        "Maria Eletricista",
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        "BASIC_PROFILE",
                        "ACCEPTING_NEW_CLIENTS",
                        false
                )
        );

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/admin/professionals/{professionalIdentifier}/unblock", professionalIdentifier)
                        .header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.blocked").value(false));
    }

    @Test
    @DisplayName("GIVEN administrador WHEN listar denuncias THEN deve retornar casos graves")
    void shouldListAdministrativeReports() throws Exception {
        // GIVEN
        UUID reportIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal());
        when(listAdministrativeProfessionalReportsUseCase.listAdministrativeProfessionalReports()).thenReturn(List.of(
                new AdministrativeProfessionalReportResponse(
                        reportIdentifier,
                        UUID.randomUUID(),
                        "THREAT",
                        true,
                        null,
                        "PENDING",
                        null,
                        null,
                        null,
                        Instant.parse("2026-05-09T10:00:00Z")
                )
        ));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/admin/reports").header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].professionalReportIdentifier").value(reportIdentifier.toString()))
                .andExpect(jsonPath("$[0].seriousCase").value(true));
    }

    @Test
    @DisplayName("GIVEN administrador WHEN listar contestacoes THEN deve retornar solicitacoes")
    void shouldListReviewAnalysisRequests() throws Exception {
        // GIVEN
        UUID requestIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal());
        when(listAdministrativeReviewAnalysisRequestsUseCase.listAdministrativeReviewAnalysisRequests()).thenReturn(List.of(
                new AdministrativeReviewAnalysisRequestResponse(
                        requestIdentifier,
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        "PENDING",
                        null,
                        null,
                        null,
                        Instant.parse("2026-05-09T10:00:00Z")
                )
        ));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/admin/review-analysis-requests").header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].reviewAnalysisRequestIdentifier").value(requestIdentifier.toString()));
    }

    @Test
    @DisplayName("GIVEN administrador WHEN moderar denuncia THEN deve auditar decisao")
    void shouldModerateProfessionalReportAndAuditSensitiveAction() throws Exception {
        // GIVEN
        UUID reportIdentifier = UUID.randomUUID();
        AuthenticatedPrincipal administratorPrincipal = administratorPrincipal();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal);
        when(moderateProfessionalReportUseCase.moderateProfessionalReport(any())).thenReturn(
                new AdministrativeProfessionalReportResponse(
                        reportIdentifier,
                        UUID.randomUUID(),
                        "FRAUD",
                        false,
                        null,
                        "RESOLVED",
                        "KEEP_AS_IS",
                        "Caso encerrado",
                        Instant.parse("2026-05-10T09:00:00Z"),
                        Instant.parse("2026-05-09T10:00:00Z")
                )
        );

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/admin/reports/{professionalReportIdentifier}/moderation", reportIdentifier)
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "moderationStatus": "RESOLVED",
                                  "moderationDecision": "KEEP_AS_IS",
                                  "moderationNotes": "Caso encerrado"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.moderationStatus").value("RESOLVED"))
                .andExpect(jsonPath("$.moderationDecision").value("KEEP_AS_IS"));
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(administratorPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.MODERATE_PROFESSIONAL_REPORT
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.REPORT
                        && auditRequest.targetIdentifier().equals(reportIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("GIVEN administrador WHEN moderar contestacao THEN deve auditar decisao")
    void shouldModerateReviewAnalysisRequestAndAuditSensitiveAction() throws Exception {
        // GIVEN
        UUID requestIdentifier = UUID.randomUUID();
        AuthenticatedPrincipal administratorPrincipal = administratorPrincipal();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal);
        when(moderateReviewAnalysisRequestUseCase.moderateReviewAnalysisRequest(any())).thenReturn(
                new AdministrativeReviewAnalysisRequestResponse(
                        requestIdentifier,
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        "ACTION_REQUIRED",
                        "HIDE_FROM_PUBLIC",
                        "Ocultada ate revisao completa",
                        Instant.parse("2026-05-10T11:00:00Z"),
                        Instant.parse("2026-05-09T10:00:00Z")
                )
        );

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/admin/review-analysis-requests/{reviewAnalysisRequestIdentifier}/moderation", requestIdentifier)
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "moderationStatus": "ACTION_REQUIRED",
                                  "moderationDecision": "HIDE_FROM_PUBLIC",
                                  "moderationNotes": "Ocultada ate revisao completa"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.moderationStatus").value("ACTION_REQUIRED"))
                .andExpect(jsonPath("$.moderationDecision").value("HIDE_FROM_PUBLIC"));
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(administratorPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.MODERATE_REVIEW_ANALYSIS_REQUEST
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.REVIEW
                        && auditRequest.targetIdentifier().equals(requestIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("GIVEN administrador WHEN consultar metricas THEN deve retornar contadores")
    void shouldLoadAdministrativeMetrics() throws Exception {
        // GIVEN
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal());
        when(loadAdministrativeMetricsUseCase.loadAdministrativeMetrics())
                .thenReturn(new AdministrativeMetricsResponse(10, 2, 3, 4, 5));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/admin/metrics").header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.professionalCount").value(10))
                .andExpect(jsonPath("$.blockedProfessionalCount").value(2))
                .andExpect(jsonPath("$.professionalReportCount").value(3))
                .andExpect(jsonPath("$.reviewAnalysisRequestCount").value(4))
                .andExpect(jsonPath("$.serviceCategoryCount").value(5));
    }

    @Test
    @DisplayName("GIVEN administrador WHEN consultar metricas funcionais THEN deve retornar sinais para ranking futuro")
    void shouldLoadFunctionalMetricsWithoutRankingAlgorithm() throws Exception {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID categoryIdentifier = UUID.randomUUID();
        UUID cityIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(administratorPrincipal());
        when(loadFunctionalMetricsUseCase.loadFunctionalMetrics()).thenReturn(new FunctionalMetricsResponse(
                7,
                1,
                5,
                4,
                3,
                2,
                1,
                1,
                false,
                List.of(new ContactMetricResponse(categoryIdentifier, 6)),
                List.of(new ContactMetricResponse(cityIdentifier, 5)),
                List.of(new ContactMetricResponse(professionalIdentifier, 5)),
                List.of(new ContactMetricResponse(categoryIdentifier, 4)),
                List.of(new ContactMetricResponse(cityIdentifier, 3)),
                new br.com.worklink.application.metrics.usecase.ProfessionalMetricSummaryResponse(9, 4, 7, 2, 5),
                new br.com.worklink.application.metrics.usecase.ResponsivenessSummaryResponse(80, 20, 60, 75),
                List.of(new ResponsivenessMetricResponse("FAST_RESPONSE", 2)),
                new br.com.worklink.application.metrics.usecase.ReputationSummaryResponse(3, 4.75, 2, 1, 1),
                List.of(new ReputationMetricResponse(professionalIdentifier, 4.75, 3))
        ));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/admin/functional-metrics").header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.searchCount").value(7))
                .andExpect(jsonPath("$.searchWithoutResultCount").value(1))
                .andExpect(jsonPath("$.contactCount").value(5))
                .andExpect(jsonPath("$.postContactFeedbackCount").value(4))
                .andExpect(jsonPath("$.reviewCount").value(3))
                .andExpect(jsonPath("$.anonymousReviewCount").value(2))
                .andExpect(jsonPath("$.professionalReportCount").value(1))
                .andExpect(jsonPath("$.reviewAnalysisRequestCount").value(1))
                .andExpect(jsonPath("$.rankingAlgorithmEnabled").value(false))
                .andExpect(jsonPath("$.searchesByCategory[0].metricIdentifier").value(categoryIdentifier.toString()))
                .andExpect(jsonPath("$.searchesByCity[0].metricIdentifier").value(cityIdentifier.toString()))
                .andExpect(jsonPath("$.contactsByProfessional[0].metricIdentifier").value(professionalIdentifier.toString()))
                .andExpect(jsonPath("$.contactsByCategory[0].metricIdentifier").value(categoryIdentifier.toString()))
                .andExpect(jsonPath("$.contactsByCity[0].metricIdentifier").value(cityIdentifier.toString()))
                .andExpect(jsonPath("$.professionalSummary.activeProfessionalCount").value(9))
                .andExpect(jsonPath("$.responsivenessSummary.postContactAnswerRatePercentage").value(75.0))
                .andExpect(jsonPath("$.responsivenessSignals[0].contactResponsiveness").value("FAST_RESPONSE"))
                .andExpect(jsonPath("$.reputationSummary.averageRating").value(4.75))
                .andExpect(jsonPath("$.reputationSignals[0].averageRating").value(4.75));
    }


    @Test
    @DisplayName("GIVEN cliente WHEN acessar admin THEN deve negar sem executar caso de uso")
    void shouldDenyCustomerAccessToAdministrativeEndpoints() throws Exception {
        // GIVEN
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.CUSTOMER
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(customerPrincipal);
        doThrow(new AuthorizationDeniedException("Acesso negado para este recurso."))
                .when(authorizeSensitiveActionUseCase)
                .authorizeSensitiveAction(customerPrincipal, SensitiveAction.ACCESS_ADMINISTRATIVE_DATA);

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/admin/professionals").header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Acesso negado para este recurso."));
        verify(listAdministrativeProfessionalsUseCase, never()).listAdministrativeProfessionals();
        verify(recordSensitiveAuditEventUseCase, never()).recordSensitiveAuditEvent(any(RecordSensitiveAuditEventRequest.class));
    }

    private AuthenticatedPrincipal administratorPrincipal() {
        return new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.ADMINISTRATOR);
    }
}
