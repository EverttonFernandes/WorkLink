package br.com.worklink.application.review.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.domain.contact.ContactConversationOutcome;
import br.com.worklink.domain.contact.ContactIntent;
import br.com.worklink.domain.contact.ContactResponsiveness;
import br.com.worklink.domain.contact.PostContactFeedback;
import br.com.worklink.domain.contact.ServiceExecutionOutcome;
import br.com.worklink.domain.review.ProfessionalReview;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class RegisterProfessionalReviewUseCaseTest {

    private static final UUID PROFESSIONAL_IDENTIFIER = UUID.randomUUID();
    private static final Instant CONTACT_CREATED_AT = Instant.parse("2026-05-09T10:00:00Z");
    private static final Instant REVIEW_CREATED_AT = Instant.parse("2026-05-09T13:00:00Z");

    @Test
    @DisplayName("GIVEN servico realizado WHEN avaliar anonimamente THEN deve armazenar autoria interna e ocultar autoria publica")
    void shouldRegisterAnonymousReviewWhenServiceWasPerformed() {
        // GIVEN
        UUID customerIdentifier = UUID.randomUUID();
        ContactIntent contactIntent = contactIntentForCustomer(customerIdentifier);
        PostContactFeedback feedback = feedbackForContact(contactIntent, ServiceExecutionOutcome.SERVICE_PERFORMED);
        AtomicReference<ProfessionalReview> savedReview = new AtomicReference<>();
        RegisterProfessionalReviewUseCase useCase = reviewUseCase(contactIntent, feedback, savedReview);
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(customerIdentifier, AuthenticatedProfile.CUSTOMER);

        // WHEN
        RegisterProfessionalReviewResponse response = useCase.registerProfessionalReview(new RegisterProfessionalReviewRequest(
                customerPrincipal,
                contactIntent.contactIntentIdentifier(),
                5,
                "  Excelente atendimento  ",
                true
        ));

        // THEN
        assertThat(savedReview.get().internalAuthorIdentifier()).isEqualTo(customerIdentifier);
        assertThat(savedReview.get().publicAuthorIdentifier()).isNull();
        assertThat(savedReview.get().publicAuthorDisplayName()).isEqualTo("Usuario anonimo");
        assertThat(savedReview.get().comment()).isEqualTo("Excelente atendimento");
        assertThat(response.publicAuthorIdentifier()).isNull();
        assertThat(response.publicAuthorDisplayName()).isEqualTo("Usuario anonimo");
        assertThat(response.professionalIdentifier()).isEqualTo(PROFESSIONAL_IDENTIFIER);
    }

    @Test
    @DisplayName("GIVEN servico realizado WHEN avaliar identificado THEN deve expor somente autoria publica permitida")
    void shouldRegisterIdentifiedReviewWithAllowedPublicAuthorProjection() {
        // GIVEN
        UUID customerIdentifier = UUID.randomUUID();
        ContactIntent contactIntent = contactIntentForCustomer(customerIdentifier);
        PostContactFeedback feedback = feedbackForContact(contactIntent, ServiceExecutionOutcome.SERVICE_PERFORMED);
        AtomicReference<ProfessionalReview> savedReview = new AtomicReference<>();
        RegisterProfessionalReviewUseCase useCase = reviewUseCase(contactIntent, feedback, savedReview);
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(customerIdentifier, AuthenticatedProfile.CUSTOMER);

        // WHEN
        RegisterProfessionalReviewResponse response = useCase.registerProfessionalReview(new RegisterProfessionalReviewRequest(
                customerPrincipal,
                contactIntent.contactIntentIdentifier(),
                4,
                null,
                false
        ));

        // THEN
        assertThat(savedReview.get().internalAuthorIdentifier()).isEqualTo(customerIdentifier);
        assertThat(savedReview.get().publicAuthorIdentifier()).isEqualTo(customerIdentifier);
        assertThat(savedReview.get().publicAuthorDisplayName()).isEqualTo("Cliente WorkLink");
        assertThat(savedReview.get().comment()).isNull();
        assertThat(response.anonymousToPublic()).isFalse();
        assertThat(response.publicAuthorIdentifier()).isEqualTo(customerIdentifier);
    }

    @Test
    @DisplayName("GIVEN feedback sem servico realizado WHEN avaliar THEN deve rejeitar avaliacao")
    void shouldRejectReviewWhenServiceWasNotPerformed() {
        // GIVEN
        UUID customerIdentifier = UUID.randomUUID();
        ContactIntent contactIntent = contactIntentForCustomer(customerIdentifier);
        PostContactFeedback feedback = feedbackForContact(contactIntent, ServiceExecutionOutcome.SERVICE_NOT_PERFORMED);
        RegisterProfessionalReviewUseCase useCase = reviewUseCase(contactIntent, feedback, new AtomicReference<>());
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(customerIdentifier, AuthenticatedProfile.CUSTOMER);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerProfessionalReview(new RegisterProfessionalReviewRequest(
                customerPrincipal,
                contactIntent.contactIntentIdentifier(),
                5,
                null,
                true
        )))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A avaliacao exige servico realizado.");
    }

    @Test
    @DisplayName("GIVEN contato de outro cliente WHEN avaliar THEN deve negar por ownership")
    void shouldDenyReviewForDifferentCustomer() {
        // GIVEN
        ContactIntent contactIntent = contactIntentForCustomer(UUID.randomUUID());
        PostContactFeedback feedback = feedbackForContact(contactIntent, ServiceExecutionOutcome.SERVICE_PERFORMED);
        RegisterProfessionalReviewUseCase useCase = reviewUseCase(contactIntent, feedback, new AtomicReference<>());
        AuthenticatedPrincipal otherCustomerPrincipal = new AuthenticatedPrincipal(UUID.randomUUID(), AuthenticatedProfile.CUSTOMER);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerProfessionalReview(new RegisterProfessionalReviewRequest(
                otherCustomerPrincipal,
                contactIntent.contactIntentIdentifier(),
                5,
                null,
                false
        )))
                .isInstanceOf(AuthorizationDeniedException.class)
                .hasMessage("Apenas o cliente que iniciou o contato pode avaliar o profissional.");
    }

    @Test
    @DisplayName("GIVEN contato sem feedback pos-contato WHEN avaliar THEN deve rejeitar elegibilidade")
    void shouldRejectReviewWithoutPostContactFeedback() {
        // GIVEN
        UUID customerIdentifier = UUID.randomUUID();
        ContactIntent contactIntent = contactIntentForCustomer(customerIdentifier);
        RegisterProfessionalReviewUseCase useCase = new RegisterProfessionalReviewUseCase(
                contactIntentIdentifier -> Optional.of(contactIntent),
                contactIntentIdentifier -> Optional.empty(),
                professionalReview -> professionalReview,
                () -> REVIEW_CREATED_AT
        );
        AuthenticatedPrincipal customerPrincipal = new AuthenticatedPrincipal(customerIdentifier, AuthenticatedProfile.CUSTOMER);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.registerProfessionalReview(new RegisterProfessionalReviewRequest(
                customerPrincipal,
                contactIntent.contactIntentIdentifier(),
                4,
                null,
                true
        )))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A avaliacao exige feedback pos-contato registrado.");
    }

    private RegisterProfessionalReviewUseCase reviewUseCase(
            ContactIntent contactIntent,
            PostContactFeedback feedback,
            AtomicReference<ProfessionalReview> savedReview
    ) {
        return new RegisterProfessionalReviewUseCase(
                contactIntentIdentifier -> Optional.of(contactIntent),
                contactIntentIdentifier -> Optional.of(feedback),
                professionalReview -> {
                    savedReview.set(professionalReview);
                    return professionalReview;
                },
                () -> REVIEW_CREATED_AT
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

    private PostContactFeedback feedbackForContact(
            ContactIntent contactIntent,
            ServiceExecutionOutcome serviceExecutionOutcome
    ) {
        return PostContactFeedback.registerPostContactFeedback(
                contactIntent.contactIntentIdentifier(),
                contactIntent.customerIdentifier(),
                ContactConversationOutcome.CUSTOMER_REACHED_PROFESSIONAL,
                ContactResponsiveness.FAST_RESPONSE,
                serviceExecutionOutcome,
                Instant.parse("2026-05-09T12:00:00Z")
        );
    }
}
