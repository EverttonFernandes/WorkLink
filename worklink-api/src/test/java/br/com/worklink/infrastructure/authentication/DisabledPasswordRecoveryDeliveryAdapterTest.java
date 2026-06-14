package br.com.worklink.infrastructure.authentication;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class DisabledPasswordRecoveryDeliveryAdapterTest {

    @Test
    @DisplayName("GIVEN adapter desabilitado WHEN consultar disponibilidade THEN deve informar indisponivel")
    void shouldReportPasswordRecoveryDeliveryAsUnavailable() {
        // GIVEN
        DisabledPasswordRecoveryDeliveryAdapter adapter = new DisabledPasswordRecoveryDeliveryAdapter();

        // WHEN / THEN
        assertThat(adapter.isDeliveryAvailable()).isFalse();
    }
}
