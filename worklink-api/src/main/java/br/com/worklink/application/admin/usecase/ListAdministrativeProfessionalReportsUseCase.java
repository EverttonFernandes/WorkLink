package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.admin.port.ListAdministrativeProfessionalReportsPort;

import java.util.List;

public class ListAdministrativeProfessionalReportsUseCase {

    private final ListAdministrativeProfessionalReportsPort listAdministrativeProfessionalReportsPort;

    public ListAdministrativeProfessionalReportsUseCase(
            ListAdministrativeProfessionalReportsPort listAdministrativeProfessionalReportsPort
    ) {
        this.listAdministrativeProfessionalReportsPort = listAdministrativeProfessionalReportsPort;
    }

    public List<AdministrativeProfessionalReportResponse> listAdministrativeProfessionalReports() {
        return listAdministrativeProfessionalReportsPort.listAdministrativeProfessionalReports().stream()
                .map(AdministrativeProfessionalReportResponse::fromProfessionalReport)
                .toList();
    }
}
