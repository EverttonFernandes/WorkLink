ALTER TABLE worklink.professionals
    ADD COLUMN blocked BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX idx_professionals_blocked
    ON worklink.professionals (blocked);
