package br.com.worklink.application.testsupport.usecase;

import br.com.worklink.application.testsupport.port.ResetLocalFunctionalScenarioPort;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class ResetLocalFunctionalScenarioUseCaseTest {

    @Test
    @DisplayName("GIVEN cenario funcional local WHEN resetar estado THEN deve delegar para a porta de reset")
    void shouldDelegateScenarioResetToPort() {
        // GIVEN
        ResetLocalFunctionalScenarioPort resetLocalFunctionalScenarioPort = mock(ResetLocalFunctionalScenarioPort.class);
        ResetLocalFunctionalScenarioUseCase useCase =
                new ResetLocalFunctionalScenarioUseCase(resetLocalFunctionalScenarioPort);

        // WHEN
        useCase.resetScenarioState();

        // THEN
        verify(resetLocalFunctionalScenarioPort).resetScenarioState();
    }
}
