package br.com.worklink.api;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.api.professional.ProfessionalController;
import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.authorization.usecase.AuthorizationOwnership;
import br.com.worklink.application.authorization.usecase.AuthorizeSensitiveActionUseCase;
import br.com.worklink.application.authorization.usecase.SensitiveAction;
import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import br.com.worklink.application.professional.usecase.ListProfessionalsUseCase;
import br.com.worklink.application.professional.usecase.CompleteProfessionalProfileRequest;
import br.com.worklink.application.professional.usecase.CompleteProfessionalProfileUseCase;
import br.com.worklink.application.professional.usecase.ProfessionalResponse;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalRequest;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalUseCase;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Set;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.argThat;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ProfessionalController.class)
class ProfessionalControllerTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();
    private static final String AUTHORIZATION_HEADER = "Bearer access-token";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase;

    @MockBean
    private ListProfessionalsUseCase listProfessionalsUseCase;

    @MockBean
    private CompleteProfessionalProfileUseCase completeProfessionalProfileUseCase;

    @MockBean
    private AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;

    @MockBean
    private AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;

    @Test
    @DisplayName("Deve expor cadastro de profissional basico pela API")
    void shouldExposeBasicProfessionalRegistrationThroughApi() throws Exception {
        // GIVEN
        ProfessionalResponse professionalResponse = validProfessionalResponse();
        when(registerBasicProfessionalUseCase.registerBasicProfessional(any(RegisterBasicProfessionalRequest.class)))
                .thenReturn(professionalResponse);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/professionals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validProfessionalBody())))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.professionalIdentifier").value(professionalResponse.professionalIdentifier().toString()))
                .andExpect(jsonPath("$.professionalName").value("Maria Eletricista"))
                .andExpect(jsonPath("$.whatsappNumber").value("51999999999"))
                .andExpect(jsonPath("$.cityIdentifier").value(CITY_IDENTIFIER.toString()))
                .andExpect(jsonPath("$.categoryIdentifier").value(CATEGORY_IDENTIFIER.toString()))
                .andExpect(jsonPath("$.shortDescription").value("Atendimento residencial."))
                .andExpect(jsonPath("$.documentProvided").value(false))
                .andExpect(jsonPath("$.documentNumber").doesNotExist())
                .andExpect(jsonPath("$.profileCompletenessPercentage").value(50))
                .andExpect(jsonPath("$.profileClassification").value("BASIC_PROFILE"))
                .andExpect(jsonPath("$.availabilityStatus").value("ACCEPTING_NEW_CLIENTS"))
                .andExpect(jsonPath("$.availabilityBadgeLabel").value("Aceitando novos clientes"))
                .andExpect(jsonPath("$.availabilityReducesListingHighlight").value(false))
                .andExpect(jsonPath("$.qualityGuarantee").value(false));
    }

    @Test
    @DisplayName("Deve expor edicao progressiva de perfil profissional pela API")
    void shouldExposeProgressiveProfessionalProfileEditionThroughApi() throws Exception {
        // GIVEN
        ProfessionalResponse professionalResponse = completedProfessionalResponse();
        AuthenticatedPrincipal professionalPrincipal = new AuthenticatedPrincipal(
                professionalResponse.professionalIdentifier(),
                AuthenticatedProfile.PROFESSIONAL
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER)).thenReturn(professionalPrincipal);
        when(completeProfessionalProfileUseCase.completeProfessionalProfile(any(CompleteProfessionalProfileRequest.class)))
                .thenReturn(professionalResponse);

        // WHEN / THEN
        mockMvc.perform(patch("/api/v1/professionals/{professionalIdentifier}/profile", professionalResponse.professionalIdentifier())
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(completedProfessionalBody())))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.profileCompletenessPercentage").value(100))
                .andExpect(jsonPath("$.profileClassification").value("COMPLETE_PROFILE"))
                .andExpect(jsonPath("$.availabilityStatus").value("AVAILABLE_TODAY"))
                .andExpect(jsonPath("$.availabilityBadgeLabel").value("Disponível hoje"))
                .andExpect(jsonPath("$.documentProvided").value(true))
                .andExpect(jsonPath("$.documentNumber").doesNotExist())
                .andExpect(jsonPath("$.qualityGuarantee").value(false));
        verify(authorizeSensitiveActionUseCase).authorizeOwnedSensitiveAction(
                professionalPrincipal,
                SensitiveAction.COMPLETE_PROFESSIONAL_PROFILE,
                new AuthorizationOwnership(professionalResponse.professionalIdentifier())
        );
    }

    @Test
    @DisplayName("Deve expor busca de profissionais por cidade e categoria pela API")
    void shouldExposeProfessionalSearchByCityAndCategoryThroughApi() throws Exception {
        // GIVEN
        ProfessionalResponse professionalResponse = validProfessionalResponse();
        when(listProfessionalsUseCase.listProfessionals(argThat(this::matchesExpectedSearchCriteria)))
                .thenReturn(List.of(professionalResponse));

        // WHEN / THEN
        mockMvc.perform(get("/api/v1/professionals")
                        .param("categoryIdentifier", CATEGORY_IDENTIFIER.toString())
                        .param("cityIdentifiers", CITY_IDENTIFIER.toString())
                        .param("keyword", "residencial"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].professionalName").value("Maria Eletricista"))
                .andExpect(jsonPath("$[0].availabilityBadgeLabel").value("Aceitando novos clientes"))
                .andExpect(jsonPath("$[0].qualityGuarantee").value(false));
    }

    @Test
    @DisplayName("Deve retornar erro de negocio quando profissional basico for invalido")
    void shouldReturnBusinessErrorWhenBasicProfessionalIsInvalid() throws Exception {
        // GIVEN
        when(registerBasicProfessionalUseCase.registerBasicProfessional(any(RegisterBasicProfessionalRequest.class)))
                .thenThrow(new ApplicationRuleViolationException("O WhatsApp do profissional e obrigatorio."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/professionals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validProfessionalBody())))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("O WhatsApp do profissional e obrigatorio."));
    }

    @Test
    @DisplayName("Deve negar edicao de perfil profissional quando nao houver ownership")
    void shouldDenyProfessionalProfileEditionWithoutOwnership() throws Exception {
        // GIVEN
        ProfessionalResponse professionalResponse = completedProfessionalResponse();
        AuthenticatedPrincipal otherProfessionalPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.PROFESSIONAL
        );
        when(authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(AUTHORIZATION_HEADER))
                .thenReturn(otherProfessionalPrincipal);
        doThrow(new AuthorizationDeniedException("Acesso negado para este recurso."))
                .when(authorizeSensitiveActionUseCase)
                .authorizeOwnedSensitiveAction(
                        otherProfessionalPrincipal,
                        SensitiveAction.COMPLETE_PROFESSIONAL_PROFILE,
                        new AuthorizationOwnership(professionalResponse.professionalIdentifier())
                );

        // WHEN / THEN
        mockMvc.perform(patch("/api/v1/professionals/{professionalIdentifier}/profile", professionalResponse.professionalIdentifier())
                        .header("Authorization", AUTHORIZATION_HEADER)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(completedProfessionalBody())))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.message").value("Acesso negado para este recurso."));
    }

    private boolean matchesExpectedSearchCriteria(ProfessionalSearchCriteria professionalSearchCriteria) {
        return professionalSearchCriteria.categoryIdentifier().equals(java.util.Optional.of(CATEGORY_IDENTIFIER))
                && professionalSearchCriteria.cityIdentifiers().equals(Set.of(CITY_IDENTIFIER))
                && professionalSearchCriteria.keyword().equals(java.util.Optional.of("residencial"));
    }

    private ProfessionalResponse validProfessionalResponse() {
        return new ProfessionalResponse(
                UUID.randomUUID(),
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial.",
                null,
                null,
                null,
                null,
                null,
                50,
                "BASIC_PROFILE",
                "ACCEPTING_NEW_CLIENTS",
                "Aceitando novos clientes",
                false,
                false
        );
    }

    private ProfessionalResponse completedProfessionalResponse() {
        return new ProfessionalResponse(
                UUID.randomUUID(),
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial.",
                UUID.randomUUID(),
                "12345678900",
                "https://worklink.example/maria-eletricista",
                "Instalacoes residenciais recentes.",
                "Instalacoes e manutencoes eletricas.",
                100,
                "COMPLETE_PROFILE",
                "AVAILABLE_TODAY",
                "Disponível hoje",
                false,
                false
        );
    }

    private ProfessionalBody validProfessionalBody() {
        return new ProfessionalBody(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
    }

    private CompletedProfessionalBody completedProfessionalBody() {
        return new CompletedProfessionalBody(
                UUID.randomUUID(),
                "12345678900",
                "https://worklink.example/maria-eletricista",
                "Instalacoes residenciais recentes.",
                "Instalacoes e manutencoes eletricas.",
                "AVAILABLE_TODAY"
        );
    }

    private record ProfessionalBody(
            String professionalName,
            String whatsappNumber,
            UUID cityIdentifier,
            UUID categoryIdentifier,
            String shortDescription
    ) {
    }

    private record CompletedProfessionalBody(
            UUID profilePhotoFileIdentifier,
            String documentNumber,
            String usefulLink,
            String portfolioDescription,
            String serviceDescription,
            String availabilityStatus
    ) {
    }
}
