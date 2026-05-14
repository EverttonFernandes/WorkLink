package br.com.worklink.application.customer.port;

import java.util.UUID;

public record CustomerProfilePreferencesProjection(
        UUID customerIdentifier,
        boolean whatsappNotificationsEnabled,
        boolean profilePersonalizationEnabled
) {
}
