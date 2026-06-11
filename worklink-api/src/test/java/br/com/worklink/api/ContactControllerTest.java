package br.com.worklink.api;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.api.contact.ContactController;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.contact.usecase.StartProfessionalContactRequest;
import br.com.worklink.application.contact.usecase.StartProfessionalContactResponse;
import br.com.worklink.application.contact.usecase.StartProfessionalContactUseCase;

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

@WebMvcTest(ContactController.class)
class ContactControllerTest {

    private static final String AUTHORIZATION_HEADER = "Bearer access-value";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private StartProfessionalContactUseCase startProfessionalContactUseCase;

    @MockBean
    private RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    @Test
    @DisplayName("Deve registrar intencao de contato autenticada pela API")
    void shouldRegisterAuthenticatedContactIntentThroughApi() throws Exception {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID contactIntentIdentifier = UUID.randomUUID();
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.CUSTOMER
        );
        StartProfessionalContactResponse contactResponse = new StartProfessionalContactResponse(
                contactIntentIdentifier,
                professionalIdentifier,
                "Maria Eletricista",
                "https://wa.me/51999999999",
                Instant.parse("2026-05-08T10:15:30Z")
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(customerPrincipal);
        when(startProfessionalContactUseCase.startProfessionalContact(argThat(request ->
                request.authenticatedPrincipal().equals(customerPrincipal)
                        && request.professionalIdentifier().equals(professionalIdentifier)
        ))).thenReturn(contactResponse);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/contact-intentions")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "professionalIdentifier",
                                professionalIdentifier
                        ))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.contactIntentIdentifier").value(contactIntentIdentifier.toString()))
                .andExpect(jsonPath("$.professionalIdentifier").value(professionalIdentifier.toString()))
                .andExpect(jsonPath("$.professionalName").value("Maria Eletricista"))
                .andExpect(jsonPath("$.whatsappContactLink").value("https://wa.me/51999999999"))
                .andExpect(jsonPath("$.externalNegotiationNotice").value("A negociacao acontece fora do Profissional Perto pelo WhatsApp."))
                .andExpect(jsonPath("$.noServiceGuaranteeNotice")
                        .value("O Profissional Perto nao garante a execucao do servico contratado."));
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(customerPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.REGISTER_CONTACT_INTENTION
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.CONTACT_INTENTION
                        && auditRequest.targetIdentifier().equals(contactIntentIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("Deve bloquear intencao de contato sem autenticacao")
    void shouldBlockContactIntentWithoutAuthentication() throws Exception {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(null))
                .thenThrow(new AuthenticationRequiredException("Autenticacao obrigatoria para esta acao."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/contact-intentions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "professionalIdentifier",
                                professionalIdentifier
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Autenticacao obrigatoria para esta acao."));
        verify(startProfessionalContactUseCase, never()).startProfessionalContact(any(StartProfessionalContactRequest.class));
        verify(recordSensitiveAuditEventUseCase, never()).recordSensitiveAuditEvent(any(RecordSensitiveAuditEventRequest.class));
    }
}
