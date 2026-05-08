package br.com.worklink.application.authentication.port;

import java.time.Instant;

public interface CurrentTimePort {

    Instant currentInstant();
}
