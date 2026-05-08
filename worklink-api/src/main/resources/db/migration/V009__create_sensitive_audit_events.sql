CREATE TABLE worklink.sensitive_audit_events (
    event_identifier UUID PRIMARY KEY,
    author_identifier UUID NOT NULL,
    author_profile VARCHAR(32) NOT NULL,
    sensitive_action VARCHAR(80) NOT NULL,
    target_type VARCHAR(80) NOT NULL,
    target_identifier UUID,
    audit_outcome VARCHAR(32) NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL
);

CREATE INDEX idx_sensitive_audit_events_author
    ON worklink.sensitive_audit_events (author_identifier, occurred_at DESC);

CREATE INDEX idx_sensitive_audit_events_action
    ON worklink.sensitive_audit_events (sensitive_action, occurred_at DESC);

CREATE INDEX idx_sensitive_audit_events_target
    ON worklink.sensitive_audit_events (target_type, target_identifier, occurred_at DESC);
