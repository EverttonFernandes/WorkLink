CREATE TABLE worklink.customer_accounts (
    customer_identifier UUID PRIMARY KEY,
    phone_number VARCHAR(32) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE TABLE worklink.authentication_otp_challenges (
    challenge_identifier UUID PRIMARY KEY,
    phone_number VARCHAR(32) NOT NULL,
    otp_hash VARCHAR(128) NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX authentication_otp_challenges_phone_number_index
    ON worklink.authentication_otp_challenges (phone_number, used, created_at DESC);

CREATE TABLE worklink.authentication_refresh_sessions (
    session_identifier UUID PRIMARY KEY,
    customer_identifier UUID NOT NULL REFERENCES worklink.customer_accounts (customer_identifier),
    refresh_token_hash VARCHAR(128) NOT NULL UNIQUE,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX authentication_refresh_sessions_customer_index
    ON worklink.authentication_refresh_sessions (customer_identifier, revoked, expires_at);
