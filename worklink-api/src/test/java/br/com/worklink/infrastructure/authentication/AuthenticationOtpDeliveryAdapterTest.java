package br.com.worklink.infrastructure.authentication;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class AuthenticationOtpDeliveryAdapterTest {

    @Test
    @DisplayName("GIVEN adapter desabilitado WHEN consultar canais THEN deve retornar lista vazia")
    void shouldReportNoAvailableChannelsWhenOtpDeliveryIsDisabled() {
        // GIVEN
        DisabledAuthenticationOtpDeliveryAdapter adapter = new DisabledAuthenticationOtpDeliveryAdapter();

        // WHEN / THEN
        assertThat(adapter.availableDeliveryChannels()).isEmpty();
        assertThat(adapter.isSimulatedDelivery()).isTrue();
    }

    @Test
    @DisplayName("GIVEN sandbox configurado WHEN consultar canais THEN deve expor apenas os canais habilitados")
    void shouldExposeOnlyEnabledChannelsInSandboxMode() {
        // GIVEN
        SandboxAuthenticationOtpDeliveryAdapter adapter = new SandboxAuthenticationOtpDeliveryAdapter(
                true,
                false,
                true
        );

        // WHEN / THEN
        assertThat(adapter.availableDeliveryChannels()).containsExactly("SMS", "EMAIL");
        assertThat(adapter.isSimulatedDelivery()).isTrue();
    }
}
