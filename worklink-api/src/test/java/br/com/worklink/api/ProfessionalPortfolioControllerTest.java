package br.com.worklink.api;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.api.professional.ProfessionalPortfolioController;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.authorization.usecase.AuthorizationOwnership;
import br.com.worklink.application.authorization.usecase.AuthorizeSensitiveActionUseCase;
import br.com.worklink.application.authorization.usecase.SensitiveAction;
import br.com.worklink.application.professional.usecase.AddProfessionalPortfolioItemRequest;
import br.com.worklink.application.professional.usecase.AddProfessionalPortfolioItemUseCase;
import br.com.worklink.application.professional.usecase.ListProfessionalPortfolioItemsUseCase;
import br.com.worklink.application.professional.usecase.ProfessionalPortfolioItemResponse;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.argThat;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ProfessionalPortfolioController.class)
class ProfessionalPortfolioControllerTest {

    private static final String AUTHORIZATION_HEADER = "Bearer access-token";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase;

    @MockBean
    private ListProfessionalPortfolioItemsUseCase listProfessionalPortfolioItemsUseCase;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;

    @MockBean
    private RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    @Test
    @DisplayName("GIVEN principal autenticado WHEN listar portfolio THEN deve expor os itens do profissional")
    void shouldExposeProfessionalPortfolioItemsWhenPrincipalIsAuthenticated() throws Exception {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID fileIdentifier = UUID.randomUUID();
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.CUSTOMER
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(customerPrincipal);
        when(listProfessionalPortfolioItemsUseCase.listProfessionalPortfolioItems(professionalIdentifier))
                .thenReturn(List.of(new ProfessionalPortfolioItemResponse(
                        UUID.randomUUID(),
                        professionalIdentifier,
                        fileIdentifier,
                        "Quadro eletrico residencial",
                        "Instalacao concluida em apartamento.",
                        1
                )));

        // WHEN / THEN
        mockMvc.perform(get(
                        "/api/v1/professionals/{professionalIdentifier}/portfolio-items",
                        professionalIdentifier
                ).header("Authorization", AUTHORIZATION_HEADER))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].professionalIdentifier").value(professionalIdentifier.toString()))
                .andExpect(jsonPath("$[0].fileIdentifier").value(fileIdentifier.toString()))
                .andExpect(jsonPath("$[0].title").value("Quadro eletrico residencial"))
                .andExpect(jsonPath("$[0].description").value("Instalacao concluida em apartamento."))
                .andExpect(jsonPath("$[0].displayOrder").value(1))
                .andExpect(jsonPath("$[0].storageObjectKey").doesNotExist());
        verify(authenticatedPrincipalHttpResolver).resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER);
    }

    @Test
    @DisplayName("GIVEN requisicao anonima WHEN listar portfolio THEN deve exigir autenticacao")
    void shouldRequireAuthenticationBeforeListingProfessionalPortfolioItems() throws Exception {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(null))
                .thenThrow(new AuthenticationRequiredException("Autenticacao obrigatoria para este recurso."));

        // WHEN / THEN
        mockMvc.perform(get(
                        "/api/v1/professionals/{professionalIdentifier}/portfolio-items",
                        professionalIdentifier
                ))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("Autenticacao obrigatoria para este recurso."));
        verify(listProfessionalPortfolioItemsUseCase, never())
                .listProfessionalPortfolioItems(professionalIdentifier);
    }

    @Test
    @DisplayName("GIVEN profissional dono WHEN adicionar portfolio THEN deve autorizar e auditar inclusao")
    void shouldAuthorizeAndAuditPortfolioItemCreationWhenProfessionalOwnsProfile() throws Exception {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID fileIdentifier = UUID.randomUUID();
        AuthenticatedPrincipal professionalPrincipal = new AuthenticatedPrincipal(
                professionalIdentifier,
                AuthenticatedProfile.PROFESSIONAL
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(professionalPrincipal);
        when(addProfessionalPortfolioItemUseCase.addProfessionalPortfolioItem(any(AddProfessionalPortfolioItemRequest.class)))
                .thenReturn(new ProfessionalPortfolioItemResponse(
                        UUID.randomUUID(),
                        professionalIdentifier,
                        fileIdentifier,
                        "Quadro eletrico residencial",
                        "Instalacao concluida em apartamento.",
                        1
                ));

        // WHEN / THEN
        mockMvc.perform(post(
                        "/api/v1/professionals/{professionalIdentifier}/portfolio-items",
                        professionalIdentifier
                )
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new PortfolioItemBody(
                                fileIdentifier,
                                "Quadro eletrico residencial",
                                "Instalacao concluida em apartamento.",
                                1
                        ))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.fileIdentifier").value(fileIdentifier.toString()))
                .andExpect(jsonPath("$.title").value("Quadro eletrico residencial"));
        verify(authorizeSensitiveActionUseCase).authorizeOwnedSensitiveAction(
                professionalPrincipal,
                SensitiveAction.MANAGE_PROFESSIONAL_PORTFOLIO,
                new AuthorizationOwnership(professionalIdentifier)
        );
        verify(addProfessionalPortfolioItemUseCase).addProfessionalPortfolioItem(argThat(request ->
                request.professionalIdentifier().equals(professionalIdentifier)
                        && request.fileIdentifier().equals(fileIdentifier)
                        && request.title().equals("Quadro eletrico residencial")
                        && request.displayOrder() == 1
        ));
        verify(recordSensitiveAuditEventUseCase).recordSensitiveAuditEvent(argThat(auditRequest ->
                auditRequest.authenticatedPrincipal().equals(professionalPrincipal)
                        && auditRequest.sensitiveAuditAction() == SensitiveAuditAction.ADD_PROFESSIONAL_PORTFOLIO_ITEM
                        && auditRequest.targetIdentifier().equals(professionalIdentifier)
                        && auditRequest.sensitiveAuditOutcome() == SensitiveAuditOutcome.SUCCESS
        ));
    }

    private record PortfolioItemBody(
            UUID fileIdentifier,
            String title,
            String description,
            int displayOrder
    ) {
    }
}
