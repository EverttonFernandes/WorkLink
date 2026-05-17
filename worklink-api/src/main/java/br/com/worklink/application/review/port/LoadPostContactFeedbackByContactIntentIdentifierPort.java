package br.com.worklink.application.review.port;

import br.com.worklink.domain.contact.PostContactFeedback;

import java.util.Optional;
import java.util.UUID;



@FunctionalInterface
public interface LoadPostContactFeedbackByContactIntentIdentifierPort {

    Optional<PostContactFeedback> loadPostContactFeedbackByContactIntentIdentifier(UUID contactIntentIdentifier);
}
