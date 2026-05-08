package br.com.worklink.api;

import br.com.worklink.api.storage.StorageController;
import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.storage.usecase.PrepareFileUploadRequest;
import br.com.worklink.application.storage.usecase.PrepareFileUploadUseCase;
import br.com.worklink.application.storage.usecase.PreparedFileUploadResponse;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.argThat;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(StorageController.class)
class StorageControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private PrepareFileUploadUseCase prepareFileUploadUseCase;

    @Test
    @DisplayName("Deve preparar upload seguro sem expor chave interna pela API")
    void shouldPrepareSecureUploadWithoutExposingInternalKeyThroughApi() throws Exception {
        // GIVEN
        UUID fileIdentifier = UUID.randomUUID();
        when(prepareFileUploadUseCase.prepareFileUpload(argThat(this::matchesExpectedRequest)))
                .thenReturn(new PreparedFileUploadResponse(
                        fileIdentifier,
                        "REPORT_EVIDENCE",
                        "CONFIDENTIAL",
                        "evidencia.pdf",
                        "application/pdf",
                        "pdf",
                        300_000L,
                        null
                ));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/storage/uploads/prepare")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validBody())))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.fileIdentifier").value(fileIdentifier.toString()))
                .andExpect(jsonPath("$.filePurpose").value("REPORT_EVIDENCE"))
                .andExpect(jsonPath("$.accessLevel").value("CONFIDENTIAL"))
                .andExpect(jsonPath("$.storageObjectKey").doesNotExist());
    }

    @Test
    @DisplayName("Deve retornar erro de negocio quando upload for invalido")
    void shouldReturnBusinessErrorWhenUploadIsInvalid() throws Exception {
        // GIVEN
        when(prepareFileUploadUseCase.prepareFileUpload(any(PrepareFileUploadRequest.class)))
                .thenThrow(new ApplicationRuleViolationException("A extensao do arquivo nao e permitida."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/storage/uploads/prepare")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(validBody())))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A extensao do arquivo nao e permitida."));
    }

    private boolean matchesExpectedRequest(PrepareFileUploadRequest request) {
        return request.filePurpose().equals("REPORT_EVIDENCE")
                && request.originalFilename().equals("evidencia.pdf")
                && request.contentType().equals("application/pdf")
                && request.sizeInBytes() == 300_000L;
    }

    private StoragePreparationBody validBody() {
        return new StoragePreparationBody(
                "REPORT_EVIDENCE",
                "evidencia.pdf",
                "application/pdf",
                300_000L
        );
    }

    private record StoragePreparationBody(
            String filePurpose,
            String originalFilename,
            String contentType,
            long sizeInBytes
    ) {
    }
}
