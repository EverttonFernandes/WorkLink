CREATE TABLE worklink.customer_profile_preferences (
    customer_identifier UUID PRIMARY KEY
        REFERENCES worklink.customer_accounts (customer_identifier) ON DELETE CASCADE,
    whatsapp_notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    profile_personalization_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE worklink.customer_saved_professionals (
    customer_identifier UUID NOT NULL
        REFERENCES worklink.customer_accounts (customer_identifier) ON DELETE CASCADE,
    professional_identifier UUID NOT NULL
        REFERENCES worklink.professionals (professional_identifier) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (customer_identifier, professional_identifier)
);

CREATE INDEX customer_saved_professionals_customer_idx
    ON worklink.customer_saved_professionals (customer_identifier, created_at DESC);
