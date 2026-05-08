package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalAvailabilityStatus;

public class CompleteProfessionalProfileUseCase {

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final UpdateProfessionalPort updateProfessionalPort;

    public CompleteProfessionalProfileUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            UpdateProfessionalPort updateProfessionalPort
    ) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.updateProfessionalPort = updateProfessionalPort;
    }

    public ProfessionalResponse completeProfessionalProfile(CompleteProfessionalProfileRequest request) {
        Professional professional = loadProfessionalByIdentifierPort
                .loadProfessionalByIdentifier(request.professionalIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException("O profissional informado nao foi encontrado."));

        try {
            Professional completedProfessional = professional.completeProgressiveProfile(
                    request.profilePhotoFileIdentifier(),
                    request.documentNumber(),
                    request.usefulLink(),
                    request.portfolioDescription(),
                    request.serviceDescription(),
                    ProfessionalAvailabilityStatus.fromRequiredName(request.availabilityStatus())
            );

            return ProfessionalResponse.fromProfessional(updateProfessionalPort.updateProfessional(completedProfessional));
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException(exception.getMessage(), exception);
        }
    }
}
