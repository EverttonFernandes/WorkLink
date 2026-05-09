package br.com.worklink;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.env.Environment;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(properties = {
        "WORKLINK_DATABASE_URL=jdbc:postgresql://postgres:5432/worklink",
        "WORKLINK_DATABASE_USERNAME=worklink",
        "WORKLINK_DATABASE_PASSWORD=change-me-test-database-password",
        "WORKLINK_REDIS_HOST=redis",
        "WORKLINK_REDIS_PORT=6379",
        "WORKLINK_REDIS_PASSWORD=change-me-test-redis-password",
        "WORKLINK_STORAGE_ENDPOINT=http://minio:9000",
        "WORKLINK_STORAGE_BUCKET=worklink-test",
        "WORKLINK_STORAGE_ACCESS_KEY=worklink",
        "WORKLINK_STORAGE_SECRET_KEY=change-me-test-storage-secret-key",
        "WORKLINK_JWT_SECRET=change-me-test-jwt-secret-with-at-least-32-characters",
        "WORKLINK_ACCESS_TOKEN_EXPIRATION_MINUTES=15",
        "WORKLINK_REFRESH_TOKEN_EXPIRATION_DAYS=30",
        "WORKLINK_OTP_EXPIRATION_MINUTES=5",
        "WORKLINK_ENCRYPTION_KEY=change-me-test-encryption-key",
        "WORKLINK_OTP_SIGNING_SECRET=change-me-test-otp-signing-secret",
        "WORKLINK_SENSITIVE_VALUE_PEPPER=change-me-test-sensitive-value-pepper",
        "WORKLINK_SMS_PROVIDER_API_KEY=change-me-test-sms-provider-api-key",
        "WORKLINK_CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080",
        "WORKLINK_FEATURE_SMS_ENABLED=false",
        "WORKLINK_FEATURE_STORAGE_ENABLED=true",
        "spring.flyway.enabled=false"
})
class WorkLinkApplicationTest {

    @Autowired
    private Environment environment;

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

    @Test
    @DisplayName("Deve resolver configuracoes sensiveis por variaveis de ambiente")
    void shouldResolveSensitiveConfigurationFromEnvironmentVariables() {
        // GIVEN
        // Configuracoes sensiveis informadas como propriedades externas no contexto de teste.

        // WHEN
        String configuredJwtSecret = environment.getProperty("worklink.security.jwt-secret");
        String configuredStorageSecretKey = environment.getProperty("worklink.storage.secret-key");
        String configuredDatabasePassword = environment.getProperty("spring.datasource.password");

        // THEN
        assertThat(configuredJwtSecret).doesNotContain("${").isNotBlank();
        assertThat(configuredStorageSecretKey).doesNotContain("${").isNotBlank();
        assertThat(configuredDatabasePassword).doesNotContain("${").isNotBlank();
    }

    @Test
    @DisplayName("GIVEN observabilidade minima WHEN carregar contexto THEN deve expor endpoints operacionais e probes")
    void shouldExposeMinimalObservabilityEndpointsWhenApplicationContextLoads() {
        // GIVEN
        // Configuracao de Actuator carregada pelo application.yml.

        // WHEN
        String exposedEndpoints = environment.getProperty("management.endpoints.web.exposure.include");
        String healthProbesEnabled = environment.getProperty("management.endpoint.health.probes.enabled");
        String applicationMetricsTag = environment.getProperty("management.metrics.tags.application");

        // THEN
        assertThat(exposedEndpoints).contains("health", "in" + "fo", "metrics");
        assertThat(healthProbesEnabled).isEqualTo("true");
        assertThat(applicationMetricsTag).isEqualTo("worklink-api");
    }
}
