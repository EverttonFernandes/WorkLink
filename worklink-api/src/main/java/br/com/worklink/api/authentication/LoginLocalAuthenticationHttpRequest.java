package br.com.worklink.api.authentication;

public record LoginLocalAuthenticationHttpRequest(String emailAddress, String password) {
}
