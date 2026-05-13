package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.domain.professional.Professional;

public class ConfirmProfessionalPhoneVerificationUseCase {

    private static final String PROFESSIONAL_NOT_FOUND_MESSAGE = "O profissional informado nao foi encontrado.";
    private static final String INVALID_CODE_MESSAGE = "Nao foi possivel confirmar o telefone do profissional.";

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final UpdateProfessionalPort updateProfessionalPort;
    private final String expectedVerificationCode;

    public ConfirmProfessionalPhoneVerificationUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            UpdateProfessionalPort updateProfessionalPort,
            String expectedVerificationCode
    ) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.updateProfessionalPort = updateProfessionalPort;
        this.expectedVerificationCode = expectedVerificationCode;
    }

    public ProfessionalResponse confirmProfessionalPhoneVerification(ConfirmProfessionalPhoneVerificationRequest request) {
        Professional professional = loadProfessionalByIdentifierPort
                .loadProfessionalByIdentifier(request.professionalIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException(PROFESSIONAL_NOT_FOUND_MESSAGE));

        if (!expectedVerificationCode.equals(normalizedVerificationCode(request.verificationCode()))) {
            throw new ApplicationRuleViolationException(INVALID_CODE_MESSAGE);
        }

        return ProfessionalResponse.fromProfessional(updateProfessionalPort.updateProfessional(professional.verifyPhoneNumber()));
    }

    private String normalizedVerificationCode(String verificationCode) {
        if (verificationCode == null) {
            return "";
        }
        return verificationCode.trim();
    }
}

