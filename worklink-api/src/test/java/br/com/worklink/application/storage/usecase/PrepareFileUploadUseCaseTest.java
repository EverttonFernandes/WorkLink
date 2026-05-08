package br.com.worklink.application.storage.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.storage.port.SaveStoredFileMetadataPort;
import br.com.worklink.domain.storage.StoredFile;
import br.com.worklink.domain.storage.StoredFileAccessLevel;
import br.com.worklink.domain.storage.StoredFilePurpose;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class PrepareFileUploadUseCaseTest {

    @Test
    @DisplayName("Deve preparar upload seguro e persistir metadados quando arquivo for valido")
    void shouldPrepareSecureUploadAndPersistMetadataWhenFileIsValid() {
        // GIVEN
        InMemorySaveStoredFileMetadataPort saveStoredFileMetadataPort = new InMemorySaveStoredFileMetadataPort();
        PrepareFileUploadUseCase useCase = new PrepareFileUploadUseCase(saveStoredFileMetadataPort);

        // WHEN
        PreparedFileUploadResponse response = useCase.prepareFileUpload(new PrepareFileUploadRequest(
                StoredFilePurpose.PROFESSIONAL_PROFILE_PHOTO.name(),
                "foto.png",
                "image/png",
                512_000L
        ));

        // THEN
        assertThat(response.fileIdentifier()).isNotNull();
        assertThat(response.filePurpose()).isEqualTo(StoredFilePurpose.PROFESSIONAL_PROFILE_PHOTO.name());
        assertThat(response.accessLevel()).isEqualTo(StoredFileAccessLevel.PUBLIC.name());
        assertThat(response.storageObjectKey()).isNull();
        assertThat(saveStoredFileMetadataPort.savedStoredFile.storageObjectKey()).isNotBlank();
    }

    @Test
    @DisplayName("Deve converter violacao de dominio em violacao de aplicacao quando arquivo for invalido")
    void shouldConvertDomainViolationIntoApplicationViolationWhenFileIsInvalid() {
        // GIVEN
        PrepareFileUploadUseCase useCase = new PrepareFileUploadUseCase(storedFile -> storedFile);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.prepareFileUpload(new PrepareFileUploadRequest(
                StoredFilePurpose.PROFESSIONAL_PROFILE_PHOTO.name(),
                "malware.exe",
                "application/octet-stream",
                10L
        )))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A extensao do arquivo nao e permitida.");
    }

    private static class InMemorySaveStoredFileMetadataPort implements SaveStoredFileMetadataPort {

        private StoredFile savedStoredFile;

        @Override
        public StoredFile saveStoredFileMetadata(StoredFile storedFile) {
            savedStoredFile = storedFile;
            return storedFile;
        }
    }
}
