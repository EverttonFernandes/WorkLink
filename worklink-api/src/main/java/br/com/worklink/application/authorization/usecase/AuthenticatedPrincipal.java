package br.com.worklink.application.authorization.usecase;

import java.util.UUID;

public record AuthenticatedPrincipal(UUID principalIdentifier, AuthenticatedProfile profile) {

    public AuthenticatedPrincipal {
        if (principalIdentifier == null) {
            throw new IllegalArgumentException("O identificador do principal autenticado e obrigatorio.");
        }
        if (profile == null) {
            throw new IllegalArgumentException("O perfil autenticado e obrigatorio.");
        }
    }
}
