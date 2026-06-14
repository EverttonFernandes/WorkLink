package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.AuthenticationOtpDeliveryRequest;
import br.com.worklink.application.authentication.port.DeliverAuthenticationOtpPort;

import java.util.List;

public class DisabledAuthenticationOtpDeliveryAdapter implements DeliverAuthenticationOtpPort {

    @Override
    public List<String> availableDeliveryChannels() {
        return List.of();
    }

    @Override
    public boolean isSimulatedDelivery() {
        return true;
    }

    @Override
    public void deliverAuthenticationOtp(AuthenticationOtpDeliveryRequest request) {
        // Delivery provider is intentionally disabled until a sandbox or real provider is configured.
    }
}
