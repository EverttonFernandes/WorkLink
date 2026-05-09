package br.com.worklink.api;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.api.report.ProfessionalReportController;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.report.usecase.RegisterProfessionalReportRequest;
import br.com.worklink.application.report.usecase.RegisterProfessionalReportResponse;
import br.com.worklink.application.report.usecase.RegisterProfessionalReportUseCase;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.argThat;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ProfessionalReportController.class)
class ProfessionalReportControllerTest {

    private static final String AUTHORIZATION_HEADER = "Bearer access-value";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private RegisterProfessionalReportUseCase registerProfessionalReportUseCase;

    @MockBean
    private RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    @Test
    @DisplayName("GIVEN usuario autenticado WHEN denunciar profissional THEN deve retornar denuncia registrada")
    void shouldRegisterProfessionalReportThroughApi() throws Exception {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID professionalReportIdentifier = UUID.randomUUID();
        UUID evidenceFileIdentifier = UUID.randomUUID();
        AuthenticatedPrincipal authenticatedPrincipal =
                new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER);
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(authenticatedPrincipal);
        when(registerProfessionalReportUseCase.registerProfessionalReport(argThat(request ->
                request.authenticatedPrincipal().equals(authenticatedPrincipal)
                        && request.professionalIdentifier().equals(professionalIdentifier)
                        && request.reportReason().equals("FRAUD")
                        && request.evidenceFileIdentifier().equals(evidenceFileIdentifier)
        ))).thenReturn(new RegisterProfessionalReportResponse(
                professionalReportIdentifier,
                professionalIdentifier,
                authenticatedPrincipal.principalIdentifier(),
                "FRAUD",
                "Perfil falso",
                evidenceFileIdentifier,
                false,
                null,
                Instant.parse("2026-05-09T23:45:00Z")
        ));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/professional-reports")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "professionalIdentifier", professionalIdentifier,
                                "reportReason", "FRAUD",
                                "description", "Perfil falso",
                                "evidenceFileIdentifier", evidenceFileIdentifier
                        ))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.professionalReportIdentifier").value(professionalReportIdentifier.toString()))
                .andExpect(jsonPath("$.professionalIdentifier").value(professionalIdentifier.toString()))
                .andExpect(jsonPath("$.reportReason").value("FRAUD"))
                .andExpect(jsonPath("$.evidenceFileIdentifier").value(evidenceFileIdentifier.toString()))
                .andExpect(jsonPath("$.seriousCase").value(false))
                .andExpect(jsonPath("$.authorityGuidance").doesNotExist());
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(authenticatedPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.REGISTER_PROFESSIONAL_REPORT
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.REPORT
                        && auditRequest.targetIdentifier().equals(professionalReportIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("GIVEN requisicao sem autenticacao WHEN denunciar THEN deve bloquear sem auditoria de sucesso")
    void shouldBlockProfessionalReportWithoutAuthentication() throws Exception {
        // GIVEN
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(null))
                .thenThrow(new AuthenticationRequiredException("Autenticacao obrigatoria para esta acao."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/professional-reports")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "professionalIdentifier", UUID.randomUUID(),
                                "reportReason", "FRAUD"
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Autenticacao obrigatoria para esta acao."));
        verify(registerProfessionalReportUseCase, never())
                .registerProfessionalReport(any(RegisterProfessionalReportRequest.class));
        verify(recordSensitiveAuditEventUseCase, never())
                .recordSensitiveAuditEvent(any(RecordSensitiveAuditEventRequest.class));
    }
}
