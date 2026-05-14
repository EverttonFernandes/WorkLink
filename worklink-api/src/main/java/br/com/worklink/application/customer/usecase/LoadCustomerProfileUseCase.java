package br.com.worklink.application.customer.usecase;

import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.customer.port.CustomerProfilePreferencesProjection;
import br.com.worklink.application.customer.port.ListCustomerSavedProfessionalIdentifiersPort;
import br.com.worklink.application.customer.port.LoadCustomerProfilePreferencesPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.review.port.ListProfessionalReviewsByInternalAuthorIdentifierPort;
import br.com.worklink.domain.authentication.CustomerAccount;
import br.com.worklink.domain.catalog.ServiceCategory;
import br.com.worklink.domain.catalog.ServiceCity;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.review.ProfessionalReview;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class LoadCustomerProfileUseCase {

    private static final String DEFAULT_CUSTOMER_NAME = "Cliente WorkLink";

    private final LoadCustomerAccountByIdentifierPort loadCustomerAccountByIdentifierPort;
    private final LoadCustomerProfilePreferencesPort loadCustomerProfilePreferencesPort;
    private final ListCustomerSavedProfessionalIdentifiersPort listCustomerSavedProfessionalIdentifiersPort;
    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final LoadServiceCategoryByIdentifierPort loadServiceCategoryByIdentifierPort;
    private final LoadServiceCityByIdentifierPort loadServiceCityByIdentifierPort;
    private final ListProfessionalReviewsByInternalAuthorIdentifierPort
            listProfessionalReviewsByInternalAuthorIdentifierPort;

    public LoadCustomerProfileUseCase(
            LoadCustomerAccountByIdentifierPort loadCustomerAccountByIdentifierPort,
            LoadCustomerProfilePreferencesPort loadCustomerProfilePreferencesPort,
            ListCustomerSavedProfessionalIdentifiersPort listCustomerSavedProfessionalIdentifiersPort,
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            LoadServiceCategoryByIdentifierPort loadServiceCategoryByIdentifierPort,
            LoadServiceCityByIdentifierPort loadServiceCityByIdentifierPort,
            ListProfessionalReviewsByInternalAuthorIdentifierPort
                    listProfessionalReviewsByInternalAuthorIdentifierPort
    ) {
        this.loadCustomerAccountByIdentifierPort = loadCustomerAccountByIdentifierPort;
        this.loadCustomerProfilePreferencesPort = loadCustomerProfilePreferencesPort;
        this.listCustomerSavedProfessionalIdentifiersPort = listCustomerSavedProfessionalIdentifiersPort;
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.loadServiceCategoryByIdentifierPort = loadServiceCategoryByIdentifierPort;
        this.loadServiceCityByIdentifierPort = loadServiceCityByIdentifierPort;
        this.listProfessionalReviewsByInternalAuthorIdentifierPort = listProfessionalReviewsByInternalAuthorIdentifierPort;
    }

    public CustomerProfileResponse loadCustomerProfile(UUID customerIdentifier) {
        CustomerAccount customerAccount = loadCustomerAccountByIdentifierPort.loadCustomerAccountByIdentifier(customerIdentifier)
                .orElseThrow(() -> new ResourceNotFoundException("Cliente nao encontrado."));
        CustomerProfilePreferencesProjection customerProfilePreferencesProjection =
                loadCustomerProfilePreferencesPort.loadCustomerProfilePreferences(customerIdentifier)
                        .orElseGet(() -> defaultCustomerProfilePreferences(customerIdentifier));

        List<CustomerSavedProfessionalResponse> savedProfessionals =
                listCustomerSavedProfessionalIdentifiersPort.listCustomerSavedProfessionalIdentifiers(customerIdentifier)
                        .stream()
                        .map(loadProfessionalByIdentifierPort::loadProfessionalByIdentifier)
                        .filter(Optional::isPresent)
                        .map(Optional::orElseThrow)
                        .map(this::mapSavedProfessionalResponse)
                        .toList();

        List<CustomerSubmittedReviewResponse> submittedReviews =
                listProfessionalReviewsByInternalAuthorIdentifierPort
                        .listProfessionalReviewsByInternalAuthorIdentifier(customerIdentifier)
                        .stream()
                        .map(this::mapSubmittedReviewResponse)
                        .toList();

        List<CustomerProfileCityResponse> selectedCities = deriveSelectedCities(savedProfessionals, submittedReviews);

        return new CustomerProfileResponse(
                customerAccount.customerIdentifier(),
                DEFAULT_CUSTOMER_NAME,
                customerAccount.phoneNumber(),
                selectedCities.stream().findFirst().orElse(null),
                selectedCities,
                savedProfessionals,
                submittedReviews,
                customerProfilePreferencesProjection.whatsappNotificationsEnabled(),
                customerProfilePreferencesProjection.profilePersonalizationEnabled()
        );
    }

    private CustomerProfilePreferencesProjection defaultCustomerProfilePreferences(UUID customerIdentifier) {
        return new CustomerProfilePreferencesProjection(customerIdentifier, true, true);
    }

    private CustomerSavedProfessionalResponse mapSavedProfessionalResponse(Professional professional) {
        ServiceCategory serviceCategory = loadServiceCategoryByIdentifierPort
                .loadServiceCategoryByIdentifier(professional.categoryIdentifier())
                .orElseThrow(() -> new ResourceNotFoundException("Categoria do profissional nao encontrada."));
        CustomerProfileCityResponse customerProfileCityResponse = loadServiceCityByIdentifierPort
                .loadServiceCityByIdentifier(professional.cityIdentifier())
                .map(this::mapCityResponse)
                .orElseThrow(() -> new ResourceNotFoundException("Cidade do profissional nao encontrada."));
        return new CustomerSavedProfessionalResponse(
                professional.professionalIdentifier(),
                professional.professionalName(),
                serviceCategory.categoryName(),
                customerProfileCityResponse
        );
    }

    private CustomerSubmittedReviewResponse mapSubmittedReviewResponse(ProfessionalReview professionalReview) {
        Professional professional = loadProfessionalByIdentifierPort
                .loadProfessionalByIdentifier(professionalReview.professionalIdentifier())
                .orElseThrow(() -> new ResourceNotFoundException("Profissional da avaliacao nao encontrado."));
        return new CustomerSubmittedReviewResponse(
                professionalReview.professionalReviewIdentifier(),
                professional.professionalIdentifier(),
                professional.professionalName(),
                professionalReview.starRating(),
                professionalReview.anonymousToPublic(),
                professionalReview.comment()
        );
    }

    private List<CustomerProfileCityResponse> deriveSelectedCities(
            List<CustomerSavedProfessionalResponse> savedProfessionals,
            List<CustomerSubmittedReviewResponse> submittedReviews
    ) {
        Map<UUID, CustomerProfileCityResponse> citiesByIdentifier = new LinkedHashMap<>();
        for (CustomerSavedProfessionalResponse savedProfessional : savedProfessionals) {
            citiesByIdentifier.put(savedProfessional.city().cityIdentifier(), savedProfessional.city());
        }
        for (CustomerSubmittedReviewResponse submittedReview : submittedReviews) {
            loadProfessionalByIdentifierPort.loadProfessionalByIdentifier(submittedReview.professionalIdentifier())
                    .flatMap(professional -> loadServiceCityByIdentifierPort.loadServiceCityByIdentifier(professional.cityIdentifier()))
                    .map(this::mapCityResponse)
                    .ifPresent(cityResponse -> citiesByIdentifier.putIfAbsent(cityResponse.cityIdentifier(), cityResponse));
        }
        return new ArrayList<>(citiesByIdentifier.values());
    }

    private CustomerProfileCityResponse mapCityResponse(ServiceCity serviceCity) {
        return new CustomerProfileCityResponse(
                serviceCity.cityIdentifier(),
                serviceCity.cityName(),
                serviceCity.stateCode()
        );
    }
}
