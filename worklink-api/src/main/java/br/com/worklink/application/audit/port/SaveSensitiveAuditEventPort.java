package br.com.worklink.application.audit.port;

import br.com.worklink.application.audit.usecase.SensitiveAuditEvent;

public interface SaveSensitiveAuditEventPort {

    SensitiveAuditEvent saveSensitiveAuditEvent(SensitiveAuditEvent sensitiveAuditEvent);
}
