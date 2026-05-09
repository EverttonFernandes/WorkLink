package br.com.worklink.application.report.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.report.port.SaveProfessionalReportPort;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.report.ProfessionalReport;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class RegisterProfessionalReportUseCaseTest {

    @Test
    @DisplayName("GIVEN usuario autenticado WHEN denunciar profissional THEN deve registrar para analise")
    void shouldRegisterProfessionalReport() {
        // GIVEN
        LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort = mock(LoadProfessionalByIdentifierPort.class);
        SaveProfessionalReportPort saveProfessionalReportPort = mock(SaveProfessionalReportPort.class);
        CurrentContactTimePort currentContactTimePort = mock(CurrentContactTimePort.class);
        RegisterProfessionalReportUseCase useCase = new RegisterProfessionalReportUseCase(
                loadProfessionalByIdentifierPort,
                saveProfessionalReportPort,
                currentContactTimePort
        );
        UUID professionalIdentifier = UUID.randomUUID();
        UUID reporterIdentifier = UUID.randomUUID();
        UUID evidenceFileIdentifier = UUID.randomUUID();
        when(loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(professionalIdentifier))
                .thenReturn(Optional.of(mock(Professional.class)));
        when(currentContactTimePort.currentInstant()).thenReturn(Instant.parse("2026-05-09T23:30:00Z"));
        when(saveProfessionalReportPort.saveProfessionalReport(any(ProfessionalReport.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        // WHEN
        RegisterProfessionalReportResponse response = useCase.registerProfessionalReport(new RegisterProfessionalReportRequest(
                new AuthenticatedPrincipal(reporterIdentifier, AuthenticatedProfile.CUSTOMER),
                professionalIdentifier,
                "FRAUD",
                "Perfil falso",
                evidenceFileIdentifier
        ));

        // THEN
        assertThat(response.professionalReportIdentifier()).isNotNull();
        assertThat(response.professionalIdentifier()).isEqualTo(professionalIdentifier);
        assertThat(response.reporterIdentifier()).isEqualTo(reporterIdentifier);
        assertThat(response.reportReason()).isEqualTo("FRAUD");
        assertThat(response.description()).isEqualTo("Perfil falso");
        assertThat(response.evidenceFileIdentifier()).isEqualTo(evidenceFileIdentifier);
        assertThat(response.seriousCase()).isFalse();
        verify(saveProfessionalReportPort).saveProfessionalReport(any(ProfessionalReport.class));
    }

    @Test
    @DisplayName("GIVEN denuncia grave WHEN registrar THEN deve retornar orientacao para autoridades")
    void shouldReturnAuthorityGuidanceForSeriousReport() {
        // GIVEN
        LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort = mock(LoadProfessionalByIdentifierPort.class);
        SaveProfessionalReportPort saveProfessionalReportPort = mock(SaveProfessionalReportPort.class);
        CurrentContactTimePort currentContactTimePort = mock(CurrentContactTimePort.class);
        RegisterProfessionalReportUseCase useCase = new RegisterProfessionalReportUseCase(
                loadProfessionalByIdentifierPort,
                saveProfessionalReportPort,
                currentContactTimePort
        );
        UUID professionalIdentifier = UUID.randomUUID();
        when(loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(professionalIdentifier))
                .thenReturn(Optional.of(mock(Professional.class)));
        when(currentContactTimePort.currentInstant()).thenReturn(Instant.parse("2026-05-09T23:30:00Z"));
        when(saveProfessionalReportPort.saveProfessionalReport(any(ProfessionalReport.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        // WHEN
        RegisterProfessionalReportResponse response = useCase.registerProfessionalReport(new RegisterProfessionalReportRequest(
                new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER),
                professionalIdentifier,
                "THREAT",
                "Ameaca relatada",
                null
        ));

        // THEN
        assertThat(response.seriousCase()).isTrue();
        assertThat(response.authorityGuidance()).contains("autoridades competentes");
    }

    @Test
    @DisplayName("GIVEN usuario ausente WHEN denunciar THEN deve bloquear sem persistir")
    void shouldBlockUnauthenticatedProfessionalReport() {
        // GIVEN
        LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort = mock(LoadProfessionalByIdentifierPort.class);
        SaveProfessionalReportPort saveProfessionalReportPort = mock(SaveProfessionalReportPort.class);
        CurrentContactTimePort currentContactTimePort = mock(CurrentContactTimePort.class);
        RegisterProfessionalReportUseCase useCase = new RegisterProfessionalReportUseCase(
                loadProfessionalByIdentifierPort,
                saveProfessionalReportPort,
                currentContactTimePort
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerProfessionalReport(new RegisterProfessionalReportRequest(
                null,
                UUID.randomUUID(),
                "FRAUD",
                "Perfil falso",
                null
        ))).isInstanceOf(AuthenticationRequiredException.class)
                .hasMessage("Autenticacao obrigatoria para denunciar profissional.");
        verify(saveProfessionalReportPort, never()).saveProfessionalReport(any(ProfessionalReport.class));
    }

    @Test
    @DisplayName("GIVEN profissional inexistente WHEN denunciar THEN deve bloquear")
    void shouldBlockReportForUnknownProfessional() {
        // GIVEN
        LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort = mock(LoadProfessionalByIdentifierPort.class);
        SaveProfessionalReportPort saveProfessionalReportPort = mock(SaveProfessionalReportPort.class);
        CurrentContactTimePort currentContactTimePort = mock(CurrentContactTimePort.class);
        RegisterProfessionalReportUseCase useCase = new RegisterProfessionalReportUseCase(
                loadProfessionalByIdentifierPort,
                saveProfessionalReportPort,
                currentContactTimePort
        );
        UUID professionalIdentifier = UUID.randomUUID();
        when(loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(professionalIdentifier))
                .thenReturn(Optional.empty());

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerProfessionalReport(new RegisterProfessionalReportRequest(
                new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER),
                professionalIdentifier,
                "FRAUD",
                "Perfil falso",
                null
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O profissional denunciado nao foi encontrado.");
        verify(saveProfessionalReportPort, never()).saveProfessionalReport(any(ProfessionalReport.class));
    }

    @Test
    @DisplayName("GIVEN motivo invalido WHEN denunciar THEN deve bloquear sem persistir")
    void shouldBlockProfessionalReportWithInvalidReason() {
        // GIVEN
        LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort = mock(LoadProfessionalByIdentifierPort.class);
        SaveProfessionalReportPort saveProfessionalReportPort = mock(SaveProfessionalReportPort.class);
        CurrentContactTimePort currentContactTimePort = mock(CurrentContactTimePort.class);
        RegisterProfessionalReportUseCase useCase = new RegisterProfessionalReportUseCase(
                loadProfessionalByIdentifierPort,
                saveProfessionalReportPort,
                currentContactTimePort
        );
        UUID professionalIdentifier = UUID.randomUUID();
        when(loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(professionalIdentifier))
                .thenReturn(Optional.of(mock(Professional.class)));

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerProfessionalReport(new RegisterProfessionalReportRequest(
                new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER),
                professionalIdentifier,
                "INVALID_REASON",
                "Motivo invalido",
                null
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A denuncia profissional informada e invalida.");
        verify(saveProfessionalReportPort, never()).saveProfessionalReport(any(ProfessionalReport.class));
    }
}
