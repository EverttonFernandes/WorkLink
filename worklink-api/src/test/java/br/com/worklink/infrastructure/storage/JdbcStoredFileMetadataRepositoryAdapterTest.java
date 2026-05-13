package br.com.worklink.infrastructure.storage;

import br.com.worklink.domain.storage.StoredFile;
import br.com.worklink.domain.storage.StoredFileAccessLevel;
import br.com.worklink.domain.storage.StoredFilePurpose;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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

    @Test
    @DisplayName("GIVEN identificador de arquivo WHEN carregar metadados THEN deve consultar arquivo persistido")
    void shouldQueryPersistedFileMetadataWhenLoadingStoredFile() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        java.util.UUID fileIdentifier = java.util.UUID.randomUUID();
        when(jdbcTemplate.query(any(String.class), any(RowMapper.class), eq(fileIdentifier)))
                .thenAnswer(invocation -> {
                    RowMapper<StoredFile> rowMapper = invocation.getArgument(1);
                    return java.util.List.of(rowMapper.mapRow(storedFileResultSet(fileIdentifier), 0));
                });
        JdbcStoredFileMetadataRepositoryAdapter adapter = new JdbcStoredFileMetadataRepositoryAdapter(jdbcTemplate);

        // WHEN
        java.util.Optional<StoredFile> storedFile = adapter.loadStoredFileMetadata(fileIdentifier);

        // THEN
        assertThat(storedFile).isPresent();
        assertThat(storedFile.get().filePurpose()).isEqualTo(StoredFilePurpose.PROFESSIONAL_PORTFOLIO);
        assertThat(storedFile.get().isPubliclyReadable()).isTrue();
        verify(jdbcTemplate).query(any(String.class), any(RowMapper.class), eq(fileIdentifier));
    }

    private ResultSet storedFileResultSet(java.util.UUID fileIdentifier) throws java.sql.SQLException {
        ResultSet resultSet = mock(ResultSet.class);
        when(resultSet.getObject("file_identifier", java.util.UUID.class)).thenReturn(fileIdentifier);
        when(resultSet.getString("file_purpose")).thenReturn(StoredFilePurpose.PROFESSIONAL_PORTFOLIO.name());
        when(resultSet.getString("access_level")).thenReturn(StoredFileAccessLevel.PUBLIC.name());
        when(resultSet.getString("original_filename")).thenReturn("portfolio.jpg");
        when(resultSet.getString("content_type")).thenReturn("image/jpeg");
        when(resultSet.getString("file_extension")).thenReturn("jpg");
        when(resultSet.getLong("size_in_bytes")).thenReturn(300_000L);
        when(resultSet.getString("storage_object_key")).thenReturn("professional-portfolios/key.jpg");
        return resultSet;
    }
}
