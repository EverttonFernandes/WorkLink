CREATE TABLE worklink.professional_reports (
    professional_report_identifier UUID PRIMARY KEY,
    professional_identifier UUID NOT NULL REFERENCES worklink.professionals (professional_identifier),
    reporter_identifier UUID NOT NULL,
    report_reason VARCHAR(40) NOT NULL,
    description TEXT,
    evidence_file_identifier UUID REFERENCES worklink.stored_files (file_identifier),
    serious_case BOOLEAN NOT NULL,
    authority_guidance TEXT,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_professional_reports_professional_identifier
    ON worklink.professional_reports (professional_identifier);

CREATE INDEX idx_professional_reports_created_at
    ON worklink.professional_reports (created_at);
