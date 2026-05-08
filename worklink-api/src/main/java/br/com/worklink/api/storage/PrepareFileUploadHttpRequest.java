package br.com.worklink.api.storage;

public record PrepareFileUploadHttpRequest(
        String filePurpose,
        String originalFilename,
        String contentType,
        long sizeInBytes
) {
}
