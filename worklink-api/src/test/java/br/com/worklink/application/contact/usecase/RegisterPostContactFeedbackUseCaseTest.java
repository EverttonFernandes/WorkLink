package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.domain.contact.ContactIntent;
import br.com.worklink.domain.contact.PostContactFeedback;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RegisterPostContactFeedbackUseCaseTest {

    private static final UUID PROFESSIONAL_IDENTIFIER = UUID.randomUUID();
    private static final Instant CONTACT_CREATED_AT = Instant.parse("2026-05-09T10:00:00Z");
    private static final Instant FEEDBACK_CREATED_AT = Instant.parse("2026-05-09T12:00:00Z");

    @Test
    @DisplayName("Deve registrar feedback pos-contato para intencao existente do cliente")
    void shouldRegisterPostContactFeedbackForExistingCustomerContactIntent() {
        // GIVEN
        UUID customerIdentifier = UUID.randomUUID();
        ContactIntent contactIntent = contactIntentForCustomer(customerIdentifier);
        AtomicReference<PostContactFeedback> savedFeedback = new AtomicReference<>();
        RegisterPostContactFeedbackUseCase useCase = new RegisterPostContactFeedbackUseCase(
                contactIntentIdentifier -> Optional.of(contactIntent),
                postContactFeedback -> {
                    savedFeedback.set(postContactFeedback);
                    return postContactFeedback;
                },
                (savedCustomerIdentifier, savedContactIntentIdentifier) -> {
                },
                () -> FEEDBACK_CREATED_AT
        );
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(customerIdentifier, AuthenticatedProfile.CUSTOMER);

        // WHEN
        RegisterPostContactFeedbackResponse response = useCase.registerPostContactFeedback(validRequest(customerPrincipal, contactIntent));

        // THEN
        assertThat(savedFeedback.get().contactIntentIdentifier()).isEqualTo(contactIntent.contactIntentIdentifier());
        assertThat(savedFeedback.get().customerIdentifier()).isEqualTo(customerIdentifier);
        assertThat(savedFeedback.get().createdAt()).isEqualTo(FEEDBACK_CREATED_AT);
        assertThat(response.conversationOutcome()).isEqualTo("CUSTOMER_REACHED_PROFESSIONAL");
        assertThat(response.contactResponsiveness()).isEqualTo("FAST_RESPONSE");
        assertThat(response.serviceExecutionOutcome()).isEqualTo("SERVICE_PERFORMED");
    }

    @Test
    @DisplayName("Deve rejeitar feedback quando intencao de contato nao existir")
    void shouldRejectFeedbackWhenContactIntentDoesNotExist() {
        // GIVEN
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER);
        RegisterPostContactFeedbackUseCase useCase = new RegisterPostContactFeedbackUseCase(
                contactIntentIdentifier -> Optional.empty(),
                postContactFeedback -> postContactFeedback,
                (savedCustomerIdentifier, savedContactIntentIdentifier) -> {
                },
                () -> FEEDBACK_CREATED_AT
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerPostContactFeedback(new RegisterPostContactFeedbackRequest(
                customerPrincipal,
                UUID.randomUUID(),
                "CUSTOMER_REACHED_PROFESSIONAL",
                "FAST_RESPONSE",
                "SERVICE_PERFORMED"
        )))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A intencao de contato informada nao foi encontrada.");
    }

    @Test
    @DisplayName("Deve negar feedback para cliente diferente do contato")
    void shouldDenyFeedbackForDifferentCustomer() {
        // GIVEN
        ContactIntent contactIntent = contactIntentForCustomer(UUID.randomUUID());
        AuthenticatedPrincipal otherCustomerPrincipal = new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER);
        RegisterPostContactFeedbackUseCase useCase = new RegisterPostContactFeedbackUseCase(
                contactIntentIdentifier -> Optional.of(contactIntent),
                postContactFeedback -> postContactFeedback,
                (savedCustomerIdentifier, savedContactIntentIdentifier) -> {
                },
                () -> FEEDBACK_CREATED_AT
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerPostContactFeedback(validRequest(otherCustomerPrincipal, contactIntent)))
                .isInstanceOf(AuthorizationDeniedException.class)
                .hasMessage("Apenas o cliente que iniciou o contato pode registrar feedback.");
    }

    @Test
    @DisplayName("Deve rejeitar feedback com respostas fora das opcoes permitidas")
    void shouldRejectFeedbackWithAnswersOutsideAllowedOptions() {
        // GIVEN
        UUID customerIdentifier = UUID.randomUUID();
        ContactIntent contactIntent = contactIntentForCustomer(customerIdentifier);
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(customerIdentifier, AuthenticatedProfile.CUSTOMER);
        RegisterPostContactFeedbackUseCase useCase = new RegisterPostContactFeedbackUseCase(
                contactIntentIdentifier -> Optional.of(contactIntent),
                postContactFeedback -> postContactFeedback,
                (savedCustomerIdentifier, savedContactIntentIdentifier) -> {
                },
                () -> FEEDBACK_CREATED_AT
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerPostContactFeedback(new RegisterPostContactFeedbackRequest(
                customerPrincipal,
                contactIntent.contactIntentIdentifier(),
                "FALOU_COM_PROFISSIONAL",
                "FAST_RESPONSE",
                "SERVICE_PERFORMED"
        )))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("As respostas do feedback pos-contato sao invalidas.");
    }

    private RegisterPostContactFeedbackRequest validRequest(
            AuthenticatedPrincipal customerPrincipal,
            ContactIntent contactIntent
    ) {
        return new RegisterPostContactFeedbackRequest(
                customerPrincipal,
                contactIntent.contactIntentIdentifier(),
                "CUSTOMER_REACHED_PROFESSIONAL",
                "FAST_RESPONSE",
                "SERVICE_PERFORMED"
        );
    }

    private ContactIntent contactIntentForCustomer(UUID customerIdentifier) {
        return ContactIntent.registerContactIntent(
                customerIdentifier,
                PROFESSIONAL_IDENTIFIER,
                "51999999999",
                CONTACT_CREATED_AT
        );
    }
}
