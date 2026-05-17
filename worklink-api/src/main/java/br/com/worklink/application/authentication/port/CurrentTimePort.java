package br.com.worklink.application.authentication.port;

import java.time.Instant;



@FunctionalInterface
public interface CurrentTimePort {

    Instant currentInstant();
}
