package br.com.worklink.application.professional.port;

import br.com.worklink.domain.professional.Professional;

import java.util.List;



@FunctionalInterface
public interface ListProfessionalsPort {

    List<Professional> listProfessionals(ProfessionalSearchCriteria professionalSearchCriteria);
}
