package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.AuthenticationOtpDeliveryRequest;
import br.com.worklink.application.authentication.port.DeliverAuthenticationOtpPort;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
@ConditionalOnProperty(
        name = "worklink.integrations.authentication-otp.delivery-mode",
        havingValue = "sandbox"
)
public class SandboxAuthenticationOtpDeliveryAdapter implements DeliverAuthenticationOtpPort {

    private final List<String> enabledDeliveryChannels;

    public SandboxAuthenticationOtpDeliveryAdapter(
            @Value("${worklink.features.sms-enabled:false}") boolean smsEnabled,
            @Value("${worklink.features.whatsapp-enabled:false}") boolean whatsappEnabled,
            @Value("${worklink.features.email-otp-enabled:false}") boolean emailOtpEnabled
    ) {
        List<String> enabledChannels = new ArrayList<>();
        if (smsEnabled) {
            enabledChannels.add("SMS");
        }
        if (whatsappEnabled) {
            enabledChannels.add("WHATSAPP");
        }
        if (emailOtpEnabled) {
            enabledChannels.add("EMAIL");
        }
        this.enabledDeliveryChannels = List.copyOf(enabledChannels);
    }

    @Override
    public List<String> availableDeliveryChannels() {
        return enabledDeliveryChannels;
    }

    @Override
    public boolean isSimulatedDelivery() {
        return true;
    }

    @Override
    public void deliverAuthenticationOtp(AuthenticationOtpDeliveryRequest request) {
        // Sandbox mode validates flow contract without sending to a real provider.
    }
}
