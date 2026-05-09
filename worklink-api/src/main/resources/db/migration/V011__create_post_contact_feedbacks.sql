CREATE TABLE worklink.post_contact_feedbacks (
    post_contact_feedback_identifier UUID PRIMARY KEY,
    contact_intent_identifier UUID NOT NULL REFERENCES worklink.contact_intentions (contact_intent_identifier),
    customer_identifier UUID NOT NULL REFERENCES worklink.customer_accounts (customer_identifier),
    conversation_outcome VARCHAR(60) NOT NULL,
    contact_responsiveness VARCHAR(60) NOT NULL,
    service_execution_outcome VARCHAR(60) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX post_contact_feedbacks_contact_intent_index
    ON worklink.post_contact_feedbacks (contact_intent_identifier);

CREATE INDEX post_contact_feedbacks_customer_created_index
    ON worklink.post_contact_feedbacks (customer_identifier, created_at DESC);
