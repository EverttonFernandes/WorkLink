package br.com.worklink.application.authentication.port;

public interface PasswordHashingPort {

    String hashPassword(String rawPassword);

    boolean matchesPassword(String rawPassword, String passwordHash);
}
