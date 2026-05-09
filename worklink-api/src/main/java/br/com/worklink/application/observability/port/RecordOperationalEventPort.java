package br.com.worklink.application.observability.port;

import br.com.worklink.application.observability.usecase.OperationalEvent;

public interface RecordOperationalEventPort {

    void recordOperationalEvent(OperationalEvent operationalEvent);
}
