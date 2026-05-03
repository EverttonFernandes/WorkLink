package br.com.worklink.api;

import br.com.worklink.api.location.CitySelectionController;
import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.location.usecase.CitySelectionCityResponse;
import br.com.worklink.application.location.usecase.CitySelectionPreviewResponse;
import br.com.worklink.application.location.usecase.PreviewCitySelectionRequest;
import br.com.worklink.application.location.usecase.PreviewCitySelectionUseCase;

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
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(CitySelectionController.class)
class CitySelectionControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private PreviewCitySelectionUseCase previewCitySelectionUseCase;

    @Test
    @DisplayName("Deve expor previa de selecao de cidades sem login")
    void shouldExposeCitySelectionPreviewWithoutLogin() throws Exception {
        // GIVEN
        UUID cityIdentifier = UUID.randomUUID();
        CitySelectionPreviewResponse citySelectionPreviewResponse = new CitySelectionPreviewResponse(
                List.of(new CitySelectionCityResponse(cityIdentifier, "Canoas", "RS")),
                false,
                List.of()
        );
        when(previewCitySelectionUseCase.previewCitySelection(any(PreviewCitySelectionRequest.class)))
                .thenReturn(citySelectionPreviewResponse);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/city-selection/preview")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new CitySelectionPreviewBody(List.of(cityIdentifier), null, null))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.selectedCities[0].cityIdentifier").value(cityIdentifier.toString()))
                .andExpect(jsonPath("$.selectedCities[0].cityName").value("Canoas"))
                .andExpect(jsonPath("$.currentLocationEnabled").value(false))
                .andExpect(jsonPath("$.nearbySuggestedCities").isEmpty());
    }

    @Test
    @DisplayName("Deve expor sugestoes proximas quando localizacao atual for informada")
    void shouldExposeNearbySuggestionsWhenCurrentLocationIsProvided() throws Exception {
        // GIVEN
        UUID suggestedCityIdentifier = UUID.randomUUID();
        CitySelectionPreviewResponse citySelectionPreviewResponse = new CitySelectionPreviewResponse(
                List.of(),
                true,
                List.of(new CitySelectionCityResponse(suggestedCityIdentifier, "Esteio", "RS"))
        );
        when(previewCitySelectionUseCase.previewCitySelection(any(PreviewCitySelectionRequest.class)))
                .thenReturn(citySelectionPreviewResponse);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/city-selection/preview")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new CitySelectionPreviewBody(List.of(), -29.91, -51.18))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currentLocationEnabled").value(true))
                .andExpect(jsonPath("$.nearbySuggestedCities[0].cityIdentifier").value(suggestedCityIdentifier.toString()));
    }

    @Test
    @DisplayName("Deve expor limpeza de selecao de cidades")
    void shouldExposeCitySelectionCleanup() throws Exception {
        // GIVEN
        when(previewCitySelectionUseCase.clearCitySelection()).thenReturn(new CitySelectionPreviewResponse(List.of(), false, List.of()));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/city-selection/clear"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.selectedCities").isEmpty())
                .andExpect(jsonPath("$.currentLocationEnabled").value(false));
    }

    @Test
    @DisplayName("Deve retornar erro quando apenas uma coordenada atual for informada")
    void shouldReturnErrorWhenOnlyOneCurrentCoordinateIsProvided() throws Exception {
        // GIVEN
        CitySelectionPreviewBody citySelectionPreviewBody = new CitySelectionPreviewBody(List.of(), -29.91, null);

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/city-selection/preview")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(citySelectionPreviewBody)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Latitude e longitude atuais devem ser informadas juntas."));
    }

    @Test
    @DisplayName("Deve retornar erro de aplicacao quando selecao for invalida")
    void shouldReturnApplicationErrorWhenSelectionIsInvalid() throws Exception {
        // GIVEN
        when(previewCitySelectionUseCase.previewCitySelection(any(PreviewCitySelectionRequest.class)))
                .thenThrow(new ApplicationRuleViolationException("Uma ou mais cidades selecionadas nao foram encontradas."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/city-selection/preview")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new CitySelectionPreviewBody(List.of(UUID.randomUUID()), null, null))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Uma ou mais cidades selecionadas nao foram encontradas."));
    }

    private record CitySelectionPreviewBody(
            List<UUID> selectedCityIdentifiers,
            Double currentLatitude,
            Double currentLongitude
    ) {
    }
}
