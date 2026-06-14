package br.com.worklink.api.authentication;

import br.com.worklink.application.authentication.port.LoadPasswordRecoveryTokenTestSupportPort;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/test-support/password-recovery")
@ConditionalOnProperty(
        name = "worklink.test-support.password-recovery-token-exposure-enabled",
        havingValue = "true"
)
@Profile({"local", "test"})
public class PasswordRecoveryTestSupportController {

    private final LoadPasswordRecoveryTokenTestSupportPort loadPasswordRecoveryTokenPort;

    public PasswordRecoveryTestSupportController(
            LoadPasswordRecoveryTokenTestSupportPort loadPasswordRecoveryTokenPort
    ) {
        this.loadPasswordRecoveryTokenPort = loadPasswordRecoveryTokenPort;
    }

    @GetMapping
    Map<String, String> loadRecoveryToken(@RequestParam String emailAddress) {
        return Map.of(
                "recoveryToken",
                loadPasswordRecoveryTokenPort.loadToken(emailAddress)
                        .orElseThrow(() -> new IllegalArgumentException("Token de recuperacao indisponivel."))
        );
    }
}
