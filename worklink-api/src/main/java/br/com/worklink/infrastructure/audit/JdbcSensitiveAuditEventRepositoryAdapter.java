package br.com.worklink.infrastructure.audit;

import br.com.worklink.application.audit.port.SaveSensitiveAuditEventPort;
import br.com.worklink.application.audit.usecase.SensitiveAuditEvent;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;

@Repository
public class JdbcSensitiveAuditEventRepositoryAdapter implements SaveSensitiveAuditEventPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcSensitiveAuditEventRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public SensitiveAuditEvent saveSensitiveAuditEvent(SensitiveAuditEvent sensitiveAuditEvent) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.sensitive_audit_events (
                    event_identifier,
                    author_identifier,
                    author_profile,
                    sensitive_action,
                    target_type,
                    target_identifier,
                    audit_outcome,
                    occurred_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                sensitiveAuditEvent.eventIdentifier(),
                sensitiveAuditEvent.authorIdentifier(),
                sensitiveAuditEvent.authorProfile().name(),
                sensitiveAuditEvent.sensitiveAuditAction().name(),
                sensitiveAuditEvent.sensitiveAuditTargetType().name(),
                sensitiveAuditEvent.targetIdentifier(),
                sensitiveAuditEvent.sensitiveAuditOutcome().name(),
                Timestamp.from(sensitiveAuditEvent.occurredAt())
        );
        return sensitiveAuditEvent;
    }
}
