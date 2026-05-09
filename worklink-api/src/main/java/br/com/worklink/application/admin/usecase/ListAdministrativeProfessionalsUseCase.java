package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.admin.port.ListAdministrativeProfessionalsPort;

import java.util.List;

public class ListAdministrativeProfessionalsUseCase {

    private final ListAdministrativeProfessionalsPort listAdministrativeProfessionalsPort;

    public ListAdministrativeProfessionalsUseCase(
            ListAdministrativeProfessionalsPort listAdministrativeProfessionalsPort
    ) {
        this.listAdministrativeProfessionalsPort = listAdministrativeProfessionalsPort;
    }

    public List<AdministrativeProfessionalResponse> listAdministrativeProfessionals() {
        return listAdministrativeProfessionalsPort.listAdministrativeProfessionals().stream()
                .map(AdministrativeProfessionalResponse::fromProfessional)
                .toList();
    }
}
