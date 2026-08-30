package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import java.util.List;

public class ListProfessionalsUseCase {

    private final ListProfessionalsPort listProfessionalsPort;

    public ListProfessionalsUseCase(ListProfessionalsPort listProfessionalsPort) {
        this.listProfessionalsPort = listProfessionalsPort;
    }

    public List<ProfessionalSummaryResponse> listProfessionals(ProfessionalSearchCriteria professionalSearchCriteria) {
        return listProfessionalsPort.listProfessionals(professionalSearchCriteria).stream()
                .map(ProfessionalSummaryResponse::fromProfessional)
                .toList();
    }
}
