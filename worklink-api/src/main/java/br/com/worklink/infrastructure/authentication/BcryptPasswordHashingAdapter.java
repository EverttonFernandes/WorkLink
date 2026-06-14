package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.PasswordHashingPort;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class BcryptPasswordHashingAdapter implements PasswordHashingPort {

    private final BCryptPasswordEncoder passwordEncoder;

    public BcryptPasswordHashingAdapter(
            @Value("${worklink.security.password-bcrypt-strength:12}") int strength
    ) {
        this.passwordEncoder = new BCryptPasswordEncoder(strength);
    }

    @Override
    public String hashPassword(String rawPassword) {
        return passwordEncoder.encode(rawPassword);
    }

    @Override
    public boolean matchesPassword(String rawPassword, String passwordHash) {
        return rawPassword != null && passwordHash != null && passwordEncoder.matches(rawPassword, passwordHash);
    }
}
