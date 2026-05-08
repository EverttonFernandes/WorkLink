package br.com.worklink.api.storage;

import br.com.worklink.application.storage.usecase.PreparedFileUploadResponse;

import java.util.UUID;

public record PreparedFileUploadHttpResponse(
        UUID fileIdentifier,
        String filePurpose,
        String accessLevel,
        String originalFilename,
        String contentType,
        String fileExtension,
        long sizeInBytes
) {

    static PreparedFileUploadHttpResponse fromPreparedFileUploadResponse(PreparedFileUploadResponse response) {
        return new PreparedFileUploadHttpResponse(
                response.fileIdentifier(),
                response.filePurpose(),
                response.accessLevel(),
                response.originalFilename(),
                response.contentType(),
                response.fileExtension(),
                response.sizeInBytes()
        );
    }
}
