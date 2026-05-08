package br.com.worklink.application.privacy.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

public record PersonalDataProcessingRule(
        PersonalDataField personalDataField,
        PersonalDataProcessingPurpose personalDataProcessingPurpose,
        PersonalDataRetentionPolicy personalDataRetentionPolicy,
        PrivacyExposureLevel privacyExposureLevel,
        boolean collectionAllowed
) {

    public PersonalDataProcessingRule {
        if (personalDataField == null) {
            throw new ApplicationRuleViolationException("O campo de dado pessoal e obrigatorio.");
        }
        if (personalDataProcessingPurpose == null) {
            throw new ApplicationRuleViolationException("A finalidade do dado pessoal e obrigatoria.");
        }
        if (personalDataRetentionPolicy == null) {
            throw new ApplicationRuleViolationException("A retencao do dado pessoal e obrigatoria.");
        }
        if (privacyExposureLevel == null) {
            throw new ApplicationRuleViolationException("A exposicao do dado pessoal e obrigatoria.");
        }
    }

    public boolean exposesSensitiveDataPublicly() {
        return privacyExposureLevel == PrivacyExposureLevel.PUBLIC
                && (personalDataField == PersonalDataField.PROFESSIONAL_DOCUMENT_NUMBER_HASH
                || personalDataField == PersonalDataField.CUSTOMER_PHONE_NUMBER
                || personalDataField == PersonalDataField.AUTHENTICATION_ONE_TIME_PASSWORD_HASH
                || personalDataField == PersonalDataField.AUTHENTICATION_REFRESH_TOKEN_HASH
                || personalDataField == PersonalDataField.REPORT_EVIDENCE_REFERENCE
                || personalDataField == PersonalDataField.REVIEW_INTERNAL_AUTHOR_IDENTIFIER);
    }
}
