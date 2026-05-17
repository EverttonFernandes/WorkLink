package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.CustomerAccount;



@FunctionalInterface
public interface SaveCustomerAccountPort {

    CustomerAccount saveCustomerAccount(CustomerAccount customerAccount);
}
