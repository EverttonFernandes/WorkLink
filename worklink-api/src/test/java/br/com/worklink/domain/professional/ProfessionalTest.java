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
                "12345678900",
                "https://worklink.example/maria-eletricista",
                "Instalacoes residenciais recentes.",
                "Instalacoes, manutencao e emergencias eletricas."
        );

        // THEN
        assertThat(completedProfessional.profileCompletenessPercentage()).isEqualTo(100);
        assertThat(completedProfessional.profileClassification()).isEqualTo(ProfessionalProfileClassification.COMPLETE_PROFILE);
        assertThat(completedProfessional.profilePhotoFileIdentifier()).isEqualTo(profilePhotoFileIdentifier);
        assertThat(completedProfessional.documentNumber()).isEqualTo("12345678900");
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
                null
        );

        // THEN
        assertThat(updatedProfessional.profileCompletenessPercentage()).isEqualTo(50);
        assertThat(updatedProfessional.profileClassification()).isEqualTo(ProfessionalProfileClassification.BASIC_PROFILE);
        assertThat(updatedProfessional.documentNumber()).isNull();
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
                false
        ))
                .isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("A classificacao do perfil profissional e obrigatoria.");
    }
}
