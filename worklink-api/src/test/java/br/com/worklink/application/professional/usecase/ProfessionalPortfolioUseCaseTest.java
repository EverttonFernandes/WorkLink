package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.professional.port.ListProfessionalPortfolioItemsPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.SaveProfessionalPortfolioItemPort;
import br.com.worklink.application.storage.port.LoadStoredFileMetadataPort;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalPortfolioItem;
import br.com.worklink.domain.storage.StoredFile;
import br.com.worklink.domain.storage.StoredFileAccessLevel;
import br.com.worklink.domain.storage.StoredFilePurpose;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ProfessionalPortfolioUseCaseTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("GIVEN profissional e arquivo de portfolio WHEN adicionar item THEN deve salvar item publico")
    void shouldSavePublicPortfolioItemWhenProfessionalAndStoredFileExist() {
        // GIVEN
        InMemoryProfessionalPortfolioPort inMemoryProfessionalPortfolioPort = new InMemoryProfessionalPortfolioPort();
        Professional professional = Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
        StoredFile portfolioStoredFile = publicPortfolioStoredFile(UUID.randomUUID());
        AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase = new AddProfessionalPortfolioItemUseCase(
                professionalIdentifier -> Optional.of(professional),
                fileIdentifier -> Optional.of(portfolioStoredFile),
                inMemoryProfessionalPortfolioPort,
                inMemoryProfessionalPortfolioPort
        );

        // WHEN
        ProfessionalPortfolioItemResponse response = addProfessionalPortfolioItemUseCase.addProfessionalPortfolioItem(
                new AddProfessionalPortfolioItemRequest(
                        professional.professionalIdentifier(),
                        portfolioStoredFile.fileIdentifier(),
                        "Quadro eletrico residencial",
                        "Instalacao concluida em apartamento.",
                        1
                )
        );

        // THEN
        assertThat(response.professionalIdentifier()).isEqualTo(professional.professionalIdentifier());
        assertThat(response.fileIdentifier()).isEqualTo(portfolioStoredFile.fileIdentifier());
        assertThat(response.title()).isEqualTo("Quadro eletrico residencial");
        assertThat(response.description()).isEqualTo("Instalacao concluida em apartamento.");
        assertThat(inMemoryProfessionalPortfolioPort.portfolioItems).hasSize(1);
    }

    @Test
    @DisplayName("GIVEN arquivo confidencial WHEN adicionar item THEN deve rejeitar portfolio")
    void shouldRejectPortfolioItemWhenStoredFileIsNotPublicPortfolio() {
        // GIVEN
        Professional professional = Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
        StoredFile confidentialStoredFile = StoredFile.restoreStoredFile(
                UUID.randomUUID(),
                StoredFilePurpose.REPORT_EVIDENCE,
                StoredFileAccessLevel.CONFIDENTIAL,
                "evidencia.pdf",
                "application/pdf",
                "pdf",
                300_000L,
                "report-evidences/internal-key.pdf"
        );
        AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase = new AddProfessionalPortfolioItemUseCase(
                professionalIdentifier -> Optional.of(professional),
                fileIdentifier -> Optional.of(confidentialStoredFile),
                professionalIdentifier -> List.of(),
                professionalPortfolioItem -> professionalPortfolioItem
        );

        // WHEN / THEN
        assertThatThrownBy(() -> addProfessionalPortfolioItemUseCase.addProfessionalPortfolioItem(
                new AddProfessionalPortfolioItemRequest(
                        professional.professionalIdentifier(),
                        confidentialStoredFile.fileIdentifier(),
                        "Evidencia indevida",
                        null,
                        0
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O arquivo informado nao pode ser usado como portfolio profissional.");
    }

    @Test
    @DisplayName("GIVEN profissional inexistente WHEN adicionar portfolio THEN deve rejeitar item")
    void shouldRejectPortfolioItemWhenProfessionalDoesNotExist() {
        // GIVEN
        AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase = new AddProfessionalPortfolioItemUseCase(
                professionalIdentifier -> Optional.empty(),
                fileIdentifier -> Optional.of(publicPortfolioStoredFile(fileIdentifier)),
                professionalIdentifier -> List.of(),
                professionalPortfolioItem -> professionalPortfolioItem
        );

        // WHEN / THEN
        assertThatThrownBy(() -> addProfessionalPortfolioItemUseCase.addProfessionalPortfolioItem(
                new AddProfessionalPortfolioItemRequest(
                        UUID.randomUUID(),
                        UUID.randomUUID(),
                        "Quadro eletrico residencial",
                        null,
                        0
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O profissional informado nao foi encontrado.");
    }

    @Test
    @DisplayName("GIVEN arquivo inexistente WHEN adicionar portfolio THEN deve rejeitar item")
    void shouldRejectPortfolioItemWhenStoredFileDoesNotExist() {
        // GIVEN
        Professional professional = Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
        AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase = new AddProfessionalPortfolioItemUseCase(
                professionalIdentifier -> Optional.of(professional),
                fileIdentifier -> Optional.empty(),
                professionalIdentifier -> List.of(),
                professionalPortfolioItem -> professionalPortfolioItem
        );

        // WHEN / THEN
        assertThatThrownBy(() -> addProfessionalPortfolioItemUseCase.addProfessionalPortfolioItem(
                new AddProfessionalPortfolioItemRequest(
                        professional.professionalIdentifier(),
                        UUID.randomUUID(),
                        "Quadro eletrico residencial",
                        null,
                        0
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O arquivo de portfolio informado nao foi encontrado.");
    }

    @Test
    @DisplayName("GIVEN titulo invalido WHEN adicionar portfolio THEN deve traduzir erro de dominio")
    void shouldTranslateDomainErrorWhenPortfolioTitleIsInvalid() {
        // GIVEN
        Professional professional = Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
        StoredFile portfolioStoredFile = publicPortfolioStoredFile(UUID.randomUUID());
        AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase = new AddProfessionalPortfolioItemUseCase(
                professionalIdentifier -> Optional.of(professional),
                fileIdentifier -> Optional.of(portfolioStoredFile),
                professionalIdentifier -> List.of(),
                professionalPortfolioItem -> professionalPortfolioItem
        );

        // WHEN / THEN
        assertThatThrownBy(() -> addProfessionalPortfolioItemUseCase.addProfessionalPortfolioItem(
                new AddProfessionalPortfolioItemRequest(
                        professional.professionalIdentifier(),
                        portfolioStoredFile.fileIdentifier(),
                        " ",
                        null,
                        0
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O titulo do item de portfolio e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN portfolio cheio WHEN adicionar item THEN deve rejeitar limite")
    void shouldRejectPortfolioItemWhenProfessionalReachedItemLimit() {
        // GIVEN
        Professional professional = Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
        StoredFile portfolioStoredFile = publicPortfolioStoredFile(UUID.randomUUID());
        InMemoryProfessionalPortfolioPort inMemoryProfessionalPortfolioPort = new InMemoryProfessionalPortfolioPort();
        for (int displayOrder = 0; displayOrder < 10; displayOrder++) {
            inMemoryProfessionalPortfolioPort.saveProfessionalPortfolioItem(
                    ProfessionalPortfolioItem.addProfessionalPortfolioItem(
                            professional.professionalIdentifier(),
                            UUID.randomUUID(),
                            "Portfolio %d".formatted(displayOrder),
                            null,
                            displayOrder
                    )
            );
        }
        AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase = new AddProfessionalPortfolioItemUseCase(
                professionalIdentifier -> Optional.of(professional),
                fileIdentifier -> Optional.of(portfolioStoredFile),
                inMemoryProfessionalPortfolioPort,
                inMemoryProfessionalPortfolioPort
        );

        // WHEN / THEN
        assertThatThrownBy(() -> addProfessionalPortfolioItemUseCase.addProfessionalPortfolioItem(
                new AddProfessionalPortfolioItemRequest(
                        professional.professionalIdentifier(),
                        portfolioStoredFile.fileIdentifier(),
                        "Novo portfolio",
                        null,
                        11
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O portfolio profissional atingiu o limite de itens.");
    }

    @Test
    @DisplayName("GIVEN itens ativos WHEN listar portfolio THEN deve retornar respostas ordenadas")
    void shouldReturnOrderedPortfolioResponsesWhenListingActiveItems() {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        InMemoryProfessionalPortfolioPort inMemoryProfessionalPortfolioPort = new InMemoryProfessionalPortfolioPort();
        inMemoryProfessionalPortfolioPort.saveProfessionalPortfolioItem(
                ProfessionalPortfolioItem.addProfessionalPortfolioItem(
                        professionalIdentifier,
                        UUID.randomUUID(),
                        "Segundo item",
                        null,
                        2
                )
        );
        inMemoryProfessionalPortfolioPort.saveProfessionalPortfolioItem(
                ProfessionalPortfolioItem.addProfessionalPortfolioItem(
                        professionalIdentifier,
                        UUID.randomUUID(),
                        "Primeiro item",
                        null,
                        1
                )
        );
        ListProfessionalPortfolioItemsUseCase listProfessionalPortfolioItemsUseCase =
                new ListProfessionalPortfolioItemsUseCase(inMemoryProfessionalPortfolioPort);

        // WHEN
        List<ProfessionalPortfolioItemResponse> responses =
                listProfessionalPortfolioItemsUseCase.listProfessionalPortfolioItems(professionalIdentifier);

        // THEN
        assertThat(responses).extracting(ProfessionalPortfolioItemResponse::title)
                .containsExactly("Primeiro item", "Segundo item");
    }

    private StoredFile publicPortfolioStoredFile(UUID fileIdentifier) {
        return StoredFile.restoreStoredFile(
                fileIdentifier,
                StoredFilePurpose.PROFESSIONAL_PORTFOLIO,
                StoredFileAccessLevel.PUBLIC,
                "portfolio.jpg",
                "image/jpeg",
                "jpg",
                300_000L,
                "professional-portfolios/%s.jpg".formatted(fileIdentifier)
        );
    }

    private static class InMemoryProfessionalPortfolioPort implements
            ListProfessionalPortfolioItemsPort,
            SaveProfessionalPortfolioItemPort {

        private final List<ProfessionalPortfolioItem> portfolioItems = new ArrayList<>();

        @Override
        public List<ProfessionalPortfolioItem> listActiveProfessionalPortfolioItems(UUID professionalIdentifier) {
            return portfolioItems.stream()
                    .filter(ProfessionalPortfolioItem::active)
                    .filter(portfolioItem -> portfolioItem.professionalIdentifier().equals(professionalIdentifier))
                    .sorted(Comparator.comparingInt(ProfessionalPortfolioItem::displayOrder))
                    .toList();
        }

        @Override
        public ProfessionalPortfolioItem saveProfessionalPortfolioItem(
                ProfessionalPortfolioItem professionalPortfolioItem
        ) {
            portfolioItems.add(professionalPortfolioItem);
            return professionalPortfolioItem;
        }
    }
}
