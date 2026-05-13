package br.com.worklink.domain.professional;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ProfessionalPortfolioItemTest {

    @Test
    @DisplayName("GIVEN dados validos WHEN adicionar item de portfolio THEN deve criar item ativo")
    void shouldCreateActivePortfolioItemWhenAddingValidPortfolioData() {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID fileIdentifier = UUID.randomUUID();

        // WHEN
        ProfessionalPortfolioItem portfolioItem = ProfessionalPortfolioItem.addProfessionalPortfolioItem(
                professionalIdentifier,
                fileIdentifier,
                "Quadro eletrico residencial",
                "Antes e depois de instalacao residencial.",
                2
        );

        // THEN
        assertThat(portfolioItem.portfolioItemIdentifier()).isNotNull();
        assertThat(portfolioItem.professionalIdentifier()).isEqualTo(professionalIdentifier);
        assertThat(portfolioItem.fileIdentifier()).isEqualTo(fileIdentifier);
        assertThat(portfolioItem.title()).isEqualTo("Quadro eletrico residencial");
        assertThat(portfolioItem.description()).isEqualTo("Antes e depois de instalacao residencial.");
        assertThat(portfolioItem.displayOrder()).isEqualTo(2);
        assertThat(portfolioItem.active()).isTrue();
    }

    @Test
    @DisplayName("GIVEN titulo vazio WHEN adicionar item de portfolio THEN deve rejeitar item")
    void shouldRejectPortfolioItemWithoutTitle() {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID fileIdentifier = UUID.randomUUID();

        // WHEN / THEN
        assertThatThrownBy(() -> ProfessionalPortfolioItem.addProfessionalPortfolioItem(
                professionalIdentifier,
                fileIdentifier,
                " ",
                null,
                0
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O titulo do item de portfolio e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN ordem negativa WHEN adicionar item de portfolio THEN deve rejeitar item")
    void shouldRejectPortfolioItemWithNegativeDisplayOrder() {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID fileIdentifier = UUID.randomUUID();

        // WHEN / THEN
        assertThatThrownBy(() -> ProfessionalPortfolioItem.addProfessionalPortfolioItem(
                professionalIdentifier,
                fileIdentifier,
                "Quadro eletrico residencial",
                null,
                -1
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A ordem do item de portfolio nao pode ser negativa.");
    }

    @Test
    @DisplayName("GIVEN dados persistidos WHEN restaurar item de portfolio THEN deve preservar estado")
    void shouldPreservePortfolioItemStateWhenRestoringPersistedData() {
        // GIVEN
        UUID portfolioItemIdentifier = UUID.randomUUID();
        UUID professionalIdentifier = UUID.randomUUID();
        UUID fileIdentifier = UUID.randomUUID();

        // WHEN
        ProfessionalPortfolioItem portfolioItem = ProfessionalPortfolioItem.restoreProfessionalPortfolioItem(
                portfolioItemIdentifier,
                professionalIdentifier,
                fileIdentifier,
                " Quadro eletrico residencial ",
                " ",
                0,
                false
        );

        // THEN
        assertThat(portfolioItem.portfolioItemIdentifier()).isEqualTo(portfolioItemIdentifier);
        assertThat(portfolioItem.professionalIdentifier()).isEqualTo(professionalIdentifier);
        assertThat(portfolioItem.fileIdentifier()).isEqualTo(fileIdentifier);
        assertThat(portfolioItem.title()).isEqualTo("Quadro eletrico residencial");
        assertThat(portfolioItem.description()).isNull();
        assertThat(portfolioItem.active()).isFalse();
    }

    @Test
    @DisplayName("GIVEN identificador ausente WHEN restaurar item de portfolio THEN deve rejeitar estado invalido")
    void shouldRejectPortfolioItemWithoutIdentifierWhenRestoringPersistedData() {
        // WHEN / THEN
        assertThatThrownBy(() -> ProfessionalPortfolioItem.restoreProfessionalPortfolioItem(
                null,
                UUID.randomUUID(),
                UUID.randomUUID(),
                "Quadro eletrico residencial",
                null,
                0,
                true
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O identificador do item de portfolio e obrigatorio.");
    }
}
