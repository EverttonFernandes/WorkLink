package br.com.worklink.api.professional;

import java.util.UUID;

public record RegisterBasicProfessionalHttpRequest(
        String professionalName,
        String whatsappNumber,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String shortDescription
) {
}
