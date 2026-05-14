ALTER TABLE worklink.professional_reviews
    ADD COLUMN hidden_from_public BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE worklink.professional_review_analysis_requests
    ADD COLUMN moderation_status VARCHAR(40) NOT NULL DEFAULT 'PENDING',
    ADD COLUMN moderation_decision VARCHAR(40),
    ADD COLUMN moderation_notes TEXT,
    ADD COLUMN decided_at TIMESTAMPTZ;

ALTER TABLE worklink.professional_reports
    ADD COLUMN moderation_status VARCHAR(40) NOT NULL DEFAULT 'PENDING',
    ADD COLUMN moderation_decision VARCHAR(40),
    ADD COLUMN moderation_notes TEXT,
    ADD COLUMN decided_at TIMESTAMPTZ;

CREATE INDEX idx_professional_review_analysis_requests_moderation_status
    ON worklink.professional_review_analysis_requests (moderation_status);

CREATE INDEX idx_professional_reports_moderation_status
    ON worklink.professional_reports (moderation_status);
