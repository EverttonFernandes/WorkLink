package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;

import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.util.Base64;

@Component
public class SecureRandomTokenGeneratorAdapter implements GenerateSecureTokenPort {

    private static final int TOKEN_BYTES_LENGTH = 32;

    private final SecureRandom secureRandom;

    public SecureRandomTokenGeneratorAdapter() {
        this(new SecureRandom());
    }

    SecureRandomTokenGeneratorAdapter(SecureRandom secureRandom) {
        this.secureRandom = secureRandom;
    }

    @Override
    public String generateSecureToken() {
        byte[] tokenBytes = new byte[TOKEN_BYTES_LENGTH];
        secureRandom.nextBytes(tokenBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(tokenBytes);
    }
}
