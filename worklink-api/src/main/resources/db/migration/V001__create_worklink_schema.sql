CREATE SCHEMA IF NOT EXISTS worklink;

CREATE TABLE IF NOT EXISTS worklink.database_migration_marker (
    marker_identifier UUID PRIMARY KEY,
    marker_description VARCHAR(120) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);
