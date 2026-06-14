package br.com.worklink.infrastructure.authentication;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class InMemoryPasswordRecoveryMailboxAdapterTest {

    @Test
    @DisplayName("GIVEN token entregue WHEN consultar email normalizado THEN deve retornar token")
    void shouldStoreAndLoadRecoveryTokenByNormalizedEmail() {
        // GIVEN
        InMemoryPasswordRecoveryMailboxAdapter adapter = new InMemoryPasswordRecoveryMailboxAdapter();

        // WHEN
        adapter.deliverPasswordRecoveryToken("cliente@example.com", "token-opaco");

        // THEN
        assertThat(adapter.loadToken(" Cliente@Example.COM ")).contains("token-opaco");
        assertThat(adapter.loadToken("ausente@example.com")).isEmpty();
    }
}
