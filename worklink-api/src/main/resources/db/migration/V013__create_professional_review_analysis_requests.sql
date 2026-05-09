CREATE TABLE IF NOT EXISTS worklink.professional_review_analysis_requests (
    review_analysis_request_identifier UUID PRIMARY KEY,
    professional_review_identifier UUID NOT NULL
        REFERENCES worklink.professional_reviews(professional_review_identifier),
    professional_identifier UUID NOT NULL
        REFERENCES worklink.professionals(professional_identifier),
    requested_by_professional_identifier UUID NOT NULL
        REFERENCES worklink.professionals(professional_identifier),
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);
