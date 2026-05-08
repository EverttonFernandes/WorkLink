package br.com.worklink.application.authorization.usecase;

import java.util.Arrays;

public enum AuthenticatedProfile {

    CUSTOMER,
    PROFESSIONAL,
    ADMINISTRATOR;

    public static AuthenticatedProfile fromTokenProfile(String tokenProfile) {
        return Arrays.stream(values())
                .filter(profile -> profile.name().equals(tokenProfile))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Perfil autenticado invalido."));
    }
}
