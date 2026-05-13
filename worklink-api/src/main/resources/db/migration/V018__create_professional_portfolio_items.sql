CREATE TABLE IF NOT EXISTS worklink.professional_portfolio_items (
    portfolio_item_identifier UUID PRIMARY KEY,
    professional_identifier UUID NOT NULL REFERENCES worklink.professionals (professional_identifier),
    file_identifier UUID NOT NULL REFERENCES worklink.stored_files (file_identifier),
    title VARCHAR(120) NOT NULL,
    description VARCHAR(500),
    display_order INTEGER NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT professional_portfolio_items_display_order_check CHECK (display_order >= 0),
    CONSTRAINT professional_portfolio_items_unique_file_per_professional UNIQUE (professional_identifier, file_identifier)
);

CREATE INDEX IF NOT EXISTS professional_portfolio_items_professional_index
    ON worklink.professional_portfolio_items (professional_identifier, active, display_order);
