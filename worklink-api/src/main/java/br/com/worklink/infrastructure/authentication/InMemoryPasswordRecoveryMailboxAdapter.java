package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.DeliverPasswordRecoveryTokenPort;
import br.com.worklink.application.authentication.port.LoadPasswordRecoveryTokenTestSupportPort;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.Locale;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Component
@ConditionalOnProperty(
        name = "worklink.test-support.password-recovery-token-exposure-enabled",
        havingValue = "true"
)
@Profile({"local", "test"})
public class InMemoryPasswordRecoveryMailboxAdapter implements
        DeliverPasswordRecoveryTokenPort,
        LoadPasswordRecoveryTokenTestSupportPort {

    private final Map<String, String> tokensByEmailAddress = new ConcurrentHashMap<>();

    @Override
    public void deliverPasswordRecoveryToken(String normalizedEmailAddress, String rawToken) {
        tokensByEmailAddress.put(normalizedEmailAddress, rawToken);
    }

    @Override
    public Optional<String> loadToken(String emailAddress) {
        return Optional.ofNullable(tokensByEmailAddress.get(emailAddress.trim().toLowerCase(Locale.ROOT)));
    }
}
