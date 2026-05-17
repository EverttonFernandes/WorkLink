package br.com.worklink.application.contact.port;

import java.time.Instant;
import java.util.UUID;



@FunctionalInterface
public interface SavePostContactFeedbackRequestPort {

    void savePendingPostContactFeedbackRequest(
            UUID customerIdentifier,
            UUID contactIntentIdentifier,
            Instant createdAt
    );
}
