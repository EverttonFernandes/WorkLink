package br.com.worklink.application.customer.port;

import java.util.UUID;

public interface RemoveCustomerSavedProfessionalPort {

    void removeCustomerSavedProfessional(UUID customerIdentifier, UUID professionalIdentifier);
}
