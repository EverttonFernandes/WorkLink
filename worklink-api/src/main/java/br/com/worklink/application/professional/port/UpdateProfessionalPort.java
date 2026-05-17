package br.com.worklink.application.professional.port;

import br.com.worklink.domain.professional.Professional;



@FunctionalInterface
public interface UpdateProfessionalPort {

    Professional updateProfessional(Professional professional);
}
