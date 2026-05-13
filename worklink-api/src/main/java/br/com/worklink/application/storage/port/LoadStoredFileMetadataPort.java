package br.com.worklink.application.storage.port;

import br.com.worklink.domain.storage.StoredFile;

import java.util.Optional;
import java.util.UUID;

@FunctionalInterface
public interface LoadStoredFileMetadataPort {

    Optional<StoredFile> loadStoredFileMetadata(UUID fileIdentifier);
}
