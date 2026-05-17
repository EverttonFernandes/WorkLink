package br.com.worklink.application.customer.port;

import java.util.UUID;



@FunctionalInterface
public interface RemoveCustomerSavedProfessionalPort {

    void removeCustomerSavedProfessional(UUID customerIdentifier, UUID professionalIdentifier);
}
