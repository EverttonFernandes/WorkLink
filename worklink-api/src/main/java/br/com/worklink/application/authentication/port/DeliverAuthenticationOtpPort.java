package br.com.worklink.application.authentication.port;

import java.util.List;

public interface DeliverAuthenticationOtpPort {

    List<String> availableDeliveryChannels();

    boolean isSimulatedDelivery();

    void deliverAuthenticationOtp(AuthenticationOtpDeliveryRequest request);
}
