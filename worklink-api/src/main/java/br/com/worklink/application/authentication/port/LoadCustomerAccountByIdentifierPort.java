package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.CustomerAccount;

import java.util.Optional;
import java.util.UUID;



@FunctionalInterface
public interface LoadCustomerAccountByIdentifierPort {

    Optional<CustomerAccount> loadCustomerAccountByIdentifier(UUID customerIdentifier);
}
