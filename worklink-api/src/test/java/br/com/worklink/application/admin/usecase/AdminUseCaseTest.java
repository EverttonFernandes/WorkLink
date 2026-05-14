package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.admin.port.ListAdministrativeProfessionalReportsPort;
import br.com.worklink.application.admin.port.ListAdministrativeProfessionalsPort;
import br.com.worklink.application.admin.port.ListAdministrativeReviewAnalysisRequestsPort;
import br.com.worklink.application.admin.port.LoadAdministrativeMetricsPort;
import br.com.worklink.application.admin.port.ModerateProfessionalReportPort;
import br.com.worklink.application.admin.port.ModerateReviewAnalysisRequestPort;
import br.com.worklink.application.review.port.UpdateProfessionalReviewVisibilityPort;
import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.report.ProfessionalReport;
import br.com.worklink.domain.report.ProfessionalReportReason;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AdminUseCaseTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("GIVEN profissionais cadastrados WHEN listar admin THEN deve exibir status de bloqueio")
    void shouldListAdministrativeProfessionalsWithBlockedStatus() {
        // GIVEN
        ListAdministrativeProfessionalsPort port = mock(ListAdministrativeProfessionalsPort.class);
        when(port.listAdministrativeProfessionals()).thenReturn(List.of(validProfessional().blockProfessional()));
        ListAdministrativeProfessionalsUseCase useCase = new ListAdministrativeProfessionalsUseCase(port);

        // WHEN
        List<AdministrativeProfessionalResponse> professionals = useCase.listAdministrativeProfessionals();

        // THEN
        assertThat(professionals).hasSize(1);
        assertThat(professionals.getFirst().blocked()).isTrue();
        assertThat(professionals.getFirst().professionalName()).isEqualTo("Maria Eletricista");
    }

    @Test
    @DisplayName("GIVEN profissional existente WHEN bloquear THEN deve retornar profissional bloqueado")
    void shouldBlockExistingProfessional() {
        // GIVEN
        Professional professional = validProfessional();
        LoadProfessionalByIdentifierPort loadPort = mock(LoadProfessionalByIdentifierPort.class);
        UpdateProfessionalPort updatePort = mock(UpdateProfessionalPort.class);
        when(loadPort.loadProfessionalByIdentifier(professional.professionalIdentifier()))
                .thenReturn(Optional.of(professional));
        when(updatePort.updateProfessional(any(Professional.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        BlockProfessionalUseCase useCase = new BlockProfessionalUseCase(loadPort, updatePort);

        // WHEN
        AdministrativeProfessionalResponse response = useCase.blockProfessional(professional.professionalIdentifier());

        // THEN
        assertThat(response.blocked()).isTrue();
    }

    @Test
    @DisplayName("GIVEN profissional existente WHEN desbloquear THEN deve retornar profissional ativo")
    void shouldUnblockExistingProfessional() {
        // GIVEN
        Professional blockedProfessional = validProfessional().blockProfessional();
        LoadProfessionalByIdentifierPort loadPort = mock(LoadProfessionalByIdentifierPort.class);
        UpdateProfessionalPort updatePort = mock(UpdateProfessionalPort.class);
        when(loadPort.loadProfessionalByIdentifier(blockedProfessional.professionalIdentifier()))
                .thenReturn(Optional.of(blockedProfessional));
        when(updatePort.updateProfessional(any(Professional.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));
        UnblockProfessionalUseCase useCase = new UnblockProfessionalUseCase(loadPort, updatePort);

        // WHEN
        AdministrativeProfessionalResponse response = useCase.unblockProfessional(blockedProfessional.professionalIdentifier());

        // THEN
        assertThat(response.blocked()).isFalse();
    }

    @Test
    @DisplayName("GIVEN profissional inexistente WHEN bloquear THEN deve informar recurso ausente")
    void shouldRejectBlockWhenProfessionalDoesNotExist() {
        // GIVEN
        LoadProfessionalByIdentifierPort loadPort = mock(LoadProfessionalByIdentifierPort.class);
        UpdateProfessionalPort updatePort = mock(UpdateProfessionalPort.class);
        UUID professionalIdentifier = UUID.randomUUID();
        when(loadPort.loadProfessionalByIdentifier(professionalIdentifier)).thenReturn(Optional.empty());
        BlockProfessionalUseCase useCase = new BlockProfessionalUseCase(loadPort, updatePort);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.blockProfessional(professionalIdentifier))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Profissional nao encontrado.");
    }

    @Test
    @DisplayName("GIVEN denuncia registrada WHEN listar admin THEN deve expor motivo e gravidade")
    void shouldListAdministrativeReports() {
        // GIVEN
        ListAdministrativeProfessionalReportsPort port = mock(ListAdministrativeProfessionalReportsPort.class);
        ProfessionalReport professionalReport = ProfessionalReport.registerProfessionalReport(
                UUID.randomUUID(),
                UUID.randomUUID(),
                ProfessionalReportReason.THREAT,
                "Ameaca",
                null,
                Instant.parse("2026-05-09T10:00:00Z")
        );
        when(port.listAdministrativeProfessionalReports()).thenReturn(List.of(professionalReport));

        // WHEN
        List<AdministrativeProfessionalReportResponse> reports =
                new ListAdministrativeProfessionalReportsUseCase(port).listAdministrativeProfessionalReports();

        // THEN
        assertThat(reports).hasSize(1);
        assertThat(reports.getFirst().reportReason()).isEqualTo("THREAT");
        assertThat(reports.getFirst().seriousCase()).isTrue();
        assertThat(reports.getFirst().moderationStatus()).isEqualTo("PENDING");
    }

    @Test
    @DisplayName("GIVEN contestacao registrada WHEN listar admin THEN deve expor solicitacao")
    void shouldListReviewAnalysisRequests() {
        // GIVEN
        ListAdministrativeReviewAnalysisRequestsPort port = mock(ListAdministrativeReviewAnalysisRequestsPort.class);
        ProfessionalReviewAnalysisRequest request = ProfessionalReviewAnalysisRequest.requestProfessionalReviewAnalysis(
                UUID.randomUUID(),
                UUID.randomUUID(),
                UUID.randomUUID(),
                "Comentario indevido",
                Instant.parse("2026-05-09T10:00:00Z")
        );
        when(port.listAdministrativeReviewAnalysisRequests()).thenReturn(List.of(request));

        // WHEN
        List<AdministrativeReviewAnalysisRequestResponse> requests =
                new ListAdministrativeReviewAnalysisRequestsUseCase(port).listAdministrativeReviewAnalysisRequests();

        // THEN
        assertThat(requests).hasSize(1);
        assertThat(requests.getFirst().professionalIdentifier()).isEqualTo(request.professionalIdentifier());
        assertThat(requests.getFirst().moderationStatus()).isEqualTo("PENDING");
    }

    @Test
    @DisplayName("GIVEN denuncia existente WHEN moderar THEN deve persistir status e decisao")
    void shouldModerateProfessionalReport() {
        // GIVEN
        UUID reportIdentifier = UUID.randomUUID();
        ModerateProfessionalReportPort port = mock(ModerateProfessionalReportPort.class);
        ProfessionalReport moderatedReport = ProfessionalReport.restoreProfessionalReport(
                reportIdentifier,
                UUID.randomUUID(),
                UUID.randomUUID(),
                ProfessionalReportReason.FRAUD,
                "Perfil falso",
                null,
                false,
                null,
                ModerationStatus.RESOLVED,
                ModerationDecision.KEEP_AS_IS,
                "Caso encerrado",
                Instant.parse("2026-05-10T09:00:00Z"),
                Instant.parse("2026-05-09T10:00:00Z")
        );
        when(port.moderateProfessionalReport(
                eq(reportIdentifier),
                eq(ModerationStatus.RESOLVED),
                eq(ModerationDecision.KEEP_AS_IS),
                eq("Caso encerrado"),
                eq(Instant.parse("2026-05-10T09:00:00Z"))
        )).thenReturn(Optional.of(moderatedReport));
        ModerateProfessionalReportUseCase useCase = new ModerateProfessionalReportUseCase(
                port,
                () -> Instant.parse("2026-05-10T09:00:00Z")
        );

        // WHEN
        AdministrativeProfessionalReportResponse response = useCase.moderateProfessionalReport(
                new ModerateProfessionalReportRequest(
                        reportIdentifier,
                        "RESOLVED",
                        "KEEP_AS_IS",
                        "Caso encerrado"
                )
        );

        // THEN
        assertThat(response.professionalReportIdentifier()).isEqualTo(reportIdentifier);
        assertThat(response.moderationStatus()).isEqualTo("RESOLVED");
        assertThat(response.moderationDecision()).isEqualTo("KEEP_AS_IS");
    }

    @Test
    @DisplayName("GIVEN contestacao existente WHEN ocultar avaliacao THEN deve atualizar visibilidade publica")
    void shouldModerateReviewAnalysisRequestAndHideReviewFromPublic() {
        // GIVEN
        UUID requestIdentifier = UUID.randomUUID();
        UUID reviewIdentifier = UUID.randomUUID();
        ModerateReviewAnalysisRequestPort port = mock(ModerateReviewAnalysisRequestPort.class);
        UpdateProfessionalReviewVisibilityPort updateProfessionalReviewVisibilityPort =
                mock(UpdateProfessionalReviewVisibilityPort.class);
        ProfessionalReviewAnalysisRequest moderatedRequest =
                ProfessionalReviewAnalysisRequest.restoreProfessionalReviewAnalysisRequest(
                        requestIdentifier,
                        reviewIdentifier,
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        "Comentario abusivo",
                        ModerationStatus.ACTION_REQUIRED,
                        ModerationDecision.HIDE_FROM_PUBLIC,
                        "Ocultada ate revisao completa",
                        Instant.parse("2026-05-10T11:00:00Z"),
                        Instant.parse("2026-05-09T10:00:00Z")
                );
        when(port.moderateReviewAnalysisRequest(
                eq(requestIdentifier),
                eq(ModerationStatus.ACTION_REQUIRED),
                eq(ModerationDecision.HIDE_FROM_PUBLIC),
                eq("Ocultada ate revisao completa"),
                eq(Instant.parse("2026-05-10T11:00:00Z"))
        )).thenReturn(Optional.of(moderatedRequest));
        ModerateReviewAnalysisRequestUseCase useCase = new ModerateReviewAnalysisRequestUseCase(
                port,
                updateProfessionalReviewVisibilityPort,
                () -> Instant.parse("2026-05-10T11:00:00Z")
        );

        // WHEN
        AdministrativeReviewAnalysisRequestResponse response = useCase.moderateReviewAnalysisRequest(
                new ModerateReviewAnalysisRequest(
                        requestIdentifier,
                        "ACTION_REQUIRED",
                        "HIDE_FROM_PUBLIC",
                        "Ocultada ate revisao completa"
                )
        );

        // THEN
        assertThat(response.reviewAnalysisRequestIdentifier()).isEqualTo(requestIdentifier);
        assertThat(response.moderationDecision()).isEqualTo("HIDE_FROM_PUBLIC");
        verify(updateProfessionalReviewVisibilityPort).updateProfessionalReviewVisibility(reviewIdentifier, true);
    }

    @Test
    @DisplayName("GIVEN status invalido WHEN moderar denuncia THEN deve rejeitar")
    void shouldRejectProfessionalReportModerationWithInvalidStatus() {
        // GIVEN
        ModerateProfessionalReportPort port = mock(ModerateProfessionalReportPort.class);
        ModerateProfessionalReportUseCase useCase = new ModerateProfessionalReportUseCase(
                port,
                Instant::now
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.moderateProfessionalReport(
                new ModerateProfessionalReportRequest(
                        UUID.randomUUID(),
                        "PENDING",
                        "KEEP_AS_IS",
                        null
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O status de moderacao informado e invalido.");
    }

    @Test
    @DisplayName("GIVEN decisao invalida WHEN moderar denuncia THEN deve rejeitar")
    void shouldRejectProfessionalReportModerationWithInvalidDecision() {
        // GIVEN
        ModerateProfessionalReportPort port = mock(ModerateProfessionalReportPort.class);
        ModerateProfessionalReportUseCase useCase = new ModerateProfessionalReportUseCase(
                port,
                Instant::now
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.moderateProfessionalReport(
                new ModerateProfessionalReportRequest(
                        UUID.randomUUID(),
                        "RESOLVED",
                        "INVALID_DECISION",
                        null
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A decisao de moderacao informada e invalida.");
    }

    @Test
    @DisplayName("GIVEN denuncia ausente WHEN moderar THEN deve informar recurso nao encontrado")
    void shouldRejectProfessionalReportModerationWhenReportDoesNotExist() {
        // GIVEN
        ModerateProfessionalReportPort port = mock(ModerateProfessionalReportPort.class);
        UUID reportIdentifier = UUID.randomUUID();
        when(port.moderateProfessionalReport(
                eq(reportIdentifier),
                eq(ModerationStatus.IN_REVIEW),
                eq((ModerationDecision) null),
                eq((String) null),
                any(Instant.class)
        )).thenReturn(Optional.empty());
        ModerateProfessionalReportUseCase useCase = new ModerateProfessionalReportUseCase(
                port,
                Instant::now
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.moderateProfessionalReport(
                new ModerateProfessionalReportRequest(
                        reportIdentifier,
                        "IN_REVIEW",
                        null,
                        null
                )
        ))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Denuncia profissional nao encontrada.");
    }

    @Test
    @DisplayName("GIVEN contestacao sem decisao WHEN moderar THEN deve rejeitar")
    void shouldRejectReviewAnalysisModerationWithoutDecision() {
        // GIVEN
        ModerateReviewAnalysisRequestPort port = mock(ModerateReviewAnalysisRequestPort.class);
        UpdateProfessionalReviewVisibilityPort updateProfessionalReviewVisibilityPort =
                mock(UpdateProfessionalReviewVisibilityPort.class);
        ModerateReviewAnalysisRequestUseCase useCase = new ModerateReviewAnalysisRequestUseCase(
                port,
                updateProfessionalReviewVisibilityPort,
                Instant::now
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.moderateReviewAnalysisRequest(
                new ModerateReviewAnalysisRequest(
                        UUID.randomUUID(),
                        "RESOLVED",
                        null,
                        null
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A decisao de moderacao da avaliacao e obrigatoria.");
    }

    @Test
    @DisplayName("GIVEN contestacao mantida WHEN moderar THEN deve manter avaliacao publica")
    void shouldKeepReviewVisibleWhenDecisionDoesNotHideFromPublic() {
        // GIVEN
        UUID requestIdentifier = UUID.randomUUID();
        UUID reviewIdentifier = UUID.randomUUID();
        ModerateReviewAnalysisRequestPort port = mock(ModerateReviewAnalysisRequestPort.class);
        UpdateProfessionalReviewVisibilityPort updateProfessionalReviewVisibilityPort =
                mock(UpdateProfessionalReviewVisibilityPort.class);
        ProfessionalReviewAnalysisRequest moderatedRequest =
                ProfessionalReviewAnalysisRequest.restoreProfessionalReviewAnalysisRequest(
                        requestIdentifier,
                        reviewIdentifier,
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        "Contestacao encerrada",
                        ModerationStatus.RESOLVED,
                        ModerationDecision.KEEP_AS_IS,
                        null,
                        Instant.parse("2026-05-10T11:00:00Z"),
                        Instant.parse("2026-05-09T10:00:00Z")
                );
        when(port.moderateReviewAnalysisRequest(
                eq(requestIdentifier),
                eq(ModerationStatus.RESOLVED),
                eq(ModerationDecision.KEEP_AS_IS),
                eq((String) null),
                eq(Instant.parse("2026-05-10T11:00:00Z"))
        )).thenReturn(Optional.of(moderatedRequest));
        ModerateReviewAnalysisRequestUseCase useCase = new ModerateReviewAnalysisRequestUseCase(
                port,
                updateProfessionalReviewVisibilityPort,
                () -> Instant.parse("2026-05-10T11:00:00Z")
        );

        // WHEN
        AdministrativeReviewAnalysisRequestResponse response = useCase.moderateReviewAnalysisRequest(
                new ModerateReviewAnalysisRequest(
                        requestIdentifier,
                        "RESOLVED",
                        "KEEP_AS_IS",
                        null
                )
        );

        // THEN
        assertThat(response.moderationStatus()).isEqualTo("RESOLVED");
        verify(updateProfessionalReviewVisibilityPort).updateProfessionalReviewVisibility(reviewIdentifier, false);
    }

    @Test
    @DisplayName("GIVEN contestacao ausente WHEN moderar THEN deve informar recurso nao encontrado")
    void shouldRejectReviewAnalysisModerationWhenRequestDoesNotExist() {
        // GIVEN
        ModerateReviewAnalysisRequestPort port = mock(ModerateReviewAnalysisRequestPort.class);
        UpdateProfessionalReviewVisibilityPort updateProfessionalReviewVisibilityPort =
                mock(UpdateProfessionalReviewVisibilityPort.class);
        UUID requestIdentifier = UUID.randomUUID();
        when(port.moderateReviewAnalysisRequest(
                eq(requestIdentifier),
                eq(ModerationStatus.IN_REVIEW),
                eq(ModerationDecision.KEEP_AS_IS),
                eq((String) null),
                any(Instant.class)
        )).thenReturn(Optional.empty());
        ModerateReviewAnalysisRequestUseCase useCase = new ModerateReviewAnalysisRequestUseCase(
                port,
                updateProfessionalReviewVisibilityPort,
                Instant::now
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.moderateReviewAnalysisRequest(
                new ModerateReviewAnalysisRequest(
                        requestIdentifier,
                        "IN_REVIEW",
                        "KEEP_AS_IS",
                        null
                )
        ))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Contestacao de avaliacao nao encontrada.");
    }

    @Test
    @DisplayName("GIVEN dados operacionais WHEN carregar metricas THEN deve consolidar contadores")
    void shouldLoadAdministrativeMetrics() {
        // GIVEN
        LoadAdministrativeMetricsPort port = mock(LoadAdministrativeMetricsPort.class);
        when(port.countProfessionals()).thenReturn(10L);
        when(port.countBlockedProfessionals()).thenReturn(2L);
        when(port.countProfessionalReports()).thenReturn(3L);
        when(port.countReviewAnalysisRequests()).thenReturn(4L);
        when(port.countServiceCategories()).thenReturn(5L);

        // WHEN
        AdministrativeMetricsResponse response = new LoadAdministrativeMetricsUseCase(port).loadAdministrativeMetrics();

        // THEN
        assertThat(response.professionalCount()).isEqualTo(10L);
        assertThat(response.blockedProfessionalCount()).isEqualTo(2L);
        assertThat(response.professionalReportCount()).isEqualTo(3L);
        assertThat(response.reviewAnalysisRequestCount()).isEqualTo(4L);
        assertThat(response.serviceCategoryCount()).isEqualTo(5L);
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
}
