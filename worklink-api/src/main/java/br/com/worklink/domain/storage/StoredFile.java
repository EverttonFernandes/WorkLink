package br.com.worklink.domain.storage;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.util.Locale;
import java.util.UUID;

public record StoredFile(
        UUID fileIdentifier,
        StoredFilePurpose filePurpose,
        StoredFileAccessLevel accessLevel,
        String originalFilename,
        String contentType,
        String fileExtension,
        long sizeInBytes,
        String storageObjectKey
) {

    public static StoredFile prepareStoredFile(
            StoredFilePurpose filePurpose,
            String originalFilename,
            String contentType,
            long sizeInBytes
    ) {
        StoredFilePurpose validFilePurpose = requireFilePurpose(filePurpose);
        String validOriginalFilename = requireMeaningfulText(originalFilename, "O nome original do arquivo e obrigatorio.");
        String validContentType = requireMeaningfulText(contentType, "O tipo do arquivo e obrigatorio.").toLowerCase(Locale.ROOT);
        String validFileExtension = extractAllowedExtension(validOriginalFilename, validFilePurpose);
        ensureContentTypeIsAllowed(validContentType, validFilePurpose);
        ensureSizeIsAllowed(sizeInBytes, validFilePurpose);

        UUID fileIdentifier = UUID.randomUUID();
        return new StoredFile(
                fileIdentifier,
                validFilePurpose,
                validFilePurpose.defaultAccessLevel(),
                validOriginalFilename,
                validContentType,
                validFileExtension,
                sizeInBytes,
                "%s/%s.%s".formatted(validFilePurpose.storageSegment(), fileIdentifier, validFileExtension)
        );
    }

    public static StoredFile restoreStoredFile(
            UUID fileIdentifier,
            StoredFilePurpose filePurpose,
            StoredFileAccessLevel accessLevel,
            String originalFilename,
            String contentType,
            String fileExtension,
            long sizeInBytes,
            String storageObjectKey
    ) {
        return new StoredFile(
                requireIdentifier(fileIdentifier),
                requireFilePurpose(filePurpose),
                requireAccessLevel(accessLevel),
                requireMeaningfulText(originalFilename, "O nome original do arquivo e obrigatorio."),
                requireMeaningfulText(contentType, "O tipo do arquivo e obrigatorio."),
                requireMeaningfulText(fileExtension, "A extensao do arquivo e obrigatoria."),
                requirePositiveSize(sizeInBytes),
                requireMeaningfulText(storageObjectKey, "A chave interna do arquivo e obrigatoria.")
        );
    }

    public boolean isPubliclyReadable() {
        return accessLevel == StoredFileAccessLevel.PUBLIC;
    }

    private static StoredFilePurpose requireFilePurpose(StoredFilePurpose filePurpose) {
        if (filePurpose == null) {
            throw new BusinessRuleViolationException("O proposito do arquivo e obrigatorio.");
        }
        return filePurpose;
    }

    private static StoredFileAccessLevel requireAccessLevel(StoredFileAccessLevel accessLevel) {
        if (accessLevel == null) {
            throw new BusinessRuleViolationException("A classificacao de acesso do arquivo e obrigatoria.");
        }
        return accessLevel;
    }

    private static UUID requireIdentifier(UUID identifier) {
        if (identifier == null) {
            throw new BusinessRuleViolationException("O identificador do arquivo e obrigatorio.");
        }
        return identifier;
    }

    private static String requireMeaningfulText(String text, String message) {
        if (text == null || text.isBlank()) {
            throw new BusinessRuleViolationException(message);
        }
        return text.trim();
    }

    private static long requirePositiveSize(long sizeInBytes) {
        if (sizeInBytes <= 0) {
            throw new BusinessRuleViolationException("O tamanho do arquivo deve ser positivo.");
        }
        return sizeInBytes;
    }

    private static String extractAllowedExtension(String originalFilename, StoredFilePurpose filePurpose) {
        int extensionSeparatorIndex = originalFilename.lastIndexOf('.');
        if (extensionSeparatorIndex < 0 || extensionSeparatorIndex == originalFilename.length() - 1) {
            throw new BusinessRuleViolationException("A extensao do arquivo e obrigatoria.");
        }
        String fileExtension = originalFilename.substring(extensionSeparatorIndex + 1).toLowerCase(Locale.ROOT);
        if (!filePurpose.allowsExtension(fileExtension)) {
            throw new BusinessRuleViolationException("A extensao do arquivo nao e permitida.");
        }
        return fileExtension;
    }

    private static void ensureContentTypeIsAllowed(String contentType, StoredFilePurpose filePurpose) {
        if (!filePurpose.allowsContentType(contentType)) {
            throw new BusinessRuleViolationException("O tipo do arquivo nao e permitido.");
        }
    }

    private static void ensureSizeIsAllowed(long sizeInBytes, StoredFilePurpose filePurpose) {
        if (!filePurpose.allowsSize(sizeInBytes)) {
            throw new BusinessRuleViolationException("O tamanho do arquivo excede o limite permitido.");
        }
    }
}
