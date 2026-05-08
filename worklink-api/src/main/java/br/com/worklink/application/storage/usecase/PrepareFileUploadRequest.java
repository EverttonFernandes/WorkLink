package br.com.worklink.application.storage.usecase;

public record PrepareFileUploadRequest(
        String filePurpose,
        String originalFilename,
        String contentType,
        long sizeInBytes
) {
}
