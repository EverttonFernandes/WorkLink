package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.CurrentTimePort;

import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class SystemCurrentTimeAdapter implements CurrentTimePort {

    @Override
    public Instant currentInstant() {
        return Instant.now();
    }
}
