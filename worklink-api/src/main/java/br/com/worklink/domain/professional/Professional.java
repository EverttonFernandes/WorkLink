package br.com.worklink.domain.professional;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.util.UUID;

public record Professional(
        UUID professionalIdentifier,
        String professionalName,
        String whatsappNumber,
        UUID cityIdentifier,
        UUID categoryIdentifier,
        String shortDescription,
        ProfessionalProfileClassification profileClassification,
        boolean qualityGuarantee
) {

    public static Professional registerBasicProfessional(
            String professionalName,
            String whatsappNumber,
            UUID cityIdentifier,
            UUID categoryIdentifier,
            String shortDescription
    ) {
        return new Professional(
                UUID.randomUUID(),
                requireMeaningfulText(professionalName, "O nome do profissional e obrigatorio."),
                requireMeaningfulText(whatsappNumber, "O WhatsApp do profissional e obrigatorio."),
                requireIdentifier(cityIdentifier, "A cidade do profissional e obrigatoria."),
                requireIdentifier(categoryIdentifier, "A categoria do profissional e obrigatoria."),
                requireMeaningfulText(shortDescription, "A descricao curta do profissional e obrigatoria."),
                ProfessionalProfileClassification.BASIC_PROFILE,
                false
        );
    }

    public static Professional restoreProfessional(
            UUID professionalIdentifier,
            String professionalName,
            String whatsappNumber,
            UUID cityIdentifier,
            UUID categoryIdentifier,
            String shortDescription,
            ProfessionalProfileClassification profileClassification,
            boolean qualityGuarantee
    ) {
        return new Professional(
                requireIdentifier(professionalIdentifier, "O identificador do profissional e obrigatorio."),
                requireMeaningfulText(professionalName, "O nome do profissional e obrigatorio."),
                requireMeaningfulText(whatsappNumber, "O WhatsApp do profissional e obrigatorio."),
                requireIdentifier(cityIdentifier, "A cidade do profissional e obrigatoria."),
                requireIdentifier(categoryIdentifier, "A categoria do profissional e obrigatoria."),
                requireMeaningfulText(shortDescription, "A descricao curta do profissional e obrigatoria."),
                requireClassification(profileClassification),
                qualityGuarantee
        );
    }

    private static UUID requireIdentifier(UUID identifier, String message) {
        if (identifier == null) {
            throw new BusinessRuleViolationException(message);
        }
        return identifier;
    }

    private static String requireMeaningfulText(String text, String message) {
        if (text == null || text.isBlank()) {
            throw new BusinessRuleViolationException(message);
        }
        return text.trim();
    }

    private static ProfessionalProfileClassification requireClassification(ProfessionalProfileClassification profileClassification) {
        if (profileClassification == null) {
            throw new BusinessRuleViolationException("A classificacao do perfil profissional e obrigatoria.");
        }
        return profileClassification;
    }
}
