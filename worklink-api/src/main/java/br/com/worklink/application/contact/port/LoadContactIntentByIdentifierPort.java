package br.com.worklink.application.contact.port;

import br.com.worklink.domain.contact.ContactIntent;

import java.util.Optional;
import java.util.UUID;

public interface LoadContactIntentByIdentifierPort {

    Optional<ContactIntent> loadContactIntentByIdentifier(UUID contactIntentIdentifier);
}
