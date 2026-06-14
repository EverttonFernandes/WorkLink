CREATE TABLE worklink.local_authentication_accounts (
    customer_identifier UUID PRIMARY KEY REFERENCES worklink.customer_accounts (customer_identifier) ON DELETE CASCADE,
    full_name VARCHAR(160) NOT NULL,
    phone_number VARCHAR(32) NOT NULL,
    normalized_email_address VARCHAR(320) NOT NULL UNIQUE,
    password_hash VARCHAR(128) NOT NULL,
    legal_accepted BOOLEAN NOT NULL,
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_attempts INTEGER NOT NULL DEFAULT 0 CHECK (failed_login_attempts >= 0),
    blocked_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX local_authentication_accounts_phone_index
    ON worklink.local_authentication_accounts (phone_number);

CREATE TABLE worklink.password_recovery_challenges (
    challenge_identifier UUID PRIMARY KEY,
    customer_identifier UUID NOT NULL REFERENCES worklink.customer_accounts (customer_identifier) ON DELETE CASCADE,
    token_hash VARCHAR(128) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX password_recovery_challenges_customer_index
    ON worklink.password_recovery_challenges (customer_identifier, used, expires_at);
