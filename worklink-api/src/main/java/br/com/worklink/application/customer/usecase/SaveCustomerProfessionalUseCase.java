package br.com.worklink.application.customer.usecase;

import br.com.worklink.application.customer.port.SaveCustomerSavedProfessionalPort;

import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class SaveCustomerProfessionalUseCase {

    private final SaveCustomerSavedProfessionalPort saveCustomerSavedProfessionalPort;
    private final LoadCustomerProfileUseCase loadCustomerProfileUseCase;

    public SaveCustomerProfessionalUseCase(
            SaveCustomerSavedProfessionalPort saveCustomerSavedProfessionalPort,
            LoadCustomerProfileUseCase loadCustomerProfileUseCase
    ) {
        this.saveCustomerSavedProfessionalPort = saveCustomerSavedProfessionalPort;
        this.loadCustomerProfileUseCase = loadCustomerProfileUseCase;
    }

    public CustomerProfileResponse saveCustomerProfessional(UUID customerIdentifier, UUID professionalIdentifier) {
        saveCustomerSavedProfessionalPort.saveCustomerSavedProfessional(customerIdentifier, professionalIdentifier);
        return loadCustomerProfileUseCase.loadCustomerProfile(customerIdentifier);
    }
}
