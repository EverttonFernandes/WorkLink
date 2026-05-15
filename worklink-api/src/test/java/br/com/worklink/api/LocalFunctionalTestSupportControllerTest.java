package br.com.worklink.api;

import br.com.worklink.api.testsupport.LocalFunctionalTestSupportController;
import br.com.worklink.application.testsupport.usecase.ResetLocalFunctionalScenarioUseCase;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.verify;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ActiveProfiles("local")
@WebMvcTest(LocalFunctionalTestSupportController.class)
class LocalFunctionalTestSupportControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ResetLocalFunctionalScenarioUseCase resetLocalFunctionalScenarioUseCase;

    @Test
    @DisplayName("GIVEN ambiente local WHEN requisitar reset funcional THEN deve retornar no content")
    void shouldResetLocalFunctionalScenarioStateThroughApi() throws Exception {
        // WHEN / THEN
        mockMvc.perform(post("/api/v1/test-support/reset"))
                .andExpect(status().isNoContent());

        verify(resetLocalFunctionalScenarioUseCase).resetScenarioState();
    }
}
