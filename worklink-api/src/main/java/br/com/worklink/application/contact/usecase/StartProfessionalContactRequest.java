package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;

import java.util.UUID;

public record StartProfessionalContactRequest(
        AuthenticatedPrincipal authenticatedPrincipal,
        UUID professionalIdentifier
) {
}
