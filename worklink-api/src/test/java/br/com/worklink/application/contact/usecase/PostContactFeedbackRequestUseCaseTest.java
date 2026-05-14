package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.contact.port.PostContactFeedbackRequestProjection;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class PostContactFeedbackRequestUseCaseTest {

    @Test
    @DisplayName("GIVEN cliente com pendencias WHEN listar THEN deve retornar solicitacoes ordenadas para a UI")
    void shouldListPendingPostContactFeedbackRequests() {
        // GIVEN
        UUID customerIdentifier = UUID.randomUUID();
        UUID contactIntentIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        Instant contactCreatedAt = Instant.parse("2026-05-13T12:00:00Z");
        ListPendingPostContactFeedbackRequestsUseCase useCase =
                new ListPendingPostContactFeedbackRequestsUseCase(customer ->
                        List.of(new PostContactFeedbackRequestProjection(
                                contactIntentIdentifier,
                                professionalIdentifier,
                                "Maria Eletricista",
                                contactCreatedAt
                        )));

        // WHEN
        List<PendingPostContactFeedbackRequestResponse> responses =
                useCase.listPendingPostContactFeedbackRequests(customerIdentifier);

        // THEN
        assertThat(responses).singleElement().satisfies(response -> {
            assertThat(response.contactIntentIdentifier()).isEqualTo(contactIntentIdentifier);
            assertThat(response.professionalIdentifier()).isEqualTo(professionalIdentifier);
            assertThat(response.professionalName()).isEqualTo("Maria Eletricista");
            assertThat(response.contactCreatedAt()).isEqualTo(contactCreatedAt);
        });
    }

    @Test
    @DisplayName("GIVEN solicitacao pendente WHEN dispensar THEN deve concluir sem erro")
    void shouldDismissPendingPostContactFeedbackRequest() {
        // GIVEN
        DismissPostContactFeedbackRequestUseCase useCase =
                new DismissPostContactFeedbackRequestUseCase((customerIdentifier, contactIntentIdentifier) -> true);

        // WHEN / THEN
        useCase.dismissPostContactFeedbackRequest(UUID.randomUUID(), UUID.randomUUID());
    }

    @Test
    @DisplayName("GIVEN solicitacao inexistente WHEN dispensar THEN deve falhar")
    void shouldRejectDismissalForUnknownPendingPostContactFeedbackRequest() {
        // GIVEN
        DismissPostContactFeedbackRequestUseCase useCase =
                new DismissPostContactFeedbackRequestUseCase((customerIdentifier, contactIntentIdentifier) -> false);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.dismissPostContactFeedbackRequest(UUID.randomUUID(), UUID.randomUUID()))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Solicitacao de feedback pendente nao encontrada.");
    }
}
