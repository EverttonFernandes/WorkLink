ALTER TABLE worklink.professionals
    ADD COLUMN profile_photo_file_identifier UUID REFERENCES worklink.stored_files (file_identifier),
    ADD COLUMN document_number VARCHAR(32),
    ADD COLUMN useful_link VARCHAR(255),
    ADD COLUMN portfolio_description VARCHAR(500),
    ADD COLUMN service_description VARCHAR(500),
    ADD COLUMN profile_completeness_percentage INTEGER NOT NULL DEFAULT 50;

ALTER TABLE worklink.professionals
    ADD CONSTRAINT professionals_completeness_percentage_check
        CHECK (profile_completeness_percentage BETWEEN 0 AND 100);
