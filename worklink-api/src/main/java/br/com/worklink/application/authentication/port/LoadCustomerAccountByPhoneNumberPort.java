package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.CustomerAccount;

import java.util.Optional;

public interface LoadCustomerAccountByPhoneNumberPort {

    Optional<CustomerAccount> loadCustomerAccountByPhoneNumber(String phoneNumber);
}
