package br.com.worklink.api;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.api.review.ProfessionalReviewController;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.review.usecase.RegisterProfessionalReviewRequest;
import br.com.worklink.application.review.usecase.RegisterProfessionalReviewResponse;
import br.com.worklink.application.review.usecase.RegisterProfessionalReviewUseCase;

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

@WebMvcTest(ProfessionalReviewController.class)
class ProfessionalReviewControllerTest {

    private static final String AUTHORIZATION_HEADER = "Bearer access-value";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private RegisterProfessionalReviewUseCase registerProfessionalReviewUseCase;

    @MockBean
    private RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    @Test
    @DisplayName("GIVEN cliente autenticado WHEN avaliar anonimamente THEN deve retornar resposta publica sem autoria interna")
    void shouldRegisterAnonymousProfessionalReviewThroughApi() throws Exception {
        // GIVEN
        UUID contactIntentIdentifier = UUID.randomUUID();
        UUID professionalReviewIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER);
        RegisterProfessionalReviewResponse response = new RegisterProfessionalReviewResponse(
                professionalReviewIdentifier,
                contactIntentIdentifier,
                professionalIdentifier,
                5,
                "Excelente atendimento",
                true,
                null,
                "Usuario anonimo",
                Instant.parse("2026-05-09T13:00:00Z")
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(customerPrincipal);
        when(registerProfessionalReviewUseCase.registerProfessionalReview(argThat(request ->
                request.authenticatedPrincipal().equals(customerPrincipal)
                        && request.contactIntentIdentifier().equals(contactIntentIdentifier)
                        && request.starRating() == 5
                        && request.anonymousToPublic()
        ))).thenReturn(response);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/professional-reviews")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "contactIntentIdentifier", contactIntentIdentifier,
                                "starRating", 5,
                                "comment", "Excelente atendimento",
                                "anonymousToPublic", true
                        ))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.professionalReviewIdentifier").value(professionalReviewIdentifier.toString()))
                .andExpect(jsonPath("$.professionalIdentifier").value(professionalIdentifier.toString()))
                .andExpect(jsonPath("$.starRating").value(5))
                .andExpect(jsonPath("$.anonymousToPublic").value(true))
                .andExpect(jsonPath("$.publicAuthorIdentifier").doesNotExist())
                .andExpect(jsonPath("$.publicAuthorDisplayName").value("Usuario anonimo"));
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(customerPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.REGISTER_ANONYMOUS_REVIEW
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.REVIEW
                        && auditRequest.targetIdentifier().equals(professionalReviewIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("GIVEN requisicao sem autenticacao WHEN avaliar THEN deve bloquear sem registrar auditoria de sucesso")
    void shouldBlockProfessionalReviewWithoutAuthentication() throws Exception {
        // GIVEN
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(null))
                .thenThrow(new AuthenticationRequiredException("Autenticacao obrigatoria para esta acao."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/professional-reviews")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "contactIntentIdentifier", UUID.randomUUID(),
                                "starRating", 5,
                                "anonymousToPublic", true
                        ))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Autenticacao obrigatoria para esta acao."));
        verify(registerProfessionalReviewUseCase, never()).registerProfessionalReview(any(RegisterProfessionalReviewRequest.class));
        verify(recordSensitiveAuditEventUseCase, never()).recordSensitiveAuditEvent(any(RecordSensitiveAuditEventRequest.class));
    }
}
