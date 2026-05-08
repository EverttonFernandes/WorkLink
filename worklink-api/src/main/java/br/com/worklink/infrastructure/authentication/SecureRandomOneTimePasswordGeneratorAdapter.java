package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.GenerateOneTimePasswordPort;

import org.springframework.stereotype.Component;

import java.security.SecureRandom;

@Component
public class SecureRandomOneTimePasswordGeneratorAdapter implements GenerateOneTimePasswordPort {

    private static final int ONE_TIME_PASSWORD_BOUND = 1_000_000;

    private final SecureRandom secureRandom;

    public SecureRandomOneTimePasswordGeneratorAdapter() {
        this(new SecureRandom());
    }

    SecureRandomOneTimePasswordGeneratorAdapter(SecureRandom secureRandom) {
        this.secureRandom = secureRandom;
    }

    @Override
    public String generateOneTimePassword() {
        return "%06d".formatted(secureRandom.nextInt(ONE_TIME_PASSWORD_BOUND));
    }
}
