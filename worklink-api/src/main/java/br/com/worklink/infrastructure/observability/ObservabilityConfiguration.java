package br.com.worklink.infrastructure.observability;

import br.com.worklink.application.observability.port.RecordOperationalEventPort;
import br.com.worklink.application.observability.usecase.RecordOperationalEventUseCase;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ObservabilityConfiguration {

    @Bean
    SensitiveLogValueSanitizer sensitiveLogValueSanitizer() {
        return new SensitiveLogValueSanitizer();
    }

    @Bean
    RecordOperationalEventUseCase recordOperationalEventUseCase(RecordOperationalEventPort recordOperationalEventPort) {
        return new RecordOperationalEventUseCase(recordOperationalEventPort);
    }
}
