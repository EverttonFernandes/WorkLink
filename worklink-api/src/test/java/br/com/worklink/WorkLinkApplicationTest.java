package br.com.worklink;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class WorkLinkApplicationTest {

    @Test
    @DisplayName("Deve carregar o contexto da aplicacao quando a configuracao base estiver correta")
    void shouldLoadApplicationContextWhenBaseConfigurationIsCorrect() {
        // GIVEN
        // Configuracao base do Spring Boot disponivel no classpath.

        // WHEN
        // O contexto da aplicacao e carregado pelo SpringBootTest.

        // THEN
        // A ausencia de excecao confirma que o contexto base foi inicializado.
    }
}
