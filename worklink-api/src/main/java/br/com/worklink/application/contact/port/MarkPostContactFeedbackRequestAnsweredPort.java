package br.com.worklink.application.contact.port;

import java.util.UUID;

public interface MarkPostContactFeedbackRequestAnsweredPort {

    void markPostContactFeedbackRequestAnswered(UUID customerIdentifier, UUID contactIntentIdentifier);
}
