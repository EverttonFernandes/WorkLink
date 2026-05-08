CREATE TABLE worklink.stored_files (
    file_identifier UUID PRIMARY KEY,
    file_purpose VARCHAR(60) NOT NULL,
    access_level VARCHAR(30) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    content_type VARCHAR(120) NOT NULL,
    file_extension VARCHAR(20) NOT NULL,
    size_in_bytes BIGINT NOT NULL,
    storage_object_key VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT stored_files_size_positive_check CHECK (size_in_bytes > 0),
    CONSTRAINT stored_files_access_level_check CHECK (access_level IN ('PUBLIC', 'SEMI_PUBLIC', 'CONFIDENTIAL')),
    CONSTRAINT stored_files_purpose_check CHECK (
        file_purpose IN (
            'PROFESSIONAL_PROFILE_PHOTO',
            'PROFESSIONAL_PORTFOLIO',
            'REPORT_ATTACHMENT',
            'REPORT_EVIDENCE'
        )
    )
);

CREATE INDEX stored_files_access_level_index ON worklink.stored_files (access_level);
CREATE INDEX stored_files_file_purpose_index ON worklink.stored_files (file_purpose);
