package br.com.worklink.application.privacy.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ReviewAuthorPrivacyProjectionTest {

    @Test
    @DisplayName("GIVEN avaliacao anonima WHEN projetar autoria publica THEN deve ocultar identidade e manter autoria interna")
    void shouldHidePublicIdentityAndKeepInternalAuthorshipForAnonymousReview() {
        // GIVEN
        UUID internalAuthorIdentifier = UUID.randomUUID();

        // WHEN
        ReviewAuthorPrivacyProjection reviewAuthorPrivacyProjection = ReviewAuthorPrivacyProjection.fromReviewAuthor(
                internalAuthorIdentifier,
                UUID.randomUUID(),
                "Maria",
                true
        );

        // THEN
        assertThat(reviewAuthorPrivacyProjection.internalAuthorIdentifier()).isEqualTo(internalAuthorIdentifier);
        assertThat(reviewAuthorPrivacyProjection.publicAuthorIdentifier()).isNull();
        assertThat(reviewAuthorPrivacyProjection.publicAuthorDisplayName()).isEqualTo("Usuario anonimo");
        assertThat(reviewAuthorPrivacyProjection.anonymousToPublic()).isTrue();
    }

    @Test
    @DisplayName("GIVEN avaliacao identificada WHEN projetar autoria publica THEN deve expor somente dados publicos")
    void shouldExposePublicAuthorWhenReviewIsIdentified() {
        // GIVEN
        UUID internalAuthorIdentifier = UUID.randomUUID();
        UUID publicAuthorIdentifier = UUID.randomUUID();

        // WHEN
        ReviewAuthorPrivacyProjection reviewAuthorPrivacyProjection = ReviewAuthorPrivacyProjection.fromReviewAuthor(
                internalAuthorIdentifier,
                publicAuthorIdentifier,
                " Maria ",
                false
        );

        // THEN
        assertThat(reviewAuthorPrivacyProjection.internalAuthorIdentifier()).isEqualTo(internalAuthorIdentifier);
        assertThat(reviewAuthorPrivacyProjection.publicAuthorIdentifier()).isEqualTo(publicAuthorIdentifier);
        assertThat(reviewAuthorPrivacyProjection.publicAuthorDisplayName()).isEqualTo("Maria");
        assertThat(reviewAuthorPrivacyProjection.anonymousToPublic()).isFalse();
    }

    @Test
    @DisplayName("GIVEN autoria interna ausente WHEN projetar avaliacao THEN deve rejeitar sem perder rastreabilidade")
    void shouldRejectReviewProjectionWithoutInternalAuthorship() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> ReviewAuthorPrivacyProjection.fromReviewAuthor(null, UUID.randomUUID(), "Maria", true))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A autoria interna da avaliacao e obrigatoria.");
    }

    @Test
    @DisplayName("GIVEN avaliacao identificada sem nome publico WHEN projetar autoria THEN deve rejeitar")
    void shouldRejectIdentifiedReviewWithoutPublicName() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> ReviewAuthorPrivacyProjection.fromReviewAuthor(
                UUID.randomUUID(),
                UUID.randomUUID(),
                " ",
                false
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O nome publico da avaliacao identificada e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN avaliacao identificada sem autor publico WHEN projetar autoria THEN deve rejeitar")
    void shouldRejectIdentifiedReviewWithoutPublicAuthorIdentifier() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> ReviewAuthorPrivacyProjection.fromReviewAuthor(
                UUID.randomUUID(),
                null,
                "Maria",
                false
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A autoria publica da avaliacao identificada e obrigatoria.");
    }
}
