package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.domain.professional.Professional;

import java.util.UUID;

public class LoadProfessionalDetailUseCase {

    private static final String PROFESSIONAL_NOT_FOUND_MESSAGE = "Profissional nao encontrado.";

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;

    public LoadProfessionalDetailUseCase(LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
    }

    public ProfessionalDetailResponse loadProfessionalDetail(UUID professionalIdentifier) {
        Professional professional = loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(professionalIdentifier)
                .filter(loadedProfessional -> !loadedProfessional.blocked())
                .orElseThrow(() -> new ResourceNotFoundException(PROFESSIONAL_NOT_FOUND_MESSAGE));
        return ProfessionalDetailResponse.fromProfessional(professional);
    }
}
