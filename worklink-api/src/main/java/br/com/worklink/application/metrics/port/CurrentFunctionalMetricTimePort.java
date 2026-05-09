package br.com.worklink.application.metrics.port;

import java.time.Instant;

public interface CurrentFunctionalMetricTimePort {

    Instant currentInstant();
}
