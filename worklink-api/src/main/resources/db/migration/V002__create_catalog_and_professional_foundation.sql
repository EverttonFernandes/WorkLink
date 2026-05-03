CREATE TABLE worklink.service_categories (
    category_identifier UUID PRIMARY KEY,
    category_name VARCHAR(80) NOT NULL,
    category_slug VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE worklink.service_cities (
    city_identifier UUID PRIMARY KEY,
    city_name VARCHAR(80) NOT NULL,
    state_code CHAR(2) NOT NULL,
    city_slug VARCHAR(120) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE worklink.professionals (
    professional_identifier UUID PRIMARY KEY,
    professional_name VARCHAR(120) NOT NULL,
    whatsapp_number VARCHAR(20) NOT NULL,
    city_identifier UUID NOT NULL REFERENCES worklink.service_cities (city_identifier),
    category_identifier UUID NOT NULL REFERENCES worklink.service_categories (category_identifier),
    short_description VARCHAR(280) NOT NULL,
    profile_classification VARCHAR(40) NOT NULL,
    quality_guarantee BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX professionals_city_identifier_index ON worklink.professionals (city_identifier);
CREATE INDEX professionals_category_identifier_index ON worklink.professionals (category_identifier);
