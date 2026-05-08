package br.com.worklink.application.storage.usecase;

import br.com.worklink.domain.storage.StoredFile;

import java.util.UUID;

public record PreparedFileUploadResponse(
        UUID fileIdentifier,
        String filePurpose,
        String accessLevel,
        String originalFilename,
        String contentType,
        String fileExtension,
        long sizeInBytes,
        String storageObjectKey
) {

    static PreparedFileUploadResponse fromStoredFile(StoredFile storedFile) {
        return new PreparedFileUploadResponse(
                storedFile.fileIdentifier(),
                storedFile.filePurpose().name(),
                storedFile.accessLevel().name(),
                storedFile.originalFilename(),
                storedFile.contentType(),
                storedFile.fileExtension(),
                storedFile.sizeInBytes(),
                null
        );
    }
}
