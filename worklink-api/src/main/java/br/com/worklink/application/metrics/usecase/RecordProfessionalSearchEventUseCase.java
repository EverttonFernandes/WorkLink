package br.com.worklink.application.metrics.usecase;

import br.com.worklink.application.metrics.port.CurrentFunctionalMetricTimePort;
import br.com.worklink.application.metrics.port.SaveProfessionalSearchEventPort;

public class RecordProfessionalSearchEventUseCase {

    private final SaveProfessionalSearchEventPort saveProfessionalSearchEventPort;
    private final CurrentFunctionalMetricTimePort currentFunctionalMetricTimePort;

    public RecordProfessionalSearchEventUseCase(
            SaveProfessionalSearchEventPort saveProfessionalSearchEventPort,
            CurrentFunctionalMetricTimePort currentFunctionalMetricTimePort
    ) {
        this.saveProfessionalSearchEventPort = saveProfessionalSearchEventPort;
        this.currentFunctionalMetricTimePort = currentFunctionalMetricTimePort;
    }

    public ProfessionalSearchEvent recordProfessionalSearchEvent(RecordProfessionalSearchEventRequest request) {
        return saveProfessionalSearchEventPort.saveProfessionalSearchEvent(
                ProfessionalSearchEvent.registerProfessionalSearchEvent(
                        request.categoryIdentifier(),
                        request.cityIdentifiers(),
                        request.keyword(),
                        request.resultCount(),
                        currentFunctionalMetricTimePort.currentInstant()
                )
        );
    }
}
