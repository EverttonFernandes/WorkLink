package br.com.worklink.domain.professional;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ProfessionalTest {

    private static final UUID CITY_IDENTIFIER = UUID.randomUUID();
    private static final UUID CATEGORY_IDENTIFIER = UUID.randomUUID();

    @Test
    @DisplayName("Deve registrar profissional como perfil basico sem garantia de qualidade quando campos minimos forem validos")
    void shouldRegisterProfessionalAsBasicProfileWithoutQualityGuaranteeWhenMinimumFieldsAreValid() {
        // GIVEN
        String professionalName = "Maria Eletricista";

        // WHEN
        Professional professional = Professional.registerBasicProfessional(
                professionalName,
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial em instalacoes eletricas."
        );

        // THEN
        assertThat(professional.professionalIdentifier()).isNotNull();
        assertThat(professional.professionalName()).isEqualTo(professionalName);
        assertThat(professional.whatsappNumber()).isEqualTo("51999999999");
        assertThat(professional.cityIdentifier()).isEqualTo(CITY_IDENTIFIER);
        assertThat(professional.categoryIdentifier()).isEqualTo(CATEGORY_IDENTIFIER);
        assertThat(professional.shortDescription()).isEqualTo("Atendimento residencial em instalacoes eletricas.");
        assertThat(professional.profileCompletenessPercentage()).isEqualTo(50);
        assertThat(professional.profileClassification()).isEqualTo(ProfessionalProfileClassification.BASIC_PROFILE);
        assertThat(professional.qualityGuarantee()).isFalse();
    }

    @Test
    @DisplayName("Deve aumentar completude sem prometer qualidade quando profissional completar dados progressivos")
    void shouldIncreaseCompletenessWithoutPromisingQualityWhenProfessionalCompletesProgressiveData() {
        // GIVEN
        Professional professional = Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );
        UUID profilePhotoFileIdentifier = UUID.randomUUID();

        // WHEN
        Professional completedProfessional = professional.completeProgressiveProfile(
                profilePhotoFileIdentifier,
                "document-hash",
                "https://worklink.example/maria-eletricista",
                "Instalacoes residenciais recentes.",
                "Instalacoes, manutencao e emergencias eletricas.",
                ProfessionalAvailabilityStatus.AVAILABLE_TODAY
        );

        // THEN
        assertThat(completedProfessional.profileCompletenessPercentage()).isEqualTo(100);
        assertThat(completedProfessional.profileClassification()).isEqualTo(ProfessionalProfileClassification.COMPLETE_PROFILE);
        assertThat(completedProfessional.profilePhotoFileIdentifier()).isEqualTo(profilePhotoFileIdentifier);
        assertThat(completedProfessional.documentNumberHash()).isEqualTo("document-hash");
        assertThat(completedProfessional.availabilityStatus()).isEqualTo(ProfessionalAvailabilityStatus.AVAILABLE_TODAY);
        assertThat(completedProfessional.qualityGuarantee()).isFalse();
    }

    @Test
    @DisplayName("Deve manter completude basica quando profissional editar perfil sem campos opcionais")
    void shouldKeepBasicCompletenessWhenProfessionalEditsProfileWithoutOptionalFields() {
        // GIVEN
        Professional professional = Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );

        // WHEN
        Professional updatedProfessional = professional.completeProgressiveProfile(
                null,
                " ",
                null,
                "",
                null,
                ProfessionalAvailabilityStatus.ACCEPTING_NEW_CLIENTS
        );

        // THEN
        assertThat(updatedProfessional.profileCompletenessPercentage()).isEqualTo(50);
        assertThat(updatedProfessional.profileClassification()).isEqualTo(ProfessionalProfileClassification.BASIC_PROFILE);
        assertThat(updatedProfessional.documentNumberHash()).isNull();
    }

    @Test
    @DisplayName("Deve rejeitar profissional quando nome minimo estiver ausente")
    void shouldRejectProfessionalWhenMinimumNameIsMissing() {
        // GIVEN
        String professionalName = " ";

        // WHEN / THEN
        assertThatThrownBy(() -> Professional.registerBasicProfessional(
                professionalName,
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O nome do profissional e obrigatorio.");
    }

    @Test
    @DisplayName("Deve rejeitar profissional quando WhatsApp minimo estiver ausente")
    void shouldRejectProfessionalWhenMinimumWhatsappIsMissing() {
        // GIVEN
        String whatsappNumber = "";

        // WHEN / THEN
        assertThatThrownBy(() -> Professional.registerBasicProfessional(
                "Maria Eletricista",
                whatsappNumber,
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O WhatsApp do profissional e obrigatorio.");
    }

    @Test
    @DisplayName("Deve rejeitar profissional quando cidade minima estiver ausente")
    void shouldRejectProfessionalWhenMinimumCityIsMissing() {
        // GIVEN
        UUID cityIdentifier = null;

        // WHEN / THEN
        assertThatThrownBy(() -> Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                cityIdentifier,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A cidade do profissional e obrigatoria.");
    }

    @Test
    @DisplayName("Deve rejeitar profissional quando categoria minima estiver ausente")
    void shouldRejectProfessionalWhenMinimumCategoryIsMissing() {
        // GIVEN
        UUID categoryIdentifier = null;

        // WHEN / THEN
        assertThatThrownBy(() -> Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                categoryIdentifier,
                "Atendimento residencial."
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A categoria do profissional e obrigatoria.");
    }

    @Test
    @DisplayName("Deve rejeitar profissional quando descricao curta minima estiver ausente")
    void shouldRejectProfessionalWhenMinimumShortDescriptionIsMissing() {
        // GIVEN
        String shortDescription = null;

        // WHEN / THEN
        assertThatThrownBy(() -> Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                shortDescription
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A descricao curta do profissional e obrigatoria.");
    }

    @Test
    @DisplayName("Deve restaurar profissional persistido quando campos estiverem validos")
    void shouldRestorePersistedProfessionalWhenFieldsAreValid() {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();

        // WHEN
        Professional professional = Professional.restoreProfessional(
                professionalIdentifier,
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial.",
                null,
                null,
                null,
                null,
                null,
                50,
                ProfessionalProfileClassification.BASIC_PROFILE,
                ProfessionalAvailabilityStatus.ACCEPTING_NEW_CLIENTS,
                false
        );

        // THEN
        assertThat(professional.professionalIdentifier()).isEqualTo(professionalIdentifier);
        assertThat(professional.profileClassification()).isEqualTo(ProfessionalProfileClassification.BASIC_PROFILE);
        assertThat(professional.qualityGuarantee()).isFalse();
    }

    @Test
    @DisplayName("Deve rejeitar restauracao de profissional quando classificacao estiver ausente")
    void shouldRejectProfessionalRestorationWhenClassificationIsMissing() {
        // GIVEN
        ProfessionalProfileClassification profileClassification = null;

        // WHEN / THEN
        assertThatThrownBy(() -> Professional.restoreProfessional(
                UUID.randomUUID(),
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial.",
                null,
                null,
                null,
                null,
                null,
                50,
                profileClassification,
                ProfessionalAvailabilityStatus.ACCEPTING_NEW_CLIENTS,
                false
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A classificacao do perfil profissional e obrigatoria.");
    }

    @Test
    @DisplayName("Deve rejeitar disponibilidade fora dos valores permitidos")
    void shouldRejectAvailabilityOutsideAllowedValues() {
        // GIVEN
        String availabilityStatusName = "DISPONIVEL_AGORA";

        // WHEN / THEN
        assertThatThrownBy(() -> ProfessionalAvailabilityStatus.fromRequiredName(availabilityStatusName))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A disponibilidade informada nao e permitida.");
    }

    @Test
    @DisplayName("Deve reduzir destaque quando profissional estiver indisponivel temporariamente")
    void shouldReduceHighlightWhenProfessionalIsTemporarilyUnavailable() {
        // GIVEN
        Professional professional = Professional.registerBasicProfessional(
                "Maria Eletricista",
                "51999999999",
                CITY_IDENTIFIER,
                CATEGORY_IDENTIFIER,
                "Atendimento residencial."
        );

        // WHEN
        Professional unavailableProfessional = professional.updateAvailabilityStatus(
                ProfessionalAvailabilityStatus.TEMPORARILY_UNAVAILABLE
        );

        // THEN
        assertThat(unavailableProfessional.availabilityStatus().badgeLabel()).isEqualTo("Indisponível temporariamente");
        assertThat(unavailableProfessional.availabilityStatus().reducesListingHighlight()).isTrue();
    }
}
