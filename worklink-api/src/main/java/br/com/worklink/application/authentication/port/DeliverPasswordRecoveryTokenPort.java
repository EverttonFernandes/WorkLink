package br.com.worklink.application.authentication.port;

@FunctionalInterface
public interface DeliverPasswordRecoveryTokenPort {

    default boolean isDeliveryAvailable() {
        return true;
    }

    void deliverPasswordRecoveryToken(String normalizedEmailAddress, String rawToken);
}
