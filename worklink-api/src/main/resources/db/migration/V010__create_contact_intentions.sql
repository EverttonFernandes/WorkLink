CREATE TABLE worklink.contact_intentions (
    contact_intent_identifier UUID PRIMARY KEY,
    customer_identifier UUID NOT NULL REFERENCES worklink.customer_accounts (customer_identifier),
    professional_identifier UUID NOT NULL REFERENCES worklink.professionals (professional_identifier),
    professional_whatsapp_number VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX contact_intentions_customer_created_index
    ON worklink.contact_intentions (customer_identifier, created_at DESC);

CREATE INDEX contact_intentions_professional_created_index
    ON worklink.contact_intentions (professional_identifier, created_at DESC);
