package br.com.worklink.application.professional.port;

import br.com.worklink.domain.professional.Professional;



@FunctionalInterface
public interface SaveProfessionalPort {

    Professional saveProfessional(Professional professional);
}
