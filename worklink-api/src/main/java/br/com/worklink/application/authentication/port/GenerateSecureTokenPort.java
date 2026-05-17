package br.com.worklink.application.authentication.port;

@FunctionalInterface
public interface GenerateSecureTokenPort {

    String generateSecureToken();
}
