package br.com.worklink.application.audit.usecase;

import br.com.worklink.application.audit.port.SaveSensitiveAuditEventPort;
import br.com.worklink.application.authentication.port.CurrentTimePort;

public class RecordSensitiveAuditEventUseCase {

    private final SaveSensitiveAuditEventPort saveSensitiveAuditEventPort;
    private final CurrentTimePort currentTimePort;

    public RecordSensitiveAuditEventUseCase(
            SaveSensitiveAuditEventPort saveSensitiveAuditEventPort,
            CurrentTimePort currentTimePort
    ) {
        this.saveSensitiveAuditEventPort = saveSensitiveAuditEventPort;
        this.currentTimePort = currentTimePort;
    }

    public SensitiveAuditEvent recordSensitiveAuditEvent(RecordSensitiveAuditEventRequest request) {
        SensitiveAuditEvent sensitiveAuditEvent = SensitiveAuditEvent.registerSensitiveAuditEvent(
                request.authenticatedPrincipal(),
                request.sensitiveAuditAction(),
                request.sensitiveAuditTargetType(),
                request.targetIdentifier(),
                request.sensitiveAuditOutcome(),
                currentTimePort.currentInstant()
        );
        return saveSensitiveAuditEventPort.saveSensitiveAuditEvent(sensitiveAuditEvent);
    }
}
