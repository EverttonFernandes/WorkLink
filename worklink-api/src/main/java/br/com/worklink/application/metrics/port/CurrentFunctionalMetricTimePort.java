package br.com.worklink.application.metrics.port;

import java.time.Instant;



@FunctionalInterface
public interface CurrentFunctionalMetricTimePort {

    Instant currentInstant();
}
