package br.com.worklink.application.customer.usecase;

import br.com.worklink.application.customer.port.CustomerProfilePreferencesProjection;
import br.com.worklink.application.customer.port.SaveCustomerProfilePreferencesPort;

import org.springframework.stereotype.Service;

@Service
public class UpdateCustomerProfilePreferencesUseCase {

    private final SaveCustomerProfilePreferencesPort saveCustomerProfilePreferencesPort;
    private final LoadCustomerProfileUseCase loadCustomerProfileUseCase;

    public UpdateCustomerProfilePreferencesUseCase(
            SaveCustomerProfilePreferencesPort saveCustomerProfilePreferencesPort,
            LoadCustomerProfileUseCase loadCustomerProfileUseCase
    ) {
        this.saveCustomerProfilePreferencesPort = saveCustomerProfilePreferencesPort;
        this.loadCustomerProfileUseCase = loadCustomerProfileUseCase;
    }

    public CustomerProfileResponse updateCustomerProfilePreferences(
            UpdateCustomerProfilePreferencesRequest updateCustomerProfilePreferencesRequest
    ) {
        saveCustomerProfilePreferencesPort.saveCustomerProfilePreferences(new CustomerProfilePreferencesProjection(
                updateCustomerProfilePreferencesRequest.authenticatedPrincipal().principalIdentifier(),
                updateCustomerProfilePreferencesRequest.whatsappNotificationsEnabled(),
                updateCustomerProfilePreferencesRequest.profilePersonalizationEnabled()
        ));
        return loadCustomerProfileUseCase.loadCustomerProfile(
                updateCustomerProfilePreferencesRequest.authenticatedPrincipal().principalIdentifier()
        );
    }
}
