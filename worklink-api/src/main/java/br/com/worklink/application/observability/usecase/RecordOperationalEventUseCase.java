package br.com.worklink.application.observability.usecase;

import br.com.worklink.application.observability.port.RecordOperationalEventPort;

public class RecordOperationalEventUseCase {

    private final RecordOperationalEventPort recordOperationalEventPort;

    public RecordOperationalEventUseCase(RecordOperationalEventPort recordOperationalEventPort) {
        this.recordOperationalEventPort = recordOperationalEventPort;
    }

    public void recordOperationalEvent(OperationalEvent operationalEvent) {
        recordOperationalEventPort.recordOperationalEvent(operationalEvent);
    }
}
