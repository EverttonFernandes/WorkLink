package br.com.worklink.domain.storage;

import java.util.Set;

public enum StoredFilePurpose {
    PROFESSIONAL_PROFILE_PHOTO(
            StoredFileAccessLevel.PUBLIC,
            "professional-profile-photos",
            Set.of("jpg", "jpeg", "png", "webp"),
            Set.of("image/jpeg", "image/png", "image/webp"),
            5_000_000L
    ),
    PROFESSIONAL_PORTFOLIO(
            StoredFileAccessLevel.PUBLIC,
            "professional-portfolios",
            Set.of("jpg", "jpeg", "png", "webp"),
            Set.of("image/jpeg", "image/png", "image/webp"),
            10_000_000L
    ),
    REPORT_ATTACHMENT(
            StoredFileAccessLevel.CONFIDENTIAL,
            "report-attachments",
            Set.of("jpg", "jpeg", "png", "webp", "pdf"),
            Set.of("image/jpeg", "image/png", "image/webp", "application/pdf"),
            20_000_000L
    ),
    REPORT_EVIDENCE(
            StoredFileAccessLevel.CONFIDENTIAL,
            "report-evidences",
            Set.of("jpg", "jpeg", "png", "webp", "pdf"),
            Set.of("image/jpeg", "image/png", "image/webp", "application/pdf"),
            20_000_000L
    );

    private final StoredFileAccessLevel defaultAccessLevel;
    private final String storageSegment;
    private final Set<String> allowedExtensions;
    private final Set<String> allowedContentTypes;
    private final long maximumSizeInBytes;

    StoredFilePurpose(
            StoredFileAccessLevel defaultAccessLevel,
            String storageSegment,
            Set<String> allowedExtensions,
            Set<String> allowedContentTypes,
            long maximumSizeInBytes
    ) {
        this.defaultAccessLevel = defaultAccessLevel;
        this.storageSegment = storageSegment;
        this.allowedExtensions = allowedExtensions;
        this.allowedContentTypes = allowedContentTypes;
        this.maximumSizeInBytes = maximumSizeInBytes;
    }

    StoredFileAccessLevel defaultAccessLevel() {
        return defaultAccessLevel;
    }

    String storageSegment() {
        return storageSegment;
    }

    boolean allowsExtension(String fileExtension) {
        return allowedExtensions.contains(fileExtension);
    }

    boolean allowsContentType(String contentType) {
        return allowedContentTypes.contains(contentType);
    }

    boolean allowsSize(long sizeInBytes) {
        return sizeInBytes > 0 && sizeInBytes <= maximumSizeInBytes;
    }
}
