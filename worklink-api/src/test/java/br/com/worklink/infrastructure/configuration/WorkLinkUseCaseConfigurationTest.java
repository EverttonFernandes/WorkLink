package br.com.worklink.infrastructure.configuration;

import br.com.worklink.application.audit.port.SaveSensitiveAuditEventPort;
import br.com.worklink.application.catalog.port.ListServiceCategoriesPort;
import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.catalog.port.SaveServiceCategoryPort;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.DeliverAuthenticationOtpPort;
import br.com.worklink.application.authentication.port.ExecuteInTransactionPort;
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
import br.com.worklink.application.contact.port.DismissPostContactFeedbackRequestPort;
import br.com.worklink.application.contact.port.ListPendingPostContactFeedbackRequestsPort;
import br.com.worklink.application.contact.port.LoadContactIntentByIdentifierPort;
import br.com.worklink.application.contact.port.MarkPostContactFeedbackRequestAnsweredPort;
import br.com.worklink.application.contact.port.SaveContactIntentPort;
import br.com.worklink.application.contact.port.SavePostContactFeedbackPort;
import br.com.worklink.application.contact.port.SavePostContactFeedbackRequestPort;
import br.com.worklink.application.admin.port.ModerateProfessionalReportPort;
import br.com.worklink.application.admin.port.ModerateReviewAnalysisRequestPort;
import br.com.worklink.application.metrics.port.CurrentFunctionalMetricTimePort;
import br.com.worklink.application.metrics.port.LoadFunctionalMetricsPort;
import br.com.worklink.application.metrics.port.SaveProfessionalSearchEventPort;
import br.com.worklink.application.metrics.usecase.FunctionalMetricsResponse;
import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.ListProfessionalPortfolioItemsPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.application.professional.port.SaveProfessionalPortfolioItemPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.storage.port.LoadStoredFileMetadataPort;
import br.com.worklink.application.storage.port.SaveStoredFileMetadataPort;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalUseCase;
import br.com.worklink.application.review.port.LoadPostContactFeedbackByContactIntentIdentifierPort;
import br.com.worklink.application.review.port.ListProfessionalReviewsByProfessionalIdentifierPort;
import br.com.worklink.application.review.port.LoadProfessionalReviewByIdentifierPort;
import br.com.worklink.application.review.port.SaveProfessionalReviewAnalysisRequestPort;
import br.com.worklink.application.review.port.SaveProfessionalReviewPort;
import br.com.worklink.application.review.port.UpdateProfessionalReviewVisibilityPort;
import br.com.worklink.application.report.port.SaveProfessionalReportPort;

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
        ListProfessionalPortfolioItemsPort listProfessionalPortfolioItemsPort =
                professionalIdentifier -> java.util.List.of();
        SaveProfessionalPortfolioItemPort saveProfessionalPortfolioItemPort =
                professionalPortfolioItem -> professionalPortfolioItem;
        LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort = professionalIdentifier -> Optional.empty();
        UpdateProfessionalPort updateProfessionalPort = professional -> professional;
        ProtectSensitiveValuePort protectSensitiveValuePort = (rawSensitiveValue, purpose) -> "protected-value";
        LoadStoredFileMetadataPort loadStoredFileMetadataPort = fileIdentifier -> Optional.empty();
        SaveStoredFileMetadataPort saveStoredFileMetadataPort = storedFile -> storedFile;
        GenerateOneTimePasswordPort generateOneTimePasswordPort = () -> "123456";
        SaveAuthenticationOtpChallengePort saveAuthenticationOtpChallengePort = challenge -> challenge;
        DeliverAuthenticationOtpPort deliverAuthenticationOtpPort = new DeliverAuthenticationOtpPort() {
            @Override
            public java.util.List<String> availableDeliveryChannels() {
                return java.util.List.of("SMS");
            }

            @Override
            public boolean isSimulatedDelivery() {
                return true;
            }

            @Override
            public void deliverAuthenticationOtp(
                    br.com.worklink.application.authentication.port.AuthenticationOtpDeliveryRequest request
            ) {
            }
        };
        CurrentTimePort currentTimePort = () -> Instant.parse("2026-05-08T20:00:00Z");
        ExecuteInTransactionPort executeInTransactionPort = new ExecuteInTransactionPort() {
            @Override
            public <T> T execute(java.util.function.Supplier<T> action) {
                return action.get();
            }
        };
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
        SavePostContactFeedbackRequestPort savePostContactFeedbackRequestPort =
                (customerIdentifier, contactIntentIdentifier, createdAt) -> {
                };
        CurrentContactTimePort currentContactTimePort = () -> Instant.parse("2026-05-08T20:00:00Z");
        CreateWhatsappContactLinkPort createWhatsappContactLinkPort = whatsappNumber -> "https://wa.me/%s".formatted(whatsappNumber);
        LoadContactIntentByIdentifierPort loadContactIntentByIdentifierPort = contactIntentIdentifier -> Optional.empty();
        SavePostContactFeedbackPort savePostContactFeedbackPort = postContactFeedback -> postContactFeedback;
        MarkPostContactFeedbackRequestAnsweredPort markPostContactFeedbackRequestAnsweredPort =
                (customerIdentifier, contactIntentIdentifier) -> {
                };
        ListPendingPostContactFeedbackRequestsPort listPendingPostContactFeedbackRequestsPort =
                customerIdentifier -> java.util.List.of();
        DismissPostContactFeedbackRequestPort dismissPostContactFeedbackRequestPort =
                (customerIdentifier, contactIntentIdentifier) -> true;
        SaveProfessionalSearchEventPort saveProfessionalSearchEventPort = professionalSearchEvent -> professionalSearchEvent;
        CurrentFunctionalMetricTimePort currentFunctionalMetricTimePort = () -> Instant.parse("2026-05-08T20:00:00Z");
        LoadFunctionalMetricsPort loadFunctionalMetricsPort = () ->
                new FunctionalMetricsResponse(
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        false,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        null
                );
        LoadPostContactFeedbackByContactIntentIdentifierPort loadPostContactFeedbackByContactIntentIdentifierPort =
                contactIntentIdentifier -> Optional.empty();
        SaveProfessionalReviewPort saveProfessionalReviewPort = professionalReview -> professionalReview;
        ListProfessionalReviewsByProfessionalIdentifierPort listProfessionalReviewsByProfessionalIdentifierPort =
                professionalIdentifier -> java.util.List.of();
        LoadProfessionalReviewByIdentifierPort loadProfessionalReviewByIdentifierPort =
                professionalReviewIdentifier -> Optional.empty();
        SaveProfessionalReviewAnalysisRequestPort saveProfessionalReviewAnalysisRequestPort =
                professionalReviewAnalysisRequest -> professionalReviewAnalysisRequest;
        SaveProfessionalReportPort saveProfessionalReportPort = professionalReport -> professionalReport;
        ModerateProfessionalReportPort moderateProfessionalReportPort =
                (professionalReportIdentifier, moderationStatus, moderationDecision, moderationNotes, decidedAt) ->
                        Optional.empty();
        ModerateReviewAnalysisRequestPort moderateReviewAnalysisRequestPort =
                (reviewAnalysisRequestIdentifier, moderationStatus, moderationDecision, moderationNotes, decidedAt) ->
                        Optional.empty();
        UpdateProfessionalReviewVisibilityPort updateProfessionalReviewVisibilityPort =
                (professionalReviewIdentifier, hiddenFromPublic) -> {
                };

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
        assertThat(configuration.addProfessionalPortfolioItemUseCase(
                loadProfessionalByIdentifierPort,
                loadStoredFileMetadataPort,
                listProfessionalPortfolioItemsPort,
                saveProfessionalPortfolioItemPort
        )).isNotNull();
        assertThat(configuration.listProfessionalPortfolioItemsUseCase(
                listProfessionalPortfolioItemsPort
        )).isNotNull();
        assertThat(configuration.completeProfessionalProfileUseCase(
                loadProfessionalByIdentifierPort,
                updateProfessionalPort,
                protectSensitiveValuePort
        )).isNotNull();
        assertThat(configuration.prepareFileUploadUseCase(saveStoredFileMetadataPort)).isNotNull();
        assertThat(configuration.requestAuthenticationOtpUseCase(
                generateOneTimePasswordPort,
                protectSensitiveValuePort,
                saveAuthenticationOtpChallengePort,
                loadActiveAuthenticationOtpChallengePort,
                deliverAuthenticationOtpPort,
                currentTimePort,
                5,
                45,
                true
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
                30,
                true
        )).isNotNull();
        assertThat(configuration.refreshAuthenticationSessionUseCase(
                loadRefreshSessionByTokenHashPort,
                updateRefreshSessionPort,
                protectSensitiveValuePort,
                currentTimePort,
                executeInTransactionPort,
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
                savePostContactFeedbackRequestPort,
                currentContactTimePort,
                createWhatsappContactLinkPort
        )).isNotNull();
        assertThat(configuration.registerPostContactFeedbackUseCase(
                loadContactIntentByIdentifierPort,
                savePostContactFeedbackPort,
                markPostContactFeedbackRequestAnsweredPort,
                currentContactTimePort
        )).isNotNull();
        assertThat(configuration.listPendingPostContactFeedbackRequestsUseCase(
                listPendingPostContactFeedbackRequestsPort
        )).isNotNull();
        assertThat(configuration.dismissPostContactFeedbackRequestUseCase(
                dismissPostContactFeedbackRequestPort
        )).isNotNull();
        assertThat(configuration.recordProfessionalSearchEventUseCase(
                saveProfessionalSearchEventPort,
                currentFunctionalMetricTimePort
        )).isNotNull();
        assertThat(configuration.loadFunctionalMetricsUseCase(loadFunctionalMetricsPort)).isNotNull();
        assertThat(configuration.registerProfessionalReviewUseCase(
                loadContactIntentByIdentifierPort,
                loadPostContactFeedbackByContactIntentIdentifierPort,
                saveProfessionalReviewPort,
                currentContactTimePort
        )).isNotNull();
        assertThat(configuration.listProfessionalReviewProfileUseCase(
                listProfessionalReviewsByProfessionalIdentifierPort
        )).isNotNull();
        assertThat(configuration.requestProfessionalReviewAnalysisUseCase(
                loadProfessionalReviewByIdentifierPort,
                saveProfessionalReviewAnalysisRequestPort,
                currentContactTimePort
        )).isNotNull();
        assertThat(configuration.registerProfessionalReportUseCase(
                loadProfessionalByIdentifierPort,
                saveProfessionalReportPort,
                currentContactTimePort
        )).isNotNull();
        assertThat(configuration.moderateProfessionalReportUseCase(
                moderateProfessionalReportPort,
                currentContactTimePort
        )).isNotNull();
        assertThat(configuration.moderateReviewAnalysisRequestUseCase(
                moderateReviewAnalysisRequestPort,
                updateProfessionalReviewVisibilityPort,
                currentContactTimePort
        )).isNotNull();
    }
}
