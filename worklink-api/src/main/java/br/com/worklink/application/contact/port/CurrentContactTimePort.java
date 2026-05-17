package br.com.worklink.application.contact.port;

import java.time.Instant;



@FunctionalInterface
public interface CurrentContactTimePort {

    Instant currentInstant();
}
