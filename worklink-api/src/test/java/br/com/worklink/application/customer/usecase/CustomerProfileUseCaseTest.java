package br.com.worklink.application.customer.usecase;

import br.com.worklink.application.authentication.port.LoadCustomerAccountByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.customer.port.CustomerProfilePreferencesProjection;
import br.com.worklink.application.customer.port.ListCustomerSavedProfessionalIdentifiersPort;
import br.com.worklink.application.customer.port.LoadCustomerProfilePreferencesPort;
import br.com.worklink.application.customer.port.RemoveCustomerSavedProfessionalPort;
import br.com.worklink.application.customer.port.SaveCustomerProfilePreferencesPort;
import br.com.worklink.application.customer.port.SaveCustomerSavedProfessionalPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.review.port.ListProfessionalReviewsByInternalAuthorIdentifierPort;
import br.com.worklink.domain.authentication.CustomerAccount;
import br.com.worklink.domain.catalog.ServiceCategory;
import br.com.worklink.domain.catalog.ServiceCity;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.review.ProfessionalReview;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class CustomerProfileUseCaseTest {

    @Test
    @DisplayName("GIVEN cliente autenticado WHEN carregar perfil THEN deve agregar favoritos avaliacoes e preferencias")
    void shouldLoadCustomerProfileAggregatingSavedProfessionalsReviewsAndPreferences() {
        // GIVEN
        InMemoryCustomerProfileGateway gateway = new InMemoryCustomerProfileGateway();
        UUID customerIdentifier = UUID.randomUUID();
        UUID cityIdentifier = UUID.randomUUID();
        UUID categoryIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        UUID reviewIdentifier = UUID.randomUUID();
        gateway.customerAccount = CustomerAccount.restore(
                customerIdentifier,
                "51999991234",
                Instant.parse("2026-05-13T10:00:00Z")
        );
        gateway.preferencesProjection = new CustomerProfilePreferencesProjection(customerIdentifier, false, true);
        gateway.savedProfessionalIdentifiers.add(professionalIdentifier);
        gateway.professionalsByIdentifier.put(
                professionalIdentifier,
                Professional.restoreProfessional(
                        professionalIdentifier,
                        "Maria Eletricista",
                        "51999999999",
                        cityIdentifier,
                        categoryIdentifier,
                        "Atendimento residencial.",
                        null,
                        null,
                        null,
                        null,
                        null,
                        50,
                        br.com.worklink.domain.professional.ProfessionalProfileClassification.BASIC_PROFILE,
                        br.com.worklink.domain.professional.ProfessionalAvailabilityStatus.ACCEPTING_NEW_CLIENTS,
                        false,
                        false,
                        false
                )
        );
        gateway.categoriesByIdentifier.put(
                categoryIdentifier,
                ServiceCategory.restoreServiceCategory(categoryIdentifier, "Eletricista", "eletricista")
        );
        gateway.citiesByIdentifier.put(
                cityIdentifier,
                ServiceCity.restoreServiceCity(cityIdentifier, "Canoas", "RS", "canoas-rs")
        );
        gateway.reviewsByCustomer.add(
                ProfessionalReview.restoreProfessionalReview(
                        reviewIdentifier,
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        professionalIdentifier,
                        customerIdentifier,
                        5,
                        "Excelente atendimento",
                        true,
                        null,
                        "Usuario anonimo",
                        false,
                        Instant.parse("2026-05-13T11:00:00Z")
                )
        );
        LoadCustomerProfileUseCase useCase = gateway.loadCustomerProfileUseCase();

        // WHEN
        CustomerProfileResponse customerProfileResponse = useCase.loadCustomerProfile(customerIdentifier);

        // THEN
        assertThat(customerProfileResponse.customerName()).isEqualTo("Cliente Exemplo");
        assertThat(customerProfileResponse.phoneNumber()).isEqualTo("51999991234");
        assertThat(customerProfileResponse.mainCity().cityName()).isEqualTo("Canoas");
        assertThat(customerProfileResponse.selectedCities()).hasSize(1);
        assertThat(customerProfileResponse.savedProfessionals()).singleElement().satisfies(savedProfessional -> {
            assertThat(savedProfessional.professionalName()).isEqualTo("Maria Eletricista");
            assertThat(savedProfessional.categoryName()).isEqualTo("Eletricista");
        });
        assertThat(customerProfileResponse.submittedReviews()).singleElement().satisfies(submittedReview -> {
            assertThat(submittedReview.professionalName()).isEqualTo("Maria Eletricista");
            assertThat(submittedReview.publiclyAnonymous()).isTrue();
        });
        assertThat(customerProfileResponse.whatsappNotificationsEnabled()).isFalse();
        assertThat(customerProfileResponse.profilePersonalizationEnabled()).isTrue();
    }

    @Test
    @DisplayName("GIVEN preferencias atualizadas WHEN salvar THEN deve devolver perfil recalculado")
    void shouldUpdatePreferencesAndReturnReloadedCustomerProfile() {
        // GIVEN
        InMemoryCustomerProfileGateway gateway = new InMemoryCustomerProfileGateway();
        UUID customerIdentifier = UUID.randomUUID();
        gateway.customerAccount = CustomerAccount.restore(
                customerIdentifier,
                "51999991234",
                Instant.parse("2026-05-13T10:00:00Z")
        );
        UpdateCustomerProfilePreferencesUseCase useCase = new UpdateCustomerProfilePreferencesUseCase(
                gateway,
                gateway.loadCustomerProfileUseCase()
        );

        // WHEN
        CustomerProfileResponse customerProfileResponse = useCase.updateCustomerProfilePreferences(
                new UpdateCustomerProfilePreferencesRequest(
                        new br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal(
                                customerIdentifier,
                                br.com.worklink.application.authorization.usecase.AuthenticatedProfile.CUSTOMER
                        ),
                        false,
                        false
                )
        );

        // THEN
        assertThat(gateway.preferencesProjection.whatsappNotificationsEnabled()).isFalse();
        assertThat(gateway.preferencesProjection.profilePersonalizationEnabled()).isFalse();
        assertThat(customerProfileResponse.whatsappNotificationsEnabled()).isFalse();
        assertThat(customerProfileResponse.profilePersonalizationEnabled()).isFalse();
    }

    private static class InMemoryCustomerProfileGateway implements
            LoadCustomerAccountByIdentifierPort,
            LoadCustomerProfilePreferencesPort,
            SaveCustomerProfilePreferencesPort,
            ListCustomerSavedProfessionalIdentifiersPort,
            SaveCustomerSavedProfessionalPort,
            RemoveCustomerSavedProfessionalPort,
            LoadProfessionalByIdentifierPort,
            LoadServiceCategoryByIdentifierPort,
            LoadServiceCityByIdentifierPort,
            ListProfessionalReviewsByInternalAuthorIdentifierPort {

        private CustomerAccount customerAccount;
        private CustomerProfilePreferencesProjection preferencesProjection;
        private final List<UUID> savedProfessionalIdentifiers = new ArrayList<>();
        private final Map<UUID, Professional> professionalsByIdentifier = new LinkedHashMap<>();
        private final Map<UUID, ServiceCategory> categoriesByIdentifier = new LinkedHashMap<>();
        private final Map<UUID, ServiceCity> citiesByIdentifier = new LinkedHashMap<>();
        private final List<ProfessionalReview> reviewsByCustomer = new ArrayList<>();

        private LoadCustomerProfileUseCase loadCustomerProfileUseCase() {
            return new LoadCustomerProfileUseCase(this, this, this, this, this, this, this);
        }

        @Override
        public Optional<CustomerAccount> loadCustomerAccountByIdentifier(UUID customerIdentifier) {
            return Optional.ofNullable(customerAccount);
        }

        @Override
        public Optional<CustomerProfilePreferencesProjection> loadCustomerProfilePreferences(UUID customerIdentifier) {
            return Optional.ofNullable(preferencesProjection);
        }

        @Override
        public CustomerProfilePreferencesProjection saveCustomerProfilePreferences(
                CustomerProfilePreferencesProjection customerProfilePreferencesProjection
        ) {
            preferencesProjection = customerProfilePreferencesProjection;
            return customerProfilePreferencesProjection;
        }

        @Override
        public List<UUID> listCustomerSavedProfessionalIdentifiers(UUID customerIdentifier) {
            return List.copyOf(savedProfessionalIdentifiers);
        }

        @Override
        public void saveCustomerSavedProfessional(UUID customerIdentifier, UUID professionalIdentifier) {
            savedProfessionalIdentifiers.add(professionalIdentifier);
        }

        @Override
        public void removeCustomerSavedProfessional(UUID customerIdentifier, UUID professionalIdentifier) {
            savedProfessionalIdentifiers.remove(professionalIdentifier);
        }

        @Override
        public Optional<Professional> loadProfessionalByIdentifier(UUID professionalIdentifier) {
            return Optional.ofNullable(professionalsByIdentifier.get(professionalIdentifier));
        }

        @Override
        public Optional<ServiceCategory> loadServiceCategoryByIdentifier(UUID categoryIdentifier) {
            return Optional.ofNullable(categoriesByIdentifier.get(categoryIdentifier));
        }

        @Override
        public Optional<ServiceCity> loadServiceCityByIdentifier(UUID cityIdentifier) {
            return Optional.ofNullable(citiesByIdentifier.get(cityIdentifier));
        }

        @Override
        public List<ProfessionalReview> listProfessionalReviewsByInternalAuthorIdentifier(UUID internalAuthorIdentifier) {
            return List.copyOf(reviewsByCustomer);
        }
    }
}
