package br.com.worklink.application.privacy.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class WorkLinkPrivacyInventoryTest {

    @Test
    @DisplayName("GIVEN campo permitido WHEN consultar inventario THEN deve retornar finalidade retencao e exposicao")
    void shouldReturnPurposeRetentionAndExposureForAllowedPersonalData() {
        // GIVEN
        WorkLinkPrivacyInventory workLinkPrivacyInventory = new WorkLinkPrivacyInventory();

        // WHEN
        PersonalDataProcessingRule personalDataProcessingRule = workLinkPrivacyInventory.requireAllowedPersonalDataField(
                PersonalDataField.CUSTOMER_PHONE_NUMBER
        );

        // THEN
        assertThat(personalDataProcessingRule.personalDataProcessingPurpose())
                .isEqualTo(PersonalDataProcessingPurpose.CUSTOMER_AUTHENTICATION);
        assertThat(personalDataProcessingRule.personalDataRetentionPolicy())
                .isEqualTo(PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION);
        assertThat(personalDataProcessingRule.privacyExposureLevel()).isEqualTo(PrivacyExposureLevel.OWNER_ONLY);
    }

    @Test
    @DisplayName("GIVEN documento profissional WHEN consultar exposicao THEN nao deve permitir exposicao publica")
    void shouldKeepProfessionalDocumentHashRestricted() {
        // GIVEN
        WorkLinkPrivacyInventory workLinkPrivacyInventory = new WorkLinkPrivacyInventory();

        // WHEN
        PersonalDataProcessingRule personalDataProcessingRule = workLinkPrivacyInventory.requireAllowedPersonalDataField(
                PersonalDataField.PROFESSIONAL_DOCUMENT_NUMBER_HASH
        );

        // THEN
        assertThat(personalDataProcessingRule.privacyExposureLevel()).isEqualTo(PrivacyExposureLevel.INTERNAL_RESTRICTED);
        assertThat(personalDataProcessingRule.exposesSensitiveDataPublicly()).isFalse();
    }

    @Test
    @DisplayName("GIVEN evidencia de denuncia WHEN consultar inventario THEN deve classificar como confidencial")
    void shouldClassifyReportEvidenceAsConfidential() {
        // GIVEN
        WorkLinkPrivacyInventory workLinkPrivacyInventory = new WorkLinkPrivacyInventory();

        // WHEN
        PersonalDataProcessingRule personalDataProcessingRule = workLinkPrivacyInventory.requireAllowedPersonalDataField(
                PersonalDataField.REPORT_EVIDENCE_REFERENCE
        );

        // THEN
        assertThat(personalDataProcessingRule.personalDataProcessingPurpose())
                .isEqualTo(PersonalDataProcessingPurpose.MODERATION_AND_SAFETY);
        assertThat(personalDataProcessingRule.privacyExposureLevel()).isEqualTo(PrivacyExposureLevel.CONFIDENTIAL);
    }

    @Test
    @DisplayName("GIVEN dados financeiros WHEN consultar inventario THEN deve rejeitar coleta na V1")
    void shouldRejectFinancialDataCollectionInVersionOne() {
        // GIVEN
        WorkLinkPrivacyInventory workLinkPrivacyInventory = new WorkLinkPrivacyInventory();

        // WHEN / THEN
        assertThat(workLinkPrivacyInventory.canCollect(PersonalDataField.FINANCIAL_INFORMATION)).isFalse();
        assertThatThrownBy(() -> workLinkPrivacyInventory.requireAllowedPersonalDataField(PersonalDataField.FINANCIAL_INFORMATION))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O dado pessoal informado nao faz parte do escopo da V1.");
    }

    @Test
    @DisplayName("GIVEN dados fora do escopo WHEN listar permitidos THEN nao deve retornar dados proibidos")
    void shouldNotExposeOutOfScopeDataAsAllowed() {
        // GIVEN
        WorkLinkPrivacyInventory workLinkPrivacyInventory = new WorkLinkPrivacyInventory();

        // WHEN / THEN
        assertThat(workLinkPrivacyInventory.listAllowedPersonalDataProcessingRules())
                .extracting(PersonalDataProcessingRule::personalDataField)
                .doesNotContain(
                        PersonalDataField.BANK_ACCOUNT,
                        PersonalDataField.CREDIT_CARD,
                        PersonalDataField.PHOTO_DOCUMENT,
                        PersonalDataField.CONTINUOUS_REAL_TIME_LOCATION,
                        PersonalDataField.FINANCIAL_INFORMATION
                );
    }

    @Test
    @DisplayName("GIVEN regra com campo ausente WHEN construir politica THEN deve rejeitar")
    void shouldRejectProcessingRuleWithoutPersonalDataField() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> new PersonalDataProcessingRule(
                null,
                PersonalDataProcessingPurpose.CUSTOMER_AUTHENTICATION,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.OWNER_ONLY,
                true
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("O campo de dado pessoal e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN regra com finalidade ausente WHEN construir politica THEN deve rejeitar")
    void shouldRejectProcessingRuleWithoutPurpose() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> new PersonalDataProcessingRule(
                PersonalDataField.CUSTOMER_PHONE_NUMBER,
                null,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.OWNER_ONLY,
                true
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A finalidade do dado pessoal e obrigatoria.");
    }

    @Test
    @DisplayName("GIVEN regra com retencao ausente WHEN construir politica THEN deve rejeitar")
    void shouldRejectProcessingRuleWithoutRetention() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> new PersonalDataProcessingRule(
                PersonalDataField.CUSTOMER_PHONE_NUMBER,
                PersonalDataProcessingPurpose.CUSTOMER_AUTHENTICATION,
                null,
                PrivacyExposureLevel.OWNER_ONLY,
                true
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A retencao do dado pessoal e obrigatoria.");
    }

    @Test
    @DisplayName("GIVEN regra com exposicao ausente WHEN construir politica THEN deve rejeitar")
    void shouldRejectProcessingRuleWithoutExposure() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> new PersonalDataProcessingRule(
                PersonalDataField.CUSTOMER_PHONE_NUMBER,
                PersonalDataProcessingPurpose.CUSTOMER_AUTHENTICATION,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                null,
                true
        ))
                .isInstanceOf(ApplicationRuleViolationException.class)
                .hasMessage("A exposicao do dado pessoal e obrigatoria.");
    }

    @Test
    @DisplayName("GIVEN dado sensivel publico WHEN verificar regra THEN deve identificar vazamento")
    void shouldDetectSensitiveDataExposedPublicly() {
        // GIVEN
        PersonalDataProcessingRule personalDataProcessingRule = new PersonalDataProcessingRule(
                PersonalDataField.CUSTOMER_PHONE_NUMBER,
                PersonalDataProcessingPurpose.CUSTOMER_AUTHENTICATION,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.PUBLIC,
                true
        );

        // WHEN / THEN
        assertThat(personalDataProcessingRule.exposesSensitiveDataPublicly()).isTrue();
    }
}
