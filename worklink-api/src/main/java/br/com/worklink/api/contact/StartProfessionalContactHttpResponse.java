package br.com.worklink.api.contact;

import br.com.worklink.application.contact.usecase.StartProfessionalContactResponse;

import java.time.Instant;
import java.util.UUID;

public record StartProfessionalContactHttpResponse(
        UUID contactIntentIdentifier,
        UUID professionalIdentifier,
        String professionalName,
        String whatsappContactLink,
        Instant createdAt,
        String externalNegotiationNotice,
        String noServiceGuaranteeNotice
) {

    public static StartProfessionalContactHttpResponse fromUseCaseResponse(
            StartProfessionalContactResponse startProfessionalContactResponse
    ) {
        return new StartProfessionalContactHttpResponse(
                startProfessionalContactResponse.contactIntentIdentifier(),
                startProfessionalContactResponse.professionalIdentifier(),
                startProfessionalContactResponse.professionalName(),
                startProfessionalContactResponse.whatsappContactLink(),
                startProfessionalContactResponse.createdAt(),
                "A negociacao acontece fora do Profissional Perto pelo WhatsApp.",
                "O Profissional Perto nao garante a execucao do servico contratado."
        );
    }
}
