package br.com.worklink.infrastructure.audit;

import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditEvent;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class JdbcSensitiveAuditEventRepositoryAdapterTest {

    @Test
    @DisplayName("Deve persistir evento de auditoria sensivel usando JdbcTemplate")
    void shouldPersistSensitiveAuditEventUsingJdbcTemplate() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcSensitiveAuditEventRepositoryAdapter adapter = new JdbcSensitiveAuditEventRepositoryAdapter(jdbcTemplate);
        Instant occurredAt = Instant.parse("2026-05-08T21:10:00Z");
        SensitiveAuditEvent auditEvent = SensitiveAuditEvent.restoreSensitiveAuditEvent(
                UUID.randomUUID(),
                UUID.randomUUID(),
                AuthenticatedProfile.ADMINISTRATOR,
                SensitiveAuditAction.REGISTER_SERVICE_CITY,
                SensitiveAuditTargetType.SERVICE_CITY,
                UUID.randomUUID(),
                SensitiveAuditOutcome.SUCCESS,
                occurredAt
        );

        // WHEN
        SensitiveAuditEvent savedAuditEvent = adapter.saveSensitiveAuditEvent(auditEvent);

        // THEN
        assertThat(savedAuditEvent).isEqualTo(auditEvent);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(auditEvent.eventIdentifier()),
                eq(auditEvent.authorIdentifier()),
                eq(auditEvent.authorProfile().name()),
                eq(auditEvent.sensitiveAuditAction().name()),
                eq(auditEvent.sensitiveAuditTargetType().name()),
                eq(auditEvent.targetIdentifier()),
                eq(auditEvent.sensitiveAuditOutcome().name()),
                eq(Timestamp.from(occurredAt))
        );
    }
}
