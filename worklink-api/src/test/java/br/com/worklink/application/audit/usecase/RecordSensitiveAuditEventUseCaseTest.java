package br.com.worklink.application.audit.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.audit.port.SaveSensitiveAuditEventPort;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RecordSensitiveAuditEventUseCaseTest {

    private static final Instant CURRENT_INSTANT = Instant.parse("2026-05-08T21:00:00Z");

    @Test
    @DisplayName("Deve registrar autoria interna de acao sensivel com metadados minimos")
    void shouldRecordInternalAuthorshipForSensitiveActionWithMinimalMetadata() {
        // GIVEN
        AtomicReference<SensitiveAuditEvent> savedEvent = new AtomicReference<>();
        SaveSensitiveAuditEventPort saveSensitiveAuditEventPort = sensitiveAuditEvent -> {
            savedEvent.set(sensitiveAuditEvent);
            return sensitiveAuditEvent;
        };
        CurrentTimePort currentTimePort = () -> CURRENT_INSTANT;
        RecordSensitiveAuditEventUseCase useCase = new RecordSensitiveAuditEventUseCase(
                saveSensitiveAuditEventPort,
                currentTimePort
        );
        AuthenticatedPrincipal administratorPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.ADMINISTRATOR
        );
        UUID targetIdentifier = UUID.randomUUID();

        // WHEN
        SensitiveAuditEvent auditEvent = useCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                administratorPrincipal,
                SensitiveAuditAction.ACCESS_INTERNAL_REVIEW_AUTHORSHIP,
                SensitiveAuditTargetType.REVIEW,
                targetIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));

        // THEN
        assertThat(savedEvent.get()).isEqualTo(auditEvent);
        assertThat(auditEvent.eventIdentifier()).isNotNull();
        assertThat(auditEvent.authorIdentifier()).isEqualTo(administratorPrincipal.principalIdentifier());
        assertThat(auditEvent.authorProfile()).isEqualTo(AuthenticatedProfile.ADMINISTRATOR);
        assertThat(auditEvent.sensitiveAuditAction()).isEqualTo(SensitiveAuditAction.ACCESS_INTERNAL_REVIEW_AUTHORSHIP);
        assertThat(auditEvent.sensitiveAuditTargetType()).isEqualTo(SensitiveAuditTargetType.REVIEW);
        assertThat(auditEvent.targetIdentifier()).isEqualTo(targetIdentifier);
        assertThat(auditEvent.sensitiveAuditOutcome()).isEqualTo(SensitiveAuditOutcome.SUCCESS);
        assertThat(auditEvent.occurredAt()).isEqualTo(CURRENT_INSTANT);
    }

    @Test
    @DisplayName("Deve suportar auditoria futura de evidencia confidencial sem payload sensivel")
    void shouldSupportFutureConfidentialEvidenceAuditWithoutSensitivePayload() {
        // GIVEN
        RecordSensitiveAuditEventUseCase useCase = new RecordSensitiveAuditEventUseCase(
                sensitiveAuditEvent -> sensitiveAuditEvent,
                () -> CURRENT_INSTANT
        );
        AuthenticatedPrincipal administratorPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.ADMINISTRATOR
        );
        UUID storedFileIdentifier = UUID.randomUUID();

        // WHEN
        SensitiveAuditEvent auditEvent = useCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                administratorPrincipal,
                SensitiveAuditAction.ACCESS_CONFIDENTIAL_EVIDENCE,
                SensitiveAuditTargetType.STORED_FILE,
                storedFileIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));

        // THEN
        assertThat(auditEvent.sensitiveAuditAction()).isEqualTo(SensitiveAuditAction.ACCESS_CONFIDENTIAL_EVIDENCE);
        assertThat(auditEvent.sensitiveAuditTargetType()).isEqualTo(SensitiveAuditTargetType.STORED_FILE);
        assertThat(auditEvent.targetIdentifier()).isEqualTo(storedFileIdentifier);
    }

    @Test
    @DisplayName("Deve rejeitar auditoria sem principal autenticado")
    void shouldRejectAuditWithoutAuthenticatedPrincipal() {
        // GIVEN
        RecordSensitiveAuditEventUseCase useCase = new RecordSensitiveAuditEventUseCase(
                sensitiveAuditEvent -> sensitiveAuditEvent,
                () -> CURRENT_INSTANT
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                null,
                SensitiveAuditAction.REGISTER_SERVICE_CATEGORY,
                SensitiveAuditTargetType.SERVICE_CATEGORY,
                UUID.randomUUID(),
                SensitiveAuditOutcome.SUCCESS
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O principal autenticado da auditoria e obrigatorio.");
    }

    @Test
    @DisplayName("Deve rejeitar auditoria sem acao sensivel")
    void shouldRejectAuditWithoutSensitiveAction() {
        // GIVEN
        RecordSensitiveAuditEventUseCase useCase = new RecordSensitiveAuditEventUseCase(
                sensitiveAuditEvent -> sensitiveAuditEvent,
                () -> CURRENT_INSTANT
        );
        AuthenticatedPrincipal administratorPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.ADMINISTRATOR
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                administratorPrincipal,
                null,
                SensitiveAuditTargetType.SERVICE_CATEGORY,
                UUID.randomUUID(),
                SensitiveAuditOutcome.SUCCESS
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A acao sensivel da auditoria e obrigatoria.");
    }

    @Test
    @DisplayName("Deve rejeitar restauracao de auditoria sem identificador do evento")
    void shouldRejectAuditRestorationWithoutEventIdentifier() {
        // GIVEN
        UUID authorIdentifier = UUID.randomUUID();

        // WHEN / THEN
        assertThatThrownBy(() -> SensitiveAuditEvent.restoreSensitiveAuditEvent(
                null,
                authorIdentifier,
                AuthenticatedProfile.ADMINISTRATOR,
                SensitiveAuditAction.REGISTER_SERVICE_CITY,
                SensitiveAuditTargetType.SERVICE_CITY,
                UUID.randomUUID(),
                SensitiveAuditOutcome.SUCCESS,
                CURRENT_INSTANT
        )).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O identificador do evento de auditoria e obrigatorio.");
    }

    @Test
    @DisplayName("Deve rejeitar restauracao de auditoria sem autor interno")
    void shouldRejectAuditRestorationWithoutInternalAuthor() {
        // GIVEN
        UUID eventIdentifier = UUID.randomUUID();

        // WHEN / THEN
        assertThatThrownBy(() -> SensitiveAuditEvent.restoreSensitiveAuditEvent(
                eventIdentifier,
                null,
                AuthenticatedProfile.ADMINISTRATOR,
                SensitiveAuditAction.REGISTER_SERVICE_CITY,
                SensitiveAuditTargetType.SERVICE_CITY,
                UUID.randomUUID(),
                SensitiveAuditOutcome.SUCCESS,
                CURRENT_INSTANT
        )).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O autor interno do evento de auditoria e obrigatorio.");
    }

    @Test
    @DisplayName("Deve rejeitar restauracao de auditoria sem perfil do autor")
    void shouldRejectAuditRestorationWithoutAuthorProfile() {
        // GIVEN
        UUID eventIdentifier = UUID.randomUUID();
        UUID authorIdentifier = UUID.randomUUID();

        // WHEN / THEN
        assertThatThrownBy(() -> SensitiveAuditEvent.restoreSensitiveAuditEvent(
                eventIdentifier,
                authorIdentifier,
                null,
                SensitiveAuditAction.REGISTER_SERVICE_CITY,
                SensitiveAuditTargetType.SERVICE_CITY,
                UUID.randomUUID(),
                SensitiveAuditOutcome.SUCCESS,
                CURRENT_INSTANT
        )).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O perfil do autor da auditoria e obrigatorio.");
    }

    @Test
    @DisplayName("Deve rejeitar auditoria sem tipo de alvo")
    void shouldRejectAuditWithoutTargetType() {
        // GIVEN
        RecordSensitiveAuditEventUseCase useCase = new RecordSensitiveAuditEventUseCase(
                sensitiveAuditEvent -> sensitiveAuditEvent,
                () -> CURRENT_INSTANT
        );
        AuthenticatedPrincipal administratorPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.ADMINISTRATOR
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                administratorPrincipal,
                SensitiveAuditAction.REGISTER_SERVICE_CATEGORY,
                null,
                UUID.randomUUID(),
                SensitiveAuditOutcome.SUCCESS
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O tipo do alvo da auditoria e obrigatorio.");
    }

    @Test
    @DisplayName("Deve rejeitar auditoria sem resultado")
    void shouldRejectAuditWithoutOutcome() {
        // GIVEN
        RecordSensitiveAuditEventUseCase useCase = new RecordSensitiveAuditEventUseCase(
                sensitiveAuditEvent -> sensitiveAuditEvent,
                () -> CURRENT_INSTANT
        );
        AuthenticatedPrincipal administratorPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.ADMINISTRATOR
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                administratorPrincipal,
                SensitiveAuditAction.REGISTER_SERVICE_CATEGORY,
                SensitiveAuditTargetType.SERVICE_CATEGORY,
                UUID.randomUUID(),
                null
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O resultado da auditoria e obrigatorio.");
    }

    @Test
    @DisplayName("Deve rejeitar auditoria sem momento do evento")
    void shouldRejectAuditWithoutEventMoment() {
        // GIVEN
        RecordSensitiveAuditEventUseCase useCase = new RecordSensitiveAuditEventUseCase(
                sensitiveAuditEvent -> sensitiveAuditEvent,
                () -> null
        );
        AuthenticatedPrincipal administratorPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.ADMINISTRATOR
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                administratorPrincipal,
                SensitiveAuditAction.REGISTER_SERVICE_CATEGORY,
                SensitiveAuditTargetType.SERVICE_CATEGORY,
                UUID.randomUUID(),
                SensitiveAuditOutcome.SUCCESS
        ))).isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O momento do evento de auditoria e obrigatorio.");
    }
}
