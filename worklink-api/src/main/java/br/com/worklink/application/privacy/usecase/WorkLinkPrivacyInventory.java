package br.com.worklink.application.privacy.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

public final class WorkLinkPrivacyInventory {

    private final Map<PersonalDataField, PersonalDataProcessingRule> personalDataProcessingRules;

    public WorkLinkPrivacyInventory() {
        this.personalDataProcessingRules = buildPersonalDataProcessingRules();
    }

    public PersonalDataProcessingRule requireAllowedPersonalDataField(PersonalDataField personalDataField) {
        PersonalDataProcessingRule personalDataProcessingRule = personalDataProcessingRules.get(personalDataField);
        if (personalDataProcessingRule == null || !personalDataProcessingRule.collectionAllowed()) {
            throw new ApplicationRuleViolationException("O dado pessoal informado nao faz parte do escopo da V1.");
        }
        if (personalDataProcessingRule.exposesSensitiveDataPublicly()) {
            throw new ApplicationRuleViolationException("Dado sensivel nao pode ter exposicao publica.");
        }
        return personalDataProcessingRule;
    }

    public boolean canCollect(PersonalDataField personalDataField) {
        PersonalDataProcessingRule personalDataProcessingRule = personalDataProcessingRules.get(personalDataField);
        return personalDataProcessingRule != null && personalDataProcessingRule.collectionAllowed();
    }

    public List<PersonalDataProcessingRule> listAllowedPersonalDataProcessingRules() {
        return personalDataProcessingRules.values()
                .stream()
                .filter(PersonalDataProcessingRule::collectionAllowed)
                .toList();
    }

    private static Map<PersonalDataField, PersonalDataProcessingRule> buildPersonalDataProcessingRules() {
        EnumMap<PersonalDataField, PersonalDataProcessingRule> rules = new EnumMap<>(PersonalDataField.class);
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_NAME,
                PersonalDataProcessingPurpose.PUBLIC_PROFESSIONAL_DISCOVERY,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.PUBLIC
        );
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_WHATSAPP_NUMBER,
                PersonalDataProcessingPurpose.PUBLIC_PROFESSIONAL_DISCOVERY,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.PUBLIC
        );
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_CITY,
                PersonalDataProcessingPurpose.CITY_BASED_SEARCH,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.PUBLIC
        );
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_CATEGORY,
                PersonalDataProcessingPurpose.PUBLIC_PROFESSIONAL_DISCOVERY,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.PUBLIC
        );
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_SHORT_DESCRIPTION,
                PersonalDataProcessingPurpose.PUBLIC_PROFESSIONAL_DISCOVERY,
                PersonalDataRetentionPolicy.UNTIL_PROFILE_REMOVAL,
                PrivacyExposureLevel.PUBLIC
        );
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_PROFILE_PHOTO_REFERENCE,
                PersonalDataProcessingPurpose.PUBLIC_PROFESSIONAL_DISCOVERY,
                PersonalDataRetentionPolicy.UNTIL_PROFILE_REMOVAL,
                PrivacyExposureLevel.PUBLIC
        );
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_DOCUMENT_NUMBER_HASH,
                PersonalDataProcessingPurpose.PROFESSIONAL_PROFILE_COMPLETENESS,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.INTERNAL_RESTRICTED
        );
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_PORTFOLIO_DESCRIPTION,
                PersonalDataProcessingPurpose.PUBLIC_PROFESSIONAL_DISCOVERY,
                PersonalDataRetentionPolicy.UNTIL_PROFILE_REMOVAL,
                PrivacyExposureLevel.PUBLIC
        );
        allow(
                rules,
                PersonalDataField.PROFESSIONAL_SERVICE_DESCRIPTION,
                PersonalDataProcessingPurpose.PUBLIC_PROFESSIONAL_DISCOVERY,
                PersonalDataRetentionPolicy.UNTIL_PROFILE_REMOVAL,
                PrivacyExposureLevel.PUBLIC
        );
        allow(
                rules,
                PersonalDataField.CUSTOMER_PHONE_NUMBER,
                PersonalDataProcessingPurpose.CUSTOMER_AUTHENTICATION,
                PersonalDataRetentionPolicy.UNTIL_ACCOUNT_DELETION,
                PrivacyExposureLevel.OWNER_ONLY
        );
        allow(
                rules,
                PersonalDataField.AUTHENTICATION_ONE_TIME_PASSWORD_HASH,
                PersonalDataProcessingPurpose.CUSTOMER_AUTHENTICATION,
                PersonalDataRetentionPolicy.SHORT_OPERATIONAL_WINDOW,
                PrivacyExposureLevel.NOT_EXPOSED
        );
        allow(
                rules,
                PersonalDataField.AUTHENTICATION_REFRESH_TOKEN_HASH,
                PersonalDataProcessingPurpose.CUSTOMER_AUTHENTICATION,
                PersonalDataRetentionPolicy.UNTIL_SESSION_EXPIRATION,
                PrivacyExposureLevel.NOT_EXPOSED
        );
        allow(
                rules,
                PersonalDataField.APPROXIMATE_LOCATION,
                PersonalDataProcessingPurpose.CITY_BASED_SEARCH,
                PersonalDataRetentionPolicy.SHORT_OPERATIONAL_WINDOW,
                PrivacyExposureLevel.NOT_EXPOSED
        );
        allow(
                rules,
                PersonalDataField.REPORT_EVIDENCE_REFERENCE,
                PersonalDataProcessingPurpose.MODERATION_AND_SAFETY,
                PersonalDataRetentionPolicy.AUDIT_RETENTION_WINDOW,
                PrivacyExposureLevel.CONFIDENTIAL
        );
        allow(
                rules,
                PersonalDataField.REVIEW_INTERNAL_AUTHOR_IDENTIFIER,
                PersonalDataProcessingPurpose.AUDITABILITY_AND_ACCOUNTABILITY,
                PersonalDataRetentionPolicy.AUDIT_RETENTION_WINDOW,
                PrivacyExposureLevel.INTERNAL_RESTRICTED
        );
        reject(rules, PersonalDataField.BANK_ACCOUNT);
        reject(rules, PersonalDataField.CREDIT_CARD);
        reject(rules, PersonalDataField.PHOTO_DOCUMENT);
        reject(rules, PersonalDataField.CONTINUOUS_REAL_TIME_LOCATION);
        reject(rules, PersonalDataField.FINANCIAL_INFORMATION);
        return Map.copyOf(rules);
    }

    private static void allow(
            Map<PersonalDataField, PersonalDataProcessingRule> rules,
            PersonalDataField personalDataField,
            PersonalDataProcessingPurpose personalDataProcessingPurpose,
            PersonalDataRetentionPolicy personalDataRetentionPolicy,
            PrivacyExposureLevel privacyExposureLevel
    ) {
        rules.put(
                personalDataField,
                new PersonalDataProcessingRule(
                        personalDataField,
                        personalDataProcessingPurpose,
                        personalDataRetentionPolicy,
                        privacyExposureLevel,
                        true
                )
        );
    }

    private static void reject(Map<PersonalDataField, PersonalDataProcessingRule> rules, PersonalDataField personalDataField) {
        rules.put(
                personalDataField,
                new PersonalDataProcessingRule(
                        personalDataField,
                        PersonalDataProcessingPurpose.NOT_ALLOWED_IN_V1,
                        PersonalDataRetentionPolicy.NOT_COLLECTED,
                        PrivacyExposureLevel.NOT_EXPOSED,
                        false
                )
        );
    }
}
