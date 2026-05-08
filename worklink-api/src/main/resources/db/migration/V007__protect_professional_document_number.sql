ALTER TABLE worklink.professionals
    ADD COLUMN document_number_hash VARCHAR(128);

ALTER TABLE worklink.professionals
    DROP COLUMN document_number;

CREATE UNIQUE INDEX professionals_document_number_hash_index
    ON worklink.professionals (document_number_hash)
    WHERE document_number_hash IS NOT NULL;
