package br.com.worklink.infrastructure.configuration;

import br.com.worklink.application.audit.port.SaveSensitiveAuditEventPort;
import br.com.worklink.application.catalog.port.ListServiceCategoriesPort;
import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.catalog.port.SaveServiceCategoryPort;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.GenerateOneTimePasswordPort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.IssuedAccessToken;
import br.com.worklink.application.authentication.port.LoadActiveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.LoadRefreshSessionByTokenHashPort;
import br.com.worklink.application.authentication.port.SaveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.authentication.port.UpdateAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.UpdateRefreshSessionPort;
import br.com.worklink.application.authorization.port.ResolveAuthenticatedPrincipalPort;
import br.com.worklink.application.contact.port.CreateWhatsappContactLinkPort;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.contact.port.LoadContactIntentByIdentifierPort;
import br.com.worklink.application.contact.port.SaveContactIntentPort;
import br.com.worklink.application.contact.port.SavePostContactFeedbackPort;
import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalUseCase;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

class WorkLinkUseCaseConfigurationTest {

    @Test
    @DisplayName("Deve montar casos de uso a partir das portas configuradas")
    void shouldCreateUseCasesFromConfiguredPorts() {
        // GIVEN
        WorkLinkUseCaseConfiguration configuration = new WorkLinkUseCaseConfiguration();
        SaveServiceCategoryPort saveServiceCategoryPort = serviceCategory -> serviceCategory;
        ListServiceCategoriesPort listServiceCategoriesPort = java.util.List::of;
        SaveServiceCityPort saveServiceCityPort = serviceCity -> serviceCity;
        ListServiceCitiesPort listServiceCitiesPort = java.util.List::of;
        LoadServiceCityByIdentifierPort loadServiceCityByIdentifierPort = cityIdentifier -> Optional.empty();
        LoadServiceCategoryByIdentifierPort loadServiceCategoryByIdentifierPort = categoryIdentifier -> Optional.empty();
        SaveProfessionalPort saveProfessionalPort = professional -> professional;
        ListProfessionalsPort listProfessionalsPort = professionalSearchCriteria -> java.util.List.of();
        LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort = professionalIdentifier -> Optional.empty();
        UpdateProfessionalPort updateProfessionalPort = professional -> professional;
        ProtectSensitiveValuePort protectSensitiveValuePort = (rawSensitiveValue, purpose) -> "protected-value";
        GenerateOneTimePasswordPort generateOneTimePasswordPort = () -> "123456";
        SaveAuthenticationOtpChallengePort saveAuthenticationOtpChallengePort = challenge -> challenge;
        CurrentTimePort currentTimePort = () -> Instant.parse("2026-05-08T20:00:00Z");
        LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort = phoneNumber -> Optional.empty();
        UpdateAuthenticationOtpChallengePort updateAuthenticationOtpChallengePort = challenge -> challenge;
        LoadCustomerAccountByPhoneNumberPort loadCustomerAccountByPhoneNumberPort = phoneNumber -> Optional.empty();
        SaveCustomerAccountPort saveCustomerAccountPort = customerAccount -> customerAccount;
        IssueAccessTokenPort issueAccessTokenPort = (customerIdentifier, profile, issuedAt) ->
                new IssuedAccessToken("access-token", issuedAt.plusSeconds(900));
        GenerateSecureTokenPort generateSecureTokenPort = () -> "refresh-token";
        SaveRefreshSessionPort saveRefreshSessionPort = refreshSession -> refreshSession;
        LoadRefreshSessionByTokenHashPort loadRefreshSessionByTokenHashPort = refreshTokenHash -> Optional.empty();
        UpdateRefreshSessionPort updateRefreshSessionPort = refreshSession -> refreshSession;
        ResolveAuthenticatedPrincipalPort resolveAuthenticatedPrincipalPort = accessToken -> Optional.empty();
        SaveSensitiveAuditEventPort saveSensitiveAuditEventPort = sensitiveAuditEvent -> sensitiveAuditEvent;
        SaveContactIntentPort saveContactIntentPort = contactIntent -> contactIntent;
        CurrentContactTimePort currentContactTimePort = () -> Instant.parse("2026-05-08T20:00:00Z");
        CreateWhatsappContactLinkPort createWhatsappContactLinkPort = whatsappNumber -> "https://wa.me/%s".formatted(whatsappNumber);
        LoadContactIntentByIdentifierPort loadContactIntentByIdentifierPort = contactIntentIdentifier -> Optional.empty();
        SavePostContactFeedbackPort savePostContactFeedbackPort = postContactFeedback -> postContactFeedback;

        // WHEN
        RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase = configuration.registerBasicProfessionalUseCase(
                loadServiceCityByIdentifierPort,
                loadServiceCategoryByIdentifierPort,
                saveProfessionalPort
        );

        // THEN
        assertThat(configuration.registerServiceCategoryUseCase(saveServiceCategoryPort)).isNotNull();
        assertThat(configuration.listServiceCategoriesUseCase(listServiceCategoriesPort)).isNotNull();
        assertThat(configuration.registerServiceCityUseCase(saveServiceCityPort)).isNotNull();
        assertThat(configuration.listServiceCitiesUseCase(listServiceCitiesPort)).isNotNull();
        assertThat(registerBasicProfessionalUseCase).isNotNull();
        assertThat(configuration.listProfessionalsUseCase(listProfessionalsPort)).isNotNull();
        assertThat(configuration.completeProfessionalProfileUseCase(
                loadProfessionalByIdentifierPort,
                updateProfessionalPort,
                protectSensitiveValuePort
        )).isNotNull();
        assertThat(configuration.requestAuthenticationOtpUseCase(
                generateOneTimePasswordPort,
                protectSensitiveValuePort,
                saveAuthenticationOtpChallengePort,
                currentTimePort,
                5
        )).isNotNull();
        assertThat(configuration.verifyAuthenticationOtpUseCase(
                loadActiveAuthenticationOtpChallengePort,
                updateAuthenticationOtpChallengePort,
                loadCustomerAccountByPhoneNumberPort,
                saveCustomerAccountPort,
                protectSensitiveValuePort,
                currentTimePort,
                issueAccessTokenPort,
                generateSecureTokenPort,
                saveRefreshSessionPort,
                30
        )).isNotNull();
        assertThat(configuration.refreshAuthenticationSessionUseCase(
                loadRefreshSessionByTokenHashPort,
                updateRefreshSessionPort,
                protectSensitiveValuePort,
                currentTimePort,
                issueAccessTokenPort,
                generateSecureTokenPort,
                saveRefreshSessionPort,
                30
        )).isNotNull();
        assertThat(configuration.revokeAuthenticationSessionUseCase(
                loadRefreshSessionByTokenHashPort,
                updateRefreshSessionPort,
                protectSensitiveValuePort
        )).isNotNull();
        assertThat(configuration.resolveAuthenticatedPrincipalUseCase(resolveAuthenticatedPrincipalPort)).isNotNull();
        assertThat(configuration.authorizeSensitiveActionUseCase()).isNotNull();
        assertThat(configuration.recordSensitiveAuditEventUseCase(
                saveSensitiveAuditEventPort,
                currentTimePort
        )).isNotNull();
        assertThat(configuration.startProfessionalContactUseCase(
                loadProfessionalByIdentifierPort,
                saveContactIntentPort,
                currentContactTimePort,
                createWhatsappContactLinkPort
        )).isNotNull();
        assertThat(configuration.registerPostContactFeedbackUseCase(
                loadContactIntentByIdentifierPort,
                savePostContactFeedbackPort,
                currentContactTimePort
        )).isNotNull();
    }
}
