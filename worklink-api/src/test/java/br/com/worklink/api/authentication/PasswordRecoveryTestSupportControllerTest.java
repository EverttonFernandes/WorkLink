package br.com.worklink.api.authentication;

import br.com.worklink.application.authentication.port.LoadPasswordRecoveryTokenTestSupportPort;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class PasswordRecoveryTestSupportControllerTest {

    @Test
    @DisplayName("GIVEN token local WHEN consultar suporte THEN deve retornar somente token")
    void shouldReturnAvailableRecoveryToken() {
        // GIVEN
        LoadPasswordRecoveryTokenTestSupportPort port = mock(LoadPasswordRecoveryTokenTestSupportPort.class);
        when(port.loadToken("cliente@example.com")).thenReturn(Optional.of("token-opaco"));
        PasswordRecoveryTestSupportController controller = new PasswordRecoveryTestSupportController(port);

        // WHEN
        Map<String, String> response = controller.loadRecoveryToken("cliente@example.com");

        // THEN
        assertThat(response).containsEntry("recoveryToken", "token-opaco");
    }

    @Test
    @DisplayName("GIVEN token ausente WHEN consultar suporte THEN deve rejeitar consulta")
    void shouldRejectUnavailableRecoveryToken() {
        // GIVEN
        LoadPasswordRecoveryTokenTestSupportPort port = mock(LoadPasswordRecoveryTokenTestSupportPort.class);
        when(port.loadToken("ausente@example.com")).thenReturn(Optional.empty());
        PasswordRecoveryTestSupportController controller = new PasswordRecoveryTestSupportController(port);

        // WHEN / THEN
        assertThatThrownBy(() -> controller.loadRecoveryToken("ausente@example.com"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Token de recuperacao indisponivel.");
    }
}
