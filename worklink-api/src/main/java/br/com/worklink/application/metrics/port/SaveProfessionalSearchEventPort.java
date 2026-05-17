package br.com.worklink.application.metrics.port;

import br.com.worklink.application.metrics.usecase.ProfessionalSearchEvent;



@FunctionalInterface
public interface SaveProfessionalSearchEventPort {

    ProfessionalSearchEvent saveProfessionalSearchEvent(ProfessionalSearchEvent professionalSearchEvent);
}
