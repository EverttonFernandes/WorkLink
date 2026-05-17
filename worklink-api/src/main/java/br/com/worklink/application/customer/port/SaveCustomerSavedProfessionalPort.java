package br.com.worklink.application.customer.port;

import java.util.UUID;



@FunctionalInterface
public interface SaveCustomerSavedProfessionalPort {

    void saveCustomerSavedProfessional(UUID customerIdentifier, UUID professionalIdentifier);
}
