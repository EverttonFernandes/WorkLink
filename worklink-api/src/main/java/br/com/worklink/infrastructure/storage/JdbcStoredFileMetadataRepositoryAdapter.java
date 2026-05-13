package br.com.worklink.infrastructure.storage;

import br.com.worklink.application.storage.port.LoadStoredFileMetadataPort;
import br.com.worklink.application.storage.port.SaveStoredFileMetadataPort;
import br.com.worklink.domain.storage.StoredFile;
import br.com.worklink.domain.storage.StoredFileAccessLevel;
import br.com.worklink.domain.storage.StoredFilePurpose;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcStoredFileMetadataRepositoryAdapter implements SaveStoredFileMetadataPort, LoadStoredFileMetadataPort {

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

    @Override
    public Optional<StoredFile> loadStoredFileMetadata(UUID fileIdentifier) {
        return jdbcTemplate.query(
                """
                SELECT file_identifier,
                       file_purpose,
                       access_level,
                       original_filename,
                       content_type,
                       file_extension,
                       size_in_bytes,
                       storage_object_key
                  FROM worklink.stored_files
                 WHERE file_identifier = ?
                """,
                (resultSet, rowNumber) -> mapStoredFile(resultSet),
                fileIdentifier
        ).stream().findFirst();
    }

    private StoredFile mapStoredFile(ResultSet resultSet) throws SQLException {
        return StoredFile.restoreStoredFile(
                resultSet.getObject("file_identifier", UUID.class),
                StoredFilePurpose.valueOf(resultSet.getString("file_purpose")),
                StoredFileAccessLevel.valueOf(resultSet.getString("access_level")),
                resultSet.getString("original_filename"),
                resultSet.getString("content_type"),
                resultSet.getString("file_extension"),
                resultSet.getLong("size_in_bytes"),
                resultSet.getString("storage_object_key")
        );
    }
}
