package br.com.worklink.application.contact.port;

import java.util.UUID;



@FunctionalInterface
public interface DismissPostContactFeedbackRequestPort {

    boolean dismissPostContactFeedbackRequest(UUID customerIdentifier, UUID contactIntentIdentifier);
}
