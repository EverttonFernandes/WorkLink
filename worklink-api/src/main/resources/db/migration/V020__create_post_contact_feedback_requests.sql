CREATE TABLE worklink.post_contact_feedback_requests (
    contact_intent_identifier UUID PRIMARY KEY
        REFERENCES worklink.contact_intentions (contact_intent_identifier),
    customer_identifier UUID NOT NULL
        REFERENCES worklink.customer_accounts (customer_identifier),
    request_status VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX post_contact_feedback_requests_customer_status_index
    ON worklink.post_contact_feedback_requests (customer_identifier, request_status, updated_at DESC);

INSERT INTO worklink.post_contact_feedback_requests (
    contact_intent_identifier,
    customer_identifier,
    request_status,
    created_at,
    updated_at
)
SELECT contacts.contact_intent_identifier,
       contacts.customer_identifier,
       CASE
           WHEN feedbacks.post_contact_feedback_identifier IS NULL THEN 'PENDING'
           ELSE 'ANSWERED'
       END,
       contacts.created_at,
       COALESCE(feedbacks.created_at, contacts.created_at)
FROM worklink.contact_intentions contacts
LEFT JOIN worklink.post_contact_feedbacks feedbacks
    ON feedbacks.contact_intent_identifier = contacts.contact_intent_identifier
ON CONFLICT (contact_intent_identifier) DO NOTHING;

CREATE UNIQUE INDEX post_contact_feedbacks_contact_intent_unique_index
    ON worklink.post_contact_feedbacks (contact_intent_identifier);
