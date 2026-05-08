package br.com.worklink.application.storage.port;

import br.com.worklink.domain.storage.StoredFile;

@FunctionalInterface
public interface SaveStoredFileMetadataPort {

    StoredFile saveStoredFileMetadata(StoredFile storedFile);
}
