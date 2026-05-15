package br.com.worklink.application.testsupport.usecase;

import br.com.worklink.application.testsupport.port.ResetLocalFunctionalScenarioPort;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Profile("local")
@Component
public class ResetLocalFunctionalScenarioUseCase {

    private final ResetLocalFunctionalScenarioPort resetLocalFunctionalScenarioPort;

    public ResetLocalFunctionalScenarioUseCase(
            ResetLocalFunctionalScenarioPort resetLocalFunctionalScenarioPort
    ) {
        this.resetLocalFunctionalScenarioPort = resetLocalFunctionalScenarioPort;
    }

    public void resetScenarioState() {
        resetLocalFunctionalScenarioPort.resetScenarioState();
    }
}
