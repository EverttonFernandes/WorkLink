package br.com.worklink.application.authentication.port;

import java.util.Optional;

@FunctionalInterface
public interface LoadPasswordRecoveryTokenTestSupportPort {

    Optional<String> loadToken(String emailAddress);
}
