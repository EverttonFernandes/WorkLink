package br.com.worklink.application.customer.usecase;

import br.com.worklink.application.customer.port.RemoveCustomerSavedProfessionalPort;

import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class RemoveCustomerSavedProfessionalUseCase {

    private final RemoveCustomerSavedProfessionalPort removeCustomerSavedProfessionalPort;
    private final LoadCustomerProfileUseCase loadCustomerProfileUseCase;

    public RemoveCustomerSavedProfessionalUseCase(
            RemoveCustomerSavedProfessionalPort removeCustomerSavedProfessionalPort,
            LoadCustomerProfileUseCase loadCustomerProfileUseCase
    ) {
        this.removeCustomerSavedProfessionalPort = removeCustomerSavedProfessionalPort;
        this.loadCustomerProfileUseCase = loadCustomerProfileUseCase;
    }

    public CustomerProfileResponse removeCustomerSavedProfessional(UUID customerIdentifier, UUID professionalIdentifier) {
        removeCustomerSavedProfessionalPort.removeCustomerSavedProfessional(customerIdentifier, professionalIdentifier);
        return loadCustomerProfileUseCase.loadCustomerProfile(customerIdentifier);
    }
}
