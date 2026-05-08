package br.com.worklink.domain.professional;

import br.com.worklink.domain.BusinessRuleViolationException;

public enum ProfessionalAvailabilityStatus {
    AVAILABLE_TODAY("Disponível hoje", 0),
    AVAILABLE_THIS_WEEK("Disponível esta semana", 1),
    ACCEPTING_NEW_CLIENTS("Aceitando novos clientes", 2),
    EMERGENCY_SERVICE("Atendimento emergencial", 0),
    TEMPORARILY_UNAVAILABLE("Indisponível temporariamente", 9);

    private final String badgeLabel;
    private final int listingPriority;

    ProfessionalAvailabilityStatus(String badgeLabel, int listingPriority) {
        this.badgeLabel = badgeLabel;
        this.listingPriority = listingPriority;
    }

    public String badgeLabel() {
        return badgeLabel;
    }

    public int listingPriority() {
        return listingPriority;
    }

    public boolean reducesListingHighlight() {
        return this == TEMPORARILY_UNAVAILABLE;
    }

    public static ProfessionalAvailabilityStatus fromRequiredName(String availabilityStatusName) {
        if (availabilityStatusName == null || availabilityStatusName.isBlank()) {
            throw new BusinessRuleViolationException("A disponibilidade do profissional e obrigatoria.");
        }
        try {
            return ProfessionalAvailabilityStatus.valueOf(availabilityStatusName.trim());
        } catch (IllegalArgumentException exception) {
            throw new BusinessRuleViolationException("A disponibilidade informada nao e permitida.");
        }
    }
}
