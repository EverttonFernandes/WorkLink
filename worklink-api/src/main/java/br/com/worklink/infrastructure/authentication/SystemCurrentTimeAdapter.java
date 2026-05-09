package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.contact.port.CurrentContactTimePort;

import org.springframework.stereotype.Component;

import java.time.Instant;

@Component
public class SystemCurrentTimeAdapter implements CurrentTimePort, CurrentContactTimePort {

    @Override
    public Instant currentInstant() {
        return Instant.now();
    }
}
