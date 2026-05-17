package br.com.worklink.application.authentication.port;

@FunctionalInterface
public interface GenerateOneTimePasswordPort {

    String generateOneTimePassword();
}
