package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.admin.port.ListAdministrativeProfessionalReportsPort;
import br.com.worklink.application.admin.port.ListAdministrativeProfessionalsPort;
import br.com.worklink.application.admin.port.ListAdministrativeReviewAnalysisRequestsPort;
import br.com.worklink.application.admin.port.LoadAdministrativeMetricsPort;
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
import static org.mockito.Mockito.mock;
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
