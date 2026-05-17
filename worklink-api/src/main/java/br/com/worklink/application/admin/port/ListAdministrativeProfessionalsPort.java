package br.com.worklink.application.admin.port;

import br.com.worklink.domain.professional.Professional;

import java.util.List;



@FunctionalInterface
public interface ListAdministrativeProfessionalsPort {

    List<Professional> listAdministrativeProfessionals();
}
