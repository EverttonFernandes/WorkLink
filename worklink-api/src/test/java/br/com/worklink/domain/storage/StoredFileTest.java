package br.com.worklink.domain.storage;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class StoredFileTest {

    @Test
    @DisplayName("Deve preparar foto publica com chave interna aleatoria quando metadados forem validos")
    void shouldPreparePublicPhotoWithRandomInternalKeyWhenMetadataIsValid() {
        // GIVEN
        String originalFilename = "foto perfil.png";

        // WHEN
        StoredFile storedFile = StoredFile.prepareStoredFile(
                StoredFilePurpose.PROFESSIONAL_PROFILE_PHOTO,
                originalFilename,
                "image/png",
                512_000L
        );

        // THEN
        assertThat(storedFile.fileIdentifier()).isNotNull();
        assertThat(storedFile.filePurpose()).isEqualTo(StoredFilePurpose.PROFESSIONAL_PROFILE_PHOTO);
        assertThat(storedFile.accessLevel()).isEqualTo(StoredFileAccessLevel.PUBLIC);
        assertThat(storedFile.originalFilename()).isEqualTo(originalFilename);
        assertThat(storedFile.fileExtension()).isEqualTo("png");
        assertThat(storedFile.storageObjectKey()).startsWith("professional-profile-photos/");
        assertThat(storedFile.storageObjectKey()).endsWith(".png");
        assertThat(storedFile.storageObjectKey()).doesNotContain("foto perfil");
    }

    @Test
    @DisplayName("Deve preparar evidencia de denuncia como confidencial quando metadados forem validos")
    void shouldPrepareReportEvidenceAsConfidentialWhenMetadataIsValid() {
        // GIVEN
        String originalFilename = "evidencia.pdf";

        // WHEN
        StoredFile storedFile = StoredFile.prepareStoredFile(
                StoredFilePurpose.REPORT_EVIDENCE,
                originalFilename,
                "application/pdf",
                2_000_000L
        );

        // THEN
        assertThat(storedFile.accessLevel()).isEqualTo(StoredFileAccessLevel.CONFIDENTIAL);
        assertThat(storedFile.storageObjectKey()).startsWith("report-evidences/");
        assertThat(storedFile.storageObjectKey()).endsWith(".pdf");
    }

    @Test
    @DisplayName("Deve rejeitar arquivo quando extensao for perigosa")
    void shouldRejectFileWhenExtensionIsDangerous() {
        // GIVEN
        String originalFilename = "script.sh";

        // WHEN / THEN
        assertThatThrownBy(() -> StoredFile.prepareStoredFile(
                StoredFilePurpose.PROFESSIONAL_PORTFOLIO,
                originalFilename,
                "application/octet-stream",
                100L
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A extensao do arquivo nao e permitida.");
    }

    @Test
    @DisplayName("Deve rejeitar arquivo quando tamanho exceder limite do proposito")
    void shouldRejectFileWhenSizeExceedsPurposeLimit() {
        // GIVEN
        long oversizedPhoto = 6_000_000L;

        // WHEN / THEN
        assertThatThrownBy(() -> StoredFile.prepareStoredFile(
                StoredFilePurpose.PROFESSIONAL_PROFILE_PHOTO,
                "foto.jpg",
                "image/jpeg",
                oversizedPhoto
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O tamanho do arquivo excede o limite permitido.");
    }

    @Test
    @DisplayName("Deve restaurar metadados persistidos quando campos forem validos")
    void shouldRestorePersistedMetadataWhenFieldsAreValid() {
        // GIVEN
        UUID fileIdentifier = UUID.randomUUID();

        // WHEN
        StoredFile storedFile = StoredFile.restoreStoredFile(
                fileIdentifier,
                StoredFilePurpose.PROFESSIONAL_PORTFOLIO,
                StoredFileAccessLevel.PUBLIC,
                "portfolio.jpg",
                "image/jpeg",
                "jpg",
                400_000L,
                "professional-portfolios/%s.jpg".formatted(fileIdentifier)
        );

        // THEN
        assertThat(storedFile.fileIdentifier()).isEqualTo(fileIdentifier);
        assertThat(storedFile.storageObjectKey()).contains(fileIdentifier.toString());
    }
}
