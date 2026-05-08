package br.com.worklink.domain.authentication;

import br.com.worklink.domain.BusinessRuleViolationException;

import java.time.Instant;
import java.util.UUID;

public record CustomerAccount(
        UUID customerIdentifier,
        String phoneNumber,
        Instant createdAt
) {

    public static CustomerAccount registerCustomerAccount(String phoneNumber, Instant createdAt) {
        return restore(UUID.randomUUID(), phoneNumber, createdAt);
    }

    public static CustomerAccount restore(UUID customerIdentifier, String phoneNumber, Instant createdAt) {
        return new CustomerAccount(
                requireIdentifier(customerIdentifier),
                requirePhoneNumber(phoneNumber),
                requireCreationInstant(createdAt)
        );
    }

    private static UUID requireIdentifier(UUID customerIdentifier) {
        if (customerIdentifier == null) {
            throw new BusinessRuleViolationException("O identificador do cliente e obrigatorio.");
        }
        return customerIdentifier;
    }

    private static String requirePhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.isBlank()) {
            throw new BusinessRuleViolationException("O telefone do cliente e obrigatorio.");
        }
        return phoneNumber.trim();
    }

    private static Instant requireCreationInstant(Instant creationInstant) {
        if (creationInstant == null) {
            throw new BusinessRuleViolationException("O momento de criacao do cliente e obrigatorio.");
        }
        return creationInstant;
    }
}
