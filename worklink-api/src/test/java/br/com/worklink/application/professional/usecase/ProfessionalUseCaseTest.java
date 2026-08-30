package br.com.worklink.application.professional.usecase;

import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;
import br.com.worklink.domain.catalog.ServiceCategory;
import br.com.worklink.domain.catalog.ServiceCity;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalAvailabilityStatus;
import br.com.worklink.domain.professional.ProfessionalProfileClassification;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ProfessionalUseCaseTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("Deve registrar profissional basico quando cidade e categoria existirem")
    void shouldRegisterBasicProfessionalWhenCityAndCategoryExist() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = new RegisterBasicProfessionalUseCase(
                cityIdentifier -> Optional.of(ServiceCity.restoreServiceCity(cityIdentifier, "Canoas", "RS", "canoas-rs")),
                categoryIdentifier -> Optional.of(ServiceCategory.restoreServiceCategory(categoryIdentifier, "Eletricista", "eletricista")),
                inMemoryProfessionalPort
        );

        // WHEN
        ProfessionalResponse professionalResponse = registerBasicProfessionalUseCase.registerBasicProfessional(validProfessionalRequest());

        // THEN
        assertThat(professionalResponse.profileClassification()).isEqualTo(ProfessionalProfileClassification.BASIC_PROFILE.name());
        assertThat(professionalResponse.phoneNumberVerified()).isFalse();
        assertThat(professionalResponse.qualityGuarantee()).isFalse();
        assertThat(inMemoryProfessionalPort.listProfessionals(ProfessionalSearchCriteria.withoutFilters()))
                .extracting(Professional::professionalIdentifier)
                .containsExactly(professionalResponse.professionalIdentifier());
    }

    @Test
    @DisplayName("Deve rejeitar profissional basico quando cidade nao existir")
    void shouldRejectBasicProfessionalWhenCityDoesNotExist() {
        // GIVEN
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = new RegisterBasicProfessionalUseCase(
                missingCityPort(),
                existingCategoryPort(),
                professional -> professional
        );

        // WHEN / THEN
        assertThatThrownBy(() -> registerBasicProfessionalUseCase.registerBasicProfessional(validProfessionalRequest()))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A cidade informada para o profissional nao foi encontrada.");
    }

    @Test
    @DisplayName("Deve rejeitar profissional basico quando categoria nao existir")
    void shouldRejectBasicProfessionalWhenCategoryDoesNotExist() {
        // GIVEN
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = new RegisterBasicProfessionalUseCase(
                existingCityPort(),
                missingCategoryPort(),
                professional -> professional
        );

        // WHEN / THEN
        assertThatThrownBy(() -> registerBasicProfessionalUseCase.registerBasicProfessional(validProfessionalRequest()))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A categoria informada para o profissional nao foi encontrada.");
    }

    @Test
    @DisplayName("Deve traduzir erro de dominio quando profissional basico estiver sem campo minimo")
    void shouldTranslateDomainErrorWhenBasicProfessionalHasMissingMinimumField() {
        // GIVEN
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = new RegisterBasicProfessionalUseCase(
                existingCityPort(),
                existingCategoryPort(),
                professional -> professional
        );
        RegisterBasicProfessionalRequest request = new RegisterBasicProfessionalRequest(
                "",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );

        // WHEN / THEN
        assertThatThrownBy(() -> registerBasicProfessionalUseCase.registerBasicProfessional(request))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O nome do profissional e obrigatorio.");
    }

    @Test
    @DisplayName("Deve listar profissionais usando criterio de busca informado")
    void shouldListProfessionalsUsingProvidedSearchCriteria() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        Professional professional = inMemoryProfessionalPort.saveProfessional(Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ));
        ListProfessionalsUseCase listProfessionalsUseCase = new ListProfessionalsUseCase(inMemoryProfessionalPort);
        ProfessionalSearchCriteria professionalSearchCriteria = new ProfessionalSearchCriteria(
                Optional.of(CATEGORY_IDENTIFIER),
                Set.of(CITY_IDENTIFIER),
                Optional.of("residencial")
        );

        // WHEN
        List<ProfessionalSummaryResponse> professionals =
                listProfessionalsUseCase.listProfessionals(professionalSearchCriteria);

        // THEN
        assertThat(professionals)
                .extracting(ProfessionalSummaryResponse::professionalIdentifier)
                .containsExactly(professional.professionalIdentifier());
        assertThat(professionals.getFirst().professionalName()).isEqualTo("Maria Eletricista");
    }

    @Test
    @DisplayName("GIVEN profissional ativo WHEN carregar detalhe THEN deve retornar dados sem WhatsApp e documento")
    void shouldLoadProfessionalDetailWithoutWhatsappAndDocumentWhenProfessionalIsActive() {
        // GIVEN
        Professional professional = completedProfessional(false);
        LoadProfessionalDetailUseCase loadProfessionalDetailUseCase = new LoadProfessionalDetailUseCase(
                professionalIdentifier -> Optional.of(professional)
        );

        // WHEN
        ProfessionalDetailResponse professionalDetailResponse =
                loadProfessionalDetailUseCase.loadProfessionalDetail(professional.professionalIdentifier());

        // THEN
        assertThat(professionalDetailResponse.professionalIdentifier()).isEqualTo(professional.professionalIdentifier());
        assertThat(professionalDetailResponse.professionalName()).isEqualTo(professional.professionalName());
        assertThat(professionalDetailResponse.usefulLink()).isEqualTo(professional.usefulLink());
        assertThat(professionalDetailResponse.serviceDescription()).isEqualTo(professional.serviceDescription());
    }

    @Test
    @DisplayName("GIVEN profissional inexistente WHEN carregar detalhe THEN deve retornar recurso nao encontrado")
    void shouldRejectProfessionalDetailWhenProfessionalDoesNotExist() {
        // GIVEN
        LoadProfessionalDetailUseCase loadProfessionalDetailUseCase = new LoadProfessionalDetailUseCase(
                professionalIdentifier -> Optional.empty()
        );

        // WHEN / THEN
        assertThatThrownBy(() -> loadProfessionalDetailUseCase.loadProfessionalDetail(UUID.randomUUID()))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Profissional nao encontrado.");
    }

    @Test
    @DisplayName("GIVEN profissional bloqueado WHEN carregar detalhe THEN deve ocultar recurso")
    void shouldRejectProfessionalDetailWhenProfessionalIsBlocked() {
        // GIVEN
        Professional blockedProfessional = completedProfessional(true);
        LoadProfessionalDetailUseCase loadProfessionalDetailUseCase = new LoadProfessionalDetailUseCase(
                professionalIdentifier -> Optional.of(blockedProfessional)
        );

        // WHEN / THEN
        assertThatThrownBy(() -> loadProfessionalDetailUseCase.loadProfessionalDetail(
                blockedProfessional.professionalIdentifier()
        ))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessage("Profissional nao encontrado.");
    }

    @Test
    @DisplayName("Deve completar perfil profissional existente aumentando completude")
    void shouldCompleteExistingProfessionalProfileIncreasingCompleteness() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        Professional professional = inMemoryProfessionalPort.saveProfessional(Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ));
        CompleteProfessionalProfileUseCase completeProfessionalProfileUseCase = new CompleteProfessionalProfileUseCase(
                inMemoryProfessionalPort,
                inMemoryProfessionalPort,
                (rawSensitiveValue, purpose) -> "protected-%s-%s".formatted(purpose.name(), rawSensitiveValue)
        );

        // WHEN
        ProfessionalResponse professionalResponse = completeProfessionalProfileUseCase.completeProfessionalProfile(
                new CompleteProfessionalProfileRequest(
                        professional.professionalIdentifier(),
                        UUID.randomUUID(),
                        "12345678900",
                        "https://worklink.example/maria-eletricista",
                        "Portifolio residencial.",
                        "Instalacoes e manutencoes eletricas.",
                        ProfessionalAvailabilityStatus.AVAILABLE_THIS_WEEK.name()
                )
        );

        // THEN
        assertThat(professionalResponse.profileCompletenessPercentage()).isEqualTo(100);
        assertThat(professionalResponse.profileClassification()).isEqualTo(ProfessionalProfileClassification.COMPLETE_PROFILE.name());
        assertThat(professionalResponse.documentNumberHash())
                .isEqualTo("protected-%s-12345678900".formatted(ProtectedSensitiveValuePurpose.DOCUMENT_NUMBER.name()));
        assertThat(professionalResponse.availabilityBadgeLabel()).isEqualTo("Disponível esta semana");
        assertThat(professionalResponse.phoneNumberVerified()).isFalse();
        assertThat(professionalResponse.qualityGuarantee()).isFalse();
    }

    @Test
    @DisplayName("GIVEN profissional existente WHEN solicitar verificacao THEN deve retornar prazo para confirmacao")
    void shouldReturnExpirationTimeWhenRequestingProfessionalPhoneVerification() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        Professional professional = inMemoryProfessionalPort.saveProfessional(Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ));
        Instant currentInstant = Instant.parse("2026-05-13T18:00:00Z");
        RequestProfessionalPhoneVerificationUseCase requestPhoneVerificationUseCase =
                new RequestProfessionalPhoneVerificationUseCase(
                        inMemoryProfessionalPort,
                        () -> currentInstant,
                        Duration.ofMinutes(5)
                );

        // WHEN
        RequestProfessionalPhoneVerificationResponse phoneVerificationResponse =
                requestPhoneVerificationUseCase.requestProfessionalPhoneVerification(
                        new RequestProfessionalPhoneVerificationRequest(professional.professionalIdentifier())
                );

        // THEN
        assertThat(phoneVerificationResponse.professionalIdentifier()).isEqualTo(professional.professionalIdentifier());
        assertThat(phoneVerificationResponse.expiresAt()).isEqualTo(Instant.parse("2026-05-13T18:05:00Z"));
        assertThat(phoneVerificationResponse.message())
                .isEqualTo("Codigo de verificacao enviado para o WhatsApp do profissional.");
    }

    @Test
    @DisplayName("GIVEN codigo correto WHEN confirmar telefone THEN deve persistir profissional verificado")
    void shouldPersistVerifiedProfessionalWhenConfirmingCorrectPhoneVerificationCode() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        Professional professional = inMemoryProfessionalPort.saveProfessional(Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ));
        ConfirmProfessionalPhoneVerificationUseCase confirmPhoneVerificationUseCase =
                new ConfirmProfessionalPhoneVerificationUseCase(
                        inMemoryProfessionalPort,
                        inMemoryProfessionalPort,
                        "123456"
                );

        // WHEN
        ProfessionalResponse professionalResponse = confirmPhoneVerificationUseCase.confirmProfessionalPhoneVerification(
                new ConfirmProfessionalPhoneVerificationRequest(professional.professionalIdentifier(), " 123456 ")
        );

        // THEN
        assertThat(professionalResponse.phoneNumberVerified()).isTrue();
        assertThat(inMemoryProfessionalPort.loadProfessionalByIdentifier(professional.professionalIdentifier()))
                .get()
                .extracting(Professional::phoneNumberVerified)
                .isEqualTo(true);
    }

    @Test
    @DisplayName("GIVEN codigo incorreto WHEN confirmar telefone THEN deve rejeitar verificacao")
    void shouldRejectPhoneVerificationWhenConfirmationCodeIsInvalid() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        Professional professional = inMemoryProfessionalPort.saveProfessional(Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ));
        ConfirmProfessionalPhoneVerificationUseCase confirmPhoneVerificationUseCase =
                new ConfirmProfessionalPhoneVerificationUseCase(
                        inMemoryProfessionalPort,
                        inMemoryProfessionalPort,
                        "123456"
                );

        // WHEN / THEN
        assertThatThrownBy(() -> confirmPhoneVerificationUseCase.confirmProfessionalPhoneVerification(
                new ConfirmProfessionalPhoneVerificationRequest(professional.professionalIdentifier(), "000000")
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("Nao foi possivel confirmar o telefone do profissional.");
    }

    @Test
    @DisplayName("Deve rejeitar completude de perfil quando profissional nao existir")
    void shouldRejectProfileCompletionWhenProfessionalDoesNotExist() {
        // GIVEN
        CompleteProfessionalProfileUseCase completeProfessionalProfileUseCase = new CompleteProfessionalProfileUseCase(
                professionalIdentifier -> Optional.empty(),
                professional -> professional,
                (rawSensitiveValue, purpose) -> "protected-value"
        );

        // WHEN / THEN
        assertThatThrownBy(() -> completeProfessionalProfileUseCase.completeProfessionalProfile(
                new CompleteProfessionalProfileRequest(
                        UUID.randomUUID(),
                        null,
                        null,
                        null,
                        null,
                        null,
                        null
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O profissional informado nao foi encontrado.");
    }

    @Test
    @DisplayName("Deve rejeitar disponibilidade fora da lista permitida")
    void shouldRejectAvailabilityOutsideAllowedList() {
        // GIVEN
        InMemoryProfessionalPort inMemoryProfessionalPort = new InMemoryProfessionalPort();
        Professional professional = inMemoryProfessionalPort.saveProfessional(Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ));
        CompleteProfessionalProfileUseCase completeProfessionalProfileUseCase = new CompleteProfessionalProfileUseCase(
                inMemoryProfessionalPort,
                inMemoryProfessionalPort,
                (rawSensitiveValue, purpose) -> "protected-value"
        );

        // WHEN / THEN
        assertThatThrownBy(() -> completeProfessionalProfileUseCase.completeProfessionalProfile(
                new CompleteProfessionalProfileRequest(
                        professional.professionalIdentifier(),
                        null,
                        null,
                        null,
                        null,
                        null,
                        "DISPONIVEL_AGORA"
                )
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A disponibilidade informada nao e permitida.");
    }

    private RegisterBasicProfessionalRequest validProfessionalRequest() {
        return new RegisterBasicProfessionalRequest(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
    }

    private Professional completedProfessional(boolean blocked) {
        return Professional.restoreProfessional(
                UUID.randomUUID(),
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial.",
                UUID.randomUUID(),
                "protected-document",
                "https://worklink.example/maria-eletricista",
                "Instalacoes residenciais recentes.",
                "Instalacoes e manutencoes eletricas.",
                100,
                ProfessionalProfileClassification.COMPLETE_PROFILE,
                ProfessionalAvailabilityStatus.AVAILABLE_TODAY,
                true,
                false,
                blocked
        );
    }

    private LoadServiceCityByIdentifierPort existingCityPort() {
        return cityIdentifier -> Optional.of(ServiceCity.restoreServiceCity(cityIdentifier, "Canoas", "RS", "canoas-rs"));
    }

    private LoadServiceCityByIdentifierPort missingCityPort() {
        return cityIdentifier -> Optional.empty();
    }

    private LoadServiceCategoryByIdentifierPort existingCategoryPort() {
        return categoryIdentifier -> Optional.of(ServiceCategory.restoreServiceCategory(categoryIdentifier, "Eletricista", "eletricista"));
    }

    private LoadServiceCategoryByIdentifierPort missingCategoryPort() {
        return categoryIdentifier -> Optional.empty();
    }

    private static class InMemoryProfessionalPort implements
            SaveProfessionalPort,
            ListProfessionalsPort,
            LoadProfessionalByIdentifierPort,
            UpdateProfessionalPort {

        private final List<Professional> professionals = new ArrayList<>();

        @Override
        public Professional saveProfessional(Professional professional) {
            professionals.add(professional);
            return professional;
        }

        @Override
        public Optional<Professional> loadProfessionalByIdentifier(UUID professionalIdentifier) {
            return professionals.stream()
                    .filter(professional -> professional.professionalIdentifier().equals(professionalIdentifier))
                    .findFirst();
        }

        @Override
        public Professional updateProfessional(Professional professional) {
            professionals.removeIf(existingProfessional ->
                    existingProfessional.professionalIdentifier().equals(professional.professionalIdentifier()));
            professionals.add(professional);
            return professional;
        }

        @Override
        public List<Professional> listProfessionals(ProfessionalSearchCriteria professionalSearchCriteria) {
            return professionals.stream()
                    .filter(professional -> professionalSearchCriteria.categoryIdentifier()
                            .map(professional.categoryIdentifier()::equals)
                            .orElse(true))
                    .filter(professional -> professionalSearchCriteria.cityIdentifiers().isEmpty()
                            || professionalSearchCriteria.cityIdentifiers().contains(professional.cityIdentifier()))
                    .filter(professional -> professionalSearchCriteria.keyword()
                            .map(keyword -> professional.professionalName().toLowerCase().contains(keyword.toLowerCase())
                                    || professional.shortDescription().toLowerCase().contains(keyword.toLowerCase()))
                            .orElse(true))
                    .toList();
        }
    }
}
