package br.com.worklink.api;

import br.com.worklink.api.professional.ProfessionalController;
import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import br.com.worklink.application.professional.usecase.ListProfessionalsUseCase;
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
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.argThat;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ProfessionalController.class)
class ProfessionalControllerTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase;

    @MockBean
    private ListProfessionalsUseCase listProfessionalsUseCase;

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
                .andExpect(jsonPath("$.profileClassification").value("BASIC_PROFILE"))
                .andExpect(jsonPath("$.qualityGuarantee").value(false));
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
                        .param("cityIdentifier", CITY_IDENTIFIER.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].professionalName").value("Maria Eletricista"))
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

    private boolean matchesExpectedSearchCriteria(ProfessionalSearchCriteria professionalSearchCriteria) {
        return professionalSearchCriteria.categoryIdentifier().equals(java.util.Optional.of(CATEGORY_IDENTIFIER))
                && professionalSearchCriteria.cityIdentifier().equals(java.util.Optional.of(CITY_IDENTIFIER));
    }

    private ProfessionalResponse validProfessionalResponse() {
        return new ProfessionalResponse(
                UUID.randomUUID(),
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial.",
                "BASIC_PROFILE",
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

    private record ProfessionalBody(
            String professionalName,
            String whatsappNumber,
            UUID cityIdentifier,
            UUID categoryIdentifier,
            String shortDescription
    ) {
    }
}
