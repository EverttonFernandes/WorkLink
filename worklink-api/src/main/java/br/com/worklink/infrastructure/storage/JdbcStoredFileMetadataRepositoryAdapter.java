package br.com.worklink.infrastructure.storage;

import br.com.worklink.application.storage.port.SaveStoredFileMetadataPort;
import br.com.worklink.domain.storage.StoredFile;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class JdbcStoredFileMetadataRepositoryAdapter implements SaveStoredFileMetadataPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcStoredFileMetadataRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public StoredFile saveStoredFileMetadata(StoredFile storedFile) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.stored_files (
                    file_identifier,
                    file_purpose,
                    access_level,
                    original_filename,
                    content_type,
                    file_extension,
                    size_in_bytes,
                    storage_object_key
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                storedFile.fileIdentifier(),
                storedFile.filePurpose().name(),
                storedFile.accessLevel().name(),
                storedFile.originalFilename(),
                storedFile.contentType(),
                storedFile.fileExtension(),
                storedFile.sizeInBytes(),
                storedFile.storageObjectKey()
        );
        return storedFile;
    }
}
