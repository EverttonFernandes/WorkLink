package br.com.worklink.application.authorization.usecase;

import java.util.UUID;

public record AuthorizationOwnership(UUID ownerIdentifier) {

    public AuthorizationOwnership {
        if (ownerIdentifier == null) {
            throw new IllegalArgumentException("O identificador do dono do recurso e obrigatorio.");
        }
    }
}
