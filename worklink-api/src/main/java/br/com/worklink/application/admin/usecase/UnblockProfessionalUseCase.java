package br.com.worklink.application.admin.usecase;

import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.domain.professional.Professional;

import java.util.UUID;

public class UnblockProfessionalUseCase {

    private static final String PROFESSIONAL_NOT_FOUND_MESSAGE = "Profissional nao encontrado.";

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final UpdateProfessionalPort updateProfessionalPort;

    public UnblockProfessionalUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            UpdateProfessionalPort updateProfessionalPort
    ) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.updateProfessionalPort = updateProfessionalPort;
    }

    public AdministrativeProfessionalResponse unblockProfessional(UUID professionalIdentifier) {
        Professional professional = loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(professionalIdentifier)
                .orElseThrow(() -> new ResourceNotFoundException(PROFESSIONAL_NOT_FOUND_MESSAGE));
        return AdministrativeProfessionalResponse.fromProfessional(
                updateProfessionalPort.updateProfessional(professional.unblockProfessional())
        );
    }
}
