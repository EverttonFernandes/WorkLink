package br.com.worklink.api;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.api.contact.PostContactFeedbackController;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.contact.usecase.RegisterPostContactFeedbackRequest;
import br.com.worklink.application.contact.usecase.RegisterPostContactFeedbackResponse;
import br.com.worklink.application.contact.usecase.RegisterPostContactFeedbackUseCase;

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

@WebMvcTest(PostContactFeedbackController.class)
class PostContactFeedbackControllerTest {

    private static final String AUTHORIZATION_HEADER = "Bearer access-value";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private RegisterPostContactFeedbackUseCase registerPostContactFeedbackUseCase;

    @MockBean
    private RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    @Test
    @DisplayName("Deve registrar feedback pos-contato autenticado pela API")
    void shouldRegisterAuthenticatedPostContactFeedbackThroughApi() throws Exception {
        // GIVEN
        UUID contactIntentIdentifier = UUID.randomUUID();
        UUID postContactFeedbackIdentifier = UUID.randomUUID();
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER);
        RegisterPostContactFeedbackResponse response = new RegisterPostContactFeedbackResponse(
                postContactFeedbackIdentifier,
                contactIntentIdentifier,
                "CUSTOMER_REACHED_PROFESSIONAL",
                "FAST_RESPONSE",
                "SERVICE_PERFORMED",
                Instant.parse("2026-05-09T12:00:00Z")
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(customerPrincipal);
        when(registerPostContactFeedbackUseCase.registerPostContactFeedback(argThat(request ->
                request.authenticatedPrincipal().equals(customerPrincipal)
                        && request.contactIntentIdentifier().equals(contactIntentIdentifier)
        ))).thenReturn(response);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/post-contact-feedbacks")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "contactIntentIdentifier", contactIntentIdentifier,
                                "conversationOutcome", "CUSTOMER_REACHED_PROFESSIONAL",
                                "contactResponsiveness", "FAST_RESPONSE",
                                "serviceExecutionOutcome", "SERVICE_PERFORMED"
                        ))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.postContactFeedbackIdentifier").value(postContactFeedbackIdentifier.toString()))
                .andExpect(jsonPath("$.contactIntentIdentifier").value(contactIntentIdentifier.toString()))
                .andExpect(jsonPath("$.conversationOutcome").value("CUSTOMER_REACHED_PROFESSIONAL"))
                .andExpect(jsonPath("$.contactResponsiveness").value("FAST_RESPONSE"))
                .andExpect(jsonPath("$.serviceExecutionOutcome").value("SERVICE_PERFORMED"));
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(customerPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.REGISTER_POST_CONTACT_FEEDBACK
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.CONTACT_INTENTION
                        && auditRequest.targetIdentifier().equals(contactIntentIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("Deve bloquear feedback pos-contato sem autenticacao")
    void shouldBlockPostContactFeedbackWithoutAuthentication() throws Exception {
        // GIVEN
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(null))
                .thenThrow(new AuthenticationRequiredException("Autenticacao obrigatoria para esta acao."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/post-contact-feedbacks")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "contactIntentIdentifier", UUID.randomUUID(),
                                "conversationOutcome", "CUSTOMER_DID_NOT_REACH_PROFESSIONAL",
                                "contactResponsiveness", "NO_RESPONSE",
                                "serviceExecutionOutcome", "SERVICE_NOT_PERFORMED"
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Autenticacao obrigatoria para esta acao."));
        verify(registerPostContactFeedbackUseCase, never()).registerPostContactFeedback(any(RegisterPostContactFeedbackRequest.class));
        verify(recordSensitiveAuditEventUseCase, never()).recordSensitiveAuditEvent(any(RecordSensitiveAuditEventRequest.class));
    }
}
