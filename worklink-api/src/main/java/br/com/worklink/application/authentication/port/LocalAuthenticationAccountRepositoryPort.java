package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.LocalAuthenticationAccount;

import java.util.Optional;
import java.util.UUID;

public interface LocalAuthenticationAccountRepositoryPort {

    Optional<LocalAuthenticationAccount> loadByNormalizedEmailAddress(String normalizedEmailAddress);

    Optional<LocalAuthenticationAccount> loadByCustomerIdentifier(UUID customerIdentifier);

    LocalAuthenticationAccount save(LocalAuthenticationAccount account);

    LocalAuthenticationAccount update(LocalAuthenticationAccount account);
}
