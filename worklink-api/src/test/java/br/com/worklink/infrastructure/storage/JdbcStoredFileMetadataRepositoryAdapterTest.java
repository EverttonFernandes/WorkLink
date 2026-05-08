package br.com.worklink.infrastructure.storage;

import br.com.worklink.domain.storage.StoredFile;
import br.com.worklink.domain.storage.StoredFileAccessLevel;
import br.com.worklink.domain.storage.StoredFilePurpose;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class JdbcStoredFileMetadataRepositoryAdapterTest {

    @Test
    @DisplayName("Deve persistir somente metadados do arquivo usando JdbcTemplate")
    void shouldPersistOnlyFileMetadataUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcStoredFileMetadataRepositoryAdapter adapter = new JdbcStoredFileMetadataRepositoryAdapter(jdbcTemplate);
        StoredFile storedFile = StoredFile.restoreStoredFile(
                java.util.UUID.randomUUID(),
                StoredFilePurpose.REPORT_EVIDENCE,
                StoredFileAccessLevel.CONFIDENTIAL,
                "evidencia.pdf",
                "application/pdf",
                "pdf",
                300_000L,
                "report-evidences/internal-key.pdf"
        );

        // WHEN
        StoredFile savedStoredFile = adapter.saveStoredFileMetadata(storedFile);

        // THEN
        assertThat(savedStoredFile).isEqualTo(storedFile);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(storedFile.fileIdentifier()),
                eq(storedFile.filePurpose().name()),
                eq(storedFile.accessLevel().name()),
                eq(storedFile.originalFilename()),
                eq(storedFile.contentType()),
                eq(storedFile.fileExtension()),
                eq(storedFile.sizeInBytes()),
                eq(storedFile.storageObjectKey())
        );
    }
}
