package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.DeliverPasswordRecoveryTokenPort;

public class DisabledPasswordRecoveryDeliveryAdapter implements DeliverPasswordRecoveryTokenPort {

    @Override
    public boolean isDeliveryAvailable() {
        return false;
    }

    @Override
    public void deliverPasswordRecoveryToken(String normalizedEmailAddress, String rawToken) {
        // Delivery provider is intentionally disabled until a production email adapter is configured.
    }
}
