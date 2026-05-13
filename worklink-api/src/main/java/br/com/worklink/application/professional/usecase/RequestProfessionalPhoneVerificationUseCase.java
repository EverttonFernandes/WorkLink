package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.domain.professional.Professional;

import java.time.Duration;

public class RequestProfessionalPhoneVerificationUseCase {

    private static final String PROFESSIONAL_NOT_FOUND_MESSAGE = "O profissional informado nao foi encontrado.";

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final CurrentTimePort currentTimePort;
    private final Duration verificationExpiration;

    public RequestProfessionalPhoneVerificationUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            CurrentTimePort currentTimePort,
            Duration verificationExpiration
    ) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.currentTimePort = currentTimePort;
        this.verificationExpiration = verificationExpiration;
    }

    public RequestProfessionalPhoneVerificationResponse requestProfessionalPhoneVerification(
            RequestProfessionalPhoneVerificationRequest request
    ) {
        Professional professional = loadProfessionalByIdentifierPort
                .loadProfessionalByIdentifier(request.professionalIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException(PROFESSIONAL_NOT_FOUND_MESSAGE));

        return new RequestProfessionalPhoneVerificationResponse(
                professional.professionalIdentifier(),
                "Codigo de verificacao enviado para o WhatsApp do profissional.",
                currentTimePort.currentInstant().plus(verificationExpiration)
        );
    }
}
