package br.com.worklink.api;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.api.customer.CustomerProfileController;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.authorization.usecase.AuthorizationOwnership;
import br.com.worklink.application.authorization.usecase.AuthorizeSensitiveActionUseCase;
import br.com.worklink.application.authorization.usecase.SensitiveAction;
import br.com.worklink.application.contact.usecase.DismissPostContactFeedbackRequestUseCase;
import br.com.worklink.application.contact.usecase.ListPendingPostContactFeedbackRequestsUseCase;
import br.com.worklink.application.contact.usecase.PendingPostContactFeedbackRequestResponse;
import br.com.worklink.application.customer.usecase.CustomerProfileCityResponse;
import br.com.worklink.application.customer.usecase.CustomerProfileResponse;
import br.com.worklink.application.customer.usecase.CustomerSavedProfessionalResponse;
import br.com.worklink.application.customer.usecase.CustomerSubmittedReviewResponse;
import br.com.worklink.application.customer.usecase.LoadCustomerProfileUseCase;
import br.com.worklink.application.customer.usecase.RemoveCustomerSavedProfessionalUseCase;
import br.com.worklink.application.customer.usecase.SaveCustomerProfessionalUseCase;
import br.com.worklink.application.customer.usecase.UpdateCustomerProfilePreferencesRequest;
import br.com.worklink.application.customer.usecase.UpdateCustomerProfilePreferencesUseCase;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.argThat;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(CustomerProfileController.class)
class CustomerProfileControllerTest {

    private static final String AUTHORIZATION_HEADER = "Bearer access-token";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;

    @MockBean
    private LoadCustomerProfileUseCase loadCustomerProfileUseCase;

    @MockBean
    private UpdateCustomerProfilePreferencesUseCase updateCustomerProfilePreferencesUseCase;

    @MockBean
    private SaveCustomerProfessionalUseCase saveCustomerProfessionalUseCase;

    @MockBean
    private RemoveCustomerSavedProfessionalUseCase removeCustomerSavedProfessionalUseCase;

    @MockBean
    private ListPendingPostContactFeedbackRequestsUseCase listPendingPostContactFeedbackRequestsUseCase;

    @MockBean
    private DismissPostContactFeedbackRequestUseCase dismissPostContactFeedbackRequestUseCase;

    @MockBean
    private RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    @Test
    @DisplayName("GIVEN cliente autenticado WHEN carregar perfil THEN deve expor agregados do backend")
    void shouldLoadCustomerProfileThroughApi() throws Exception {
        // GIVEN
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedCustomer();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(authenticatedPrincipal);
        when(loadCustomerProfileUseCase.loadCustomerProfile(authenticatedPrincipal.principalIdentifier()))
                .thenReturn(customerProfileResponse(authenticatedPrincipal.principalIdentifier()));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/customers/me/profile").header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.customerName").value("Cliente Exemplo"))
                .andExpect(jsonPath("$.savedProfessionals[0].professionalName").value("Maria Eletricista"))
                .andExpect(jsonPath("$.submittedReviews[0].professionalName").value("Maria Eletricista"))
                .andExpect(jsonPath("$.whatsappNotificationsEnabled").value(true));
        verify(authorizeSensitiveActionUseCase).authorizeOwnedSensitiveAction(
                authenticatedPrincipal,
                SensitiveAction.ACCESS_PRIVATE_CUSTOMER_DATA,
                new AuthorizationOwnership(authenticatedPrincipal.principalIdentifier())
        );
    }

    @Test
    @DisplayName("GIVEN preferencias validas WHEN atualizar THEN deve registrar auditoria")
    void shouldUpdateCustomerProfilePreferencesThroughApi() throws Exception {
        // GIVEN
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedCustomer();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(authenticatedPrincipal);
        when(updateCustomerProfilePreferencesUseCase.updateCustomerProfilePreferences(any(UpdateCustomerProfilePreferencesRequest.class)))
                .thenReturn(customerProfileResponse(authenticatedPrincipal.principalIdentifier()));

        // WHEN / THEN
        mockMvc.perform(patch("/api/v1/customers/me/profile/preferences")
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "whatsappNotificationsEnabled", true,
                                "profilePersonalizationEnabled", true
                        ))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.profilePersonalizationEnabled").value(true));
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(authenticatedPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.UPDATE_CUSTOMER_PROFILE_PREFERENCES
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.CUSTOMER_PROFILE
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("GIVEN cliente autenticado WHEN salvar e remover profissional THEN deve retornar perfil atualizado")
    void shouldSaveAndRemoveCustomerSavedProfessionalThroughApi() throws Exception {
        // GIVEN
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedCustomer();
        UUID professionalIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(authenticatedPrincipal);
        when(saveCustomerProfessionalUseCase.saveCustomerProfessional(
                authenticatedPrincipal.principalIdentifier(),
                professionalIdentifier
        )).thenReturn(customerProfileResponse(authenticatedPrincipal.principalIdentifier()));
        when(removeCustomerSavedProfessionalUseCase.removeCustomerSavedProfessional(
                authenticatedPrincipal.principalIdentifier(),
                professionalIdentifier
        )).thenReturn(customerProfileResponse(authenticatedPrincipal.principalIdentifier()));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/customers/me/saved-professionals/{professionalIdentifier}", professionalIdentifier)
                        .header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.savedProfessionals[0].professionalIdentifier").exists());
        mockMvc.perform(delete("/api/v1/customers/me/saved-professionals/{professionalIdentifier}", professionalIdentifier)
                        .header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("GIVEN cliente autenticado WHEN listar solicitacoes pendentes THEN deve expor contatos aguardando feedback")
    void shouldListPendingPostContactFeedbackRequestsThroughApi() throws Exception {
        // GIVEN
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedCustomer();
        UUID contactIntentIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(authenticatedPrincipal);
        when(listPendingPostContactFeedbackRequestsUseCase.listPendingPostContactFeedbackRequests(
                authenticatedPrincipal.principalIdentifier()
        )).thenReturn(List.of(new PendingPostContactFeedbackRequestResponse(
                contactIntentIdentifier,
                professionalIdentifier,
                "Maria Eletricista",
                java.time.Instant.parse("2026-05-13T12:00:00Z")
        )));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/customers/me/post-contact-feedback-requests")
                        .header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].contactIntentIdentifier").value(contactIntentIdentifier.toString()))
                .andExpect(jsonPath("$[0].professionalName").value("Maria Eletricista"));
    }

    @Test
    @DisplayName("GIVEN cliente autenticado WHEN dispensar solicitacao pendente THEN deve registrar auditoria")
    void shouldDismissPendingPostContactFeedbackRequestThroughApi() throws Exception {
        // GIVEN
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedCustomer();
        UUID contactIntentIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(authenticatedPrincipal);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/customers/me/post-contact-feedback-requests/{contactIntentIdentifier}/dismiss",
                        contactIntentIdentifier)
                        .header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isNoContent());
        verify(dismissPostContactFeedbackRequestUseCase).dismissPostContactFeedbackRequest(
                authenticatedPrincipal.principalIdentifier(),
                contactIntentIdentifier
        );
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(authenticatedPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.DISMISS_POST_CONTACT_FEEDBACK_REQUEST
                        && auditRequest.sensitiveAuditTargetType() == SensitiveAuditTargetType.CONTACT_INTENTION
                        && auditRequest.targetIdentifier().equals(contactIntentIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    @Test
    @DisplayName("GIVEN requisicao sem autenticacao WHEN acessar perfil privado THEN deve bloquear")
    void shouldBlockUnauthenticatedCustomerProfileAccess() throws Exception {
        // GIVEN
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(null))
                .thenThrow(new AuthenticationRequiredException("Autenticacao obrigatoria para esta acao."));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/customers/me/profile"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Autenticacao obrigatoria para esta acao."));
        verify(loadCustomerProfileUseCase, never()).loadCustomerProfile(any(UUID.class));
        verify(recordSensitiveAuditEventUseCase, never()).recordSensitiveAuditEvent(any(RecordSensitiveAuditEventRequest.class));
    }

    private AuthenticatedPrincipal authenticatedCustomer() {
        return new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER);
    }

    private CustomerProfileResponse customerProfileResponse(UUID customerIdentifier) {
        UUID professionalIdentifier = UUID.randomUUID();
        UUID professionalReviewIdentifier = UUID.randomUUID();
        CustomerProfileCityResponse cityResponse = new CustomerProfileCityResponse(
                UUID.randomUUID(),
                "Canoas",
                "RS"
        );
        return new CustomerProfileResponse(
                customerIdentifier,
                "Cliente Exemplo",
                "51999991234",
                cityResponse,
                List.of(cityResponse),
                List.of(new CustomerSavedProfessionalResponse(
                        professionalIdentifier,
                        "Maria Eletricista",
                        "Eletricista",
                        cityResponse
                )),
                List.of(new CustomerSubmittedReviewResponse(
                        professionalReviewIdentifier,
                        professionalIdentifier,
                        "Maria Eletricista",
                        5,
                        true,
                        "Excelente atendimento"
                )),
                true,
                true
        );
    }
}
