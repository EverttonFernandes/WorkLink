package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.GenerateOneTimePasswordPort;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;

@Component
public class SecureRandomOneTimePasswordGeneratorAdapter implements GenerateOneTimePasswordPort {

    private static final int ONE_TIME_PASSWORD_BOUND = 1_000_000;

    private final SecureRandom secureRandom;
    private final String fixedOneTimePassword;

    @Autowired
    public SecureRandomOneTimePasswordGeneratorAdapter(
            Environment environment
    ) {
        this(new SecureRandom(), environment.getProperty("worklink.test-support.fixed-otp", ""));
    }

    SecureRandomOneTimePasswordGeneratorAdapter(SecureRandom secureRandom) {
        this(secureRandom, null);
    }

    SecureRandomOneTimePasswordGeneratorAdapter(SecureRandom secureRandom, String fixedOneTimePassword) {
        this.secureRandom = secureRandom;
        this.fixedOneTimePassword = fixedOneTimePassword;
    }

    @Override
    public String generateOneTimePassword() {
        if (fixedOneTimePassword != null && !fixedOneTimePassword.isBlank()) {
            return fixedOneTimePassword.trim();
        }
        return "%06d".formatted(secureRandom.nextInt(ONE_TIME_PASSWORD_BOUND));
    }
}
