ALTER TABLE worklink.professionals
    ADD COLUMN IF NOT EXISTS phone_number_verified BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS professionals_phone_number_verified_index
    ON worklink.professionals (phone_number_verified);
