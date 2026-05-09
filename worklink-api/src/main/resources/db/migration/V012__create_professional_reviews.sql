CREATE TABLE IF NOT EXISTS worklink.professional_reviews (
    professional_review_identifier UUID PRIMARY KEY,
    contact_intent_identifier UUID NOT NULL UNIQUE
        REFERENCES worklink.contact_intentions(contact_intent_identifier),
    post_contact_feedback_identifier UUID NOT NULL
        REFERENCES worklink.post_contact_feedbacks(post_contact_feedback_identifier),
    professional_identifier UUID NOT NULL
        REFERENCES worklink.professionals(professional_identifier),
    internal_author_identifier UUID NOT NULL
        REFERENCES worklink.customer_accounts(customer_identifier),
    star_rating INTEGER NOT NULL CHECK (star_rating BETWEEN 1 AND 5),
    comment TEXT,
    anonymous_to_public BOOLEAN NOT NULL,
    public_author_identifier UUID
        REFERENCES worklink.customer_accounts(customer_identifier),
    public_author_display_name VARCHAR(120) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);
