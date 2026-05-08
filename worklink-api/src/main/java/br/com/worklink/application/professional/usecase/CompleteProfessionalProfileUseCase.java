package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalAvailabilityStatus;

public class CompleteProfessionalProfileUseCase {

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final UpdateProfessionalPort updateProfessionalPort;
    private final ProtectSensitiveValuePort protectSensitiveValuePort;

    public CompleteProfessionalProfileUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            UpdateProfessionalPort updateProfessionalPort,
            ProtectSensitiveValuePort protectSensitiveValuePort
    ) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.updateProfessionalPort = updateProfessionalPort;
        this.protectSensitiveValuePort = protectSensitiveValuePort;
    }

    public ProfessionalResponse completeProfessionalProfile(CompleteProfessionalProfileRequest request) {
        Professional professional = loadProfessionalByIdentifierPort
                .loadProfessionalByIdentifier(request.professionalIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException("O profissional informado nao foi encontrado."));

        try {
            Professional completedProfessional = professional.completeProgressiveProfile(
                    request.profilePhotoFileIdentifier(),
                    protectOptionalDocumentNumber(request.documentNumber()),
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

    private String protectOptionalDocumentNumber(String documentNumber) {
        if (documentNumber == null || documentNumber.isBlank()) {
            return null;
        }
        return protectSensitiveValuePort.protectSensitiveValue(
                documentNumber,
                ProtectedSensitiveValuePurpose.DOCUMENT_NUMBER
        );
    }
}
