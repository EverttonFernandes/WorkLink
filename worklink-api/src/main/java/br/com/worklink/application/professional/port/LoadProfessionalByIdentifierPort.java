package br.com.worklink.application.professional.port;

import br.com.worklink.domain.professional.Professional;

import java.util.Optional;
import java.util.UUID;



@FunctionalInterface
public interface LoadProfessionalByIdentifierPort {

    Optional<Professional> loadProfessionalByIdentifier(UUID professionalIdentifier);
}
