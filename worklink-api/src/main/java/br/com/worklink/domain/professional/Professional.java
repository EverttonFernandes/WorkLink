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
        UUID profilePhotoFileIdentifier,
        String documentNumberHash,
        String usefulLink,
        String portfolioDescription,
        String serviceDescription,
        int profileCompletenessPercentage,
        ProfessionalProfileClassification profileClassification,
        ProfessionalAvailabilityStatus availabilityStatus,
        boolean qualityGuarantee,
        boolean blocked
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
                null,
                null,
                null,
                null,
                null,
                calculateCompletenessPercentage(null, null, null, null, null),
                ProfessionalProfileClassification.BASIC_PROFILE,
                ProfessionalAvailabilityStatus.ACCEPTING_NEW_CLIENTS,
                false,
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
            UUID profilePhotoFileIdentifier,
            String documentNumberHash,
            String usefulLink,
            String portfolioDescription,
            String serviceDescription,
            int profileCompletenessPercentage,
            ProfessionalProfileClassification profileClassification,
            ProfessionalAvailabilityStatus availabilityStatus,
            boolean qualityGuarantee,
            boolean blocked
    ) {
        return new Professional(
                requireIdentifier(professionalIdentifier, "O identificador do profissional e obrigatorio."),
                requireMeaningfulText(professionalName, "O nome do profissional e obrigatorio."),
                requireMeaningfulText(whatsappNumber, "O WhatsApp do profissional e obrigatorio."),
                requireIdentifier(cityIdentifier, "A cidade do profissional e obrigatoria."),
                requireIdentifier(categoryIdentifier, "A categoria do profissional e obrigatoria."),
                requireMeaningfulText(shortDescription, "A descricao curta do profissional e obrigatoria."),
                profilePhotoFileIdentifier,
                normalizeOptionalText(documentNumberHash),
                normalizeOptionalText(usefulLink),
                normalizeOptionalText(portfolioDescription),
                normalizeOptionalText(serviceDescription),
                requireCompletenessPercentage(profileCompletenessPercentage),
                requireClassification(profileClassification),
                requireAvailabilityStatus(availabilityStatus),
                qualityGuarantee,
                blocked
        );
    }

    public Professional completeProgressiveProfile(
            UUID newProfilePhotoFileIdentifier,
            String newDocumentNumberHash,
            String newUsefulLink,
            String newPortfolioDescription,
            String newServiceDescription,
            ProfessionalAvailabilityStatus newAvailabilityStatus
    ) {
        int newCompletenessPercentage = calculateCompletenessPercentage(
                newProfilePhotoFileIdentifier,
                newDocumentNumberHash,
                newUsefulLink,
                newPortfolioDescription,
                newServiceDescription
        );
        return new Professional(
                professionalIdentifier,
                professionalName,
                whatsappNumber,
                cityIdentifier,
                categoryIdentifier,
                shortDescription,
                newProfilePhotoFileIdentifier,
                normalizeOptionalText(newDocumentNumberHash),
                normalizeOptionalText(newUsefulLink),
                normalizeOptionalText(newPortfolioDescription),
                normalizeOptionalText(newServiceDescription),
                newCompletenessPercentage,
                classifyCompleteness(newCompletenessPercentage),
                requireAvailabilityStatus(newAvailabilityStatus),
                false,
                blocked
        );
    }

    public Professional updateAvailabilityStatus(ProfessionalAvailabilityStatus newAvailabilityStatus) {
        return new Professional(
                professionalIdentifier,
                professionalName,
                whatsappNumber,
                cityIdentifier,
                categoryIdentifier,
                shortDescription,
                profilePhotoFileIdentifier,
                documentNumberHash,
                usefulLink,
                portfolioDescription,
                serviceDescription,
                profileCompletenessPercentage,
                profileClassification,
                requireAvailabilityStatus(newAvailabilityStatus),
                false,
                blocked
        );
    }

    public Professional blockProfessional() {
        return changeBlockedStatus(true);
    }

    public Professional unblockProfessional() {
        return changeBlockedStatus(false);
    }

    private Professional changeBlockedStatus(boolean newBlockedStatus) {
        return new Professional(
                professionalIdentifier,
                professionalName,
                whatsappNumber,
                cityIdentifier,
                categoryIdentifier,
                shortDescription,
                profilePhotoFileIdentifier,
                documentNumberHash,
                usefulLink,
                portfolioDescription,
                serviceDescription,
                profileCompletenessPercentage,
                profileClassification,
                availabilityStatus,
                qualityGuarantee,
                newBlockedStatus
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

    private static ProfessionalAvailabilityStatus requireAvailabilityStatus(ProfessionalAvailabilityStatus availabilityStatus) {
        if (availabilityStatus == null) {
            throw new BusinessRuleViolationException("A disponibilidade do profissional e obrigatoria.");
        }
        return availabilityStatus;
    }

    private static String normalizeOptionalText(String text) {
        if (text == null || text.isBlank()) {
            return null;
        }
        return text.trim();
    }

    private static int calculateCompletenessPercentage(
            UUID profilePhotoFileIdentifier,
            String documentNumberHash,
            String usefulLink,
            String portfolioDescription,
            String serviceDescription
    ) {
        int completenessPercentage = 50;
        if (profilePhotoFileIdentifier != null) {
            completenessPercentage += 10;
        }
        if (normalizeOptionalText(documentNumberHash) != null) {
            completenessPercentage += 10;
        }
        if (normalizeOptionalText(usefulLink) != null) {
            completenessPercentage += 10;
        }
        if (normalizeOptionalText(portfolioDescription) != null) {
            completenessPercentage += 10;
        }
        if (normalizeOptionalText(serviceDescription) != null) {
            completenessPercentage += 10;
        }
        return completenessPercentage;
    }

    private static int requireCompletenessPercentage(int profileCompletenessPercentage) {
        if (profileCompletenessPercentage < 0 || profileCompletenessPercentage > 100) {
            throw new BusinessRuleViolationException("A completude do perfil profissional deve estar entre 0 e 100.");
        }
        return profileCompletenessPercentage;
    }

    private static ProfessionalProfileClassification classifyCompleteness(int profileCompletenessPercentage) {
        if (profileCompletenessPercentage >= 100) {
            return ProfessionalProfileClassification.COMPLETE_PROFILE;
        }
        if (profileCompletenessPercentage > 50) {
            return ProfessionalProfileClassification.PROGRESSIVE_PROFILE;
        }
        return ProfessionalProfileClassification.BASIC_PROFILE;
    }
}
