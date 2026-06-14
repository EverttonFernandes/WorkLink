package br.com.worklink.application.authentication.usecase;

public record LoginLocalAuthenticationRequest(String emailAddress, String password) {
}
