package br.com.worklink.api.testsupport;

import br.com.worklink.application.testsupport.usecase.ResetLocalFunctionalScenarioUseCase;

import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@Profile("local")
@RestController
@RequestMapping("/api/v1/test-support")
public class LocalFunctionalTestSupportController {

    private final ResetLocalFunctionalScenarioUseCase resetLocalFunctionalScenarioUseCase;

    public LocalFunctionalTestSupportController(
            ResetLocalFunctionalScenarioUseCase resetLocalFunctionalScenarioUseCase
    ) {
        this.resetLocalFunctionalScenarioUseCase = resetLocalFunctionalScenarioUseCase;
    }

    @PostMapping("/reset")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void resetScenarioState() {
        resetLocalFunctionalScenarioUseCase.resetScenarioState();
    }
}
