package br.com.worklink.application.customer.port;

import java.util.List;
import java.util.UUID;

public interface ListCustomerSavedProfessionalIdentifiersPort {

    List<UUID> listCustomerSavedProfessionalIdentifiers(UUID customerIdentifier);
}
