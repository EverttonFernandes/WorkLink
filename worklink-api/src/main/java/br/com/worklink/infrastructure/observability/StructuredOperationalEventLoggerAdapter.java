package br.com.worklink.infrastructure.observability;

import br.com.worklink.application.observability.port.RecordOperationalEventPort;
import br.com.worklink.application.observability.usecase.OperationalEvent;
import br.com.worklink.application.observability.usecase.OperationalEventSeverity;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.event.Level;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.stream.Collectors;

@Component
public class StructuredOperationalEventLoggerAdapter implements RecordOperationalEventPort {

    private static final Logger LOGGER = LoggerFactory.getLogger(StructuredOperationalEventLoggerAdapter.class);

    private final SensitiveLogValueSanitizer sensitiveLogValueSanitizer;

    public StructuredOperationalEventLoggerAdapter(SensitiveLogValueSanitizer sensitiveLogValueSanitizer) {
        this.sensitiveLogValueSanitizer = sensitiveLogValueSanitizer;
    }

    @Override
    public void recordOperationalEvent(OperationalEvent operationalEvent) {
        String structuredMessage = "event_type=%s severity=%s message=\"%s\" context=\"%s\"".formatted(
                operationalEvent.operationalEventType().name(),
                operationalEvent.operationalEventSeverity().name(),
                sensitiveLogValueSanitizer.sanitize(operationalEvent.message()),
                sanitizeContext(operationalEvent)
        );

        if (operationalEvent.operationalEventSeverity() == OperationalEventSeverity.ERROR) {
            LOGGER.error(structuredMessage);
        } else if (operationalEvent.operationalEventSeverity() == OperationalEventSeverity.WARN) {
            LOGGER.warn(structuredMessage);
        } else {
            LOGGER.atLevel(Level.INFO).log(structuredMessage);
        }
    }

    private String sanitizeContext(OperationalEvent operationalEvent) {
        return operationalEvent.safeContext()
                .entrySet()
                .stream()
                .sorted(Comparator.comparing(entry -> entry.getKey()))
                .map(entry -> entry.getKey() + "=" + sensitiveLogValueSanitizer.sanitize(entry.getValue()))
                .collect(Collectors.joining(","));
    }
}
