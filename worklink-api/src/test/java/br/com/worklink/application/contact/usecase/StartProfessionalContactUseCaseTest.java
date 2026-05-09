package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.domain.contact.ContactIntent;
import br.com.worklink.domain.professional.Professional;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class StartProfessionalContactUseCaseTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();
    private static final Instant CREATED_AT = Instant.parse("2026-05-08T10:15:30Z");

    @Test
    @DisplayName("Deve registrar intencao antes de retornar link WhatsApp para cliente autenticado")
    void shouldRegisterContactIntentBeforeReturningWhatsappLinkForAuthenticatedCustomer() {
        // GIVEN
        Professional professional = validProfessional();
        AtomicReference<ContactIntent> savedContactIntent = new AtomicReference<>();
        AtomicBoolean contactIntentSavedBeforeWhatsappLink = new AtomicBoolean(false);
        StartProfessionalContactUseCase useCase = new StartProfessionalContactUseCase(
                professionalIdentifier -> Optional.of(professional),
                contactIntent -> {
                    savedContactIntent.set(contactIntent);
                    return contactIntent;
                },
                () -> CREATED_AT,
                whatsappNumber -> {
                    contactIntentSavedBeforeWhatsappLink.set(savedContactIntent.get() != null);
                    return "https://wa.me/%s".formatted(whatsappNumber);
                }
        );
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.CUSTOMER
        );

        // WHEN
        StartProfessionalContactResponse response = useCase.startProfessionalContact(new StartProfessionalContactRequest(
                customerPrincipal,
                professional.professionalIdentifier()
        ));

        // THEN
        assertThat(contactIntentSavedBeforeWhatsappLink).isTrue();
        assertThat(savedContactIntent.get().customerIdentifier()).isEqualTo(customerPrincipal.principalIdentifier());
        assertThat(savedContactIntent.get().professionalIdentifier()).isEqualTo(professional.professionalIdentifier());
        assertThat(savedContactIntent.get().createdAt()).isEqualTo(CREATED_AT);
        assertThat(response.contactIntentIdentifier()).isEqualTo(savedContactIntent.get().contactIntentIdentifier());
        assertThat(response.whatsappContactLink()).isEqualTo("https://wa.me/51999999999");
        assertThat(response.professionalName()).isEqualTo("Maria Eletricista");
    }

    @Test
    @DisplayName("Deve negar contato quando principal autenticado nao for cliente")
    void shouldDenyContactWhenAuthenticatedPrincipalIsNotCustomer() {
        // GIVEN
        StartProfessionalContactUseCase useCase = new StartProfessionalContactUseCase(
                professionalIdentifier -> Optional.of(validProfessional()),
                contactIntent -> contactIntent,
                () -> CREATED_AT,
                whatsappNumber -> "https://wa.me/%s".formatted(whatsappNumber)
        );
        AuthenticatedPrincipal professionalPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.PROFESSIONAL
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.startProfessionalContact(new StartProfessionalContactRequest(
                professionalPrincipal,
                UUID.randomUUID()
        )))
                .isInstanceOf(AuthorizationDeniedException.class)
                .hasMessage("Apenas cliente autenticado pode iniciar contato.");
    }

    @Test
    @DisplayName("Deve rejeitar contato quando profissional nao existir")
    void shouldRejectContactWhenProfessionalDoesNotExist() {
        // GIVEN
        StartProfessionalContactUseCase useCase = new StartProfessionalContactUseCase(
                professionalIdentifier -> Optional.empty(),
                contactIntent -> contactIntent,
                () -> CREATED_AT,
                whatsappNumber -> "https://wa.me/%s".formatted(whatsappNumber)
        );
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(
                UUID.randomUUID(),
                AuthenticatedProfile.CUSTOMER
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.startProfessionalContact(new StartProfessionalContactRequest(
                customerPrincipal,
                UUID.randomUUID()
        )))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O profissional informado nao foi encontrado.");
    }

    private Professional validProfessional() {
        return Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
    }
}
