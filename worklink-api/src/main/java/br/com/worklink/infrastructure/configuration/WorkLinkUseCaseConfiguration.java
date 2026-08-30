package br.com.worklink.infrastructure.configuration;

import br.com.worklink.application.audit.port.SaveSensitiveAuditEventPort;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.admin.port.ListAdministrativeProfessionalReportsPort;
import br.com.worklink.application.admin.port.ListAdministrativeProfessionalsPort;
import br.com.worklink.application.admin.port.ListAdministrativeReviewAnalysisRequestsPort;
import br.com.worklink.application.admin.port.LoadAdministrativeMetricsPort;
import br.com.worklink.application.admin.port.ModerateProfessionalReportPort;
import br.com.worklink.application.admin.port.ModerateReviewAnalysisRequestPort;
import br.com.worklink.application.admin.usecase.BlockProfessionalUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeProfessionalReportsUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeProfessionalsUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeReviewAnalysisRequestsUseCase;
import br.com.worklink.application.admin.usecase.LoadAdministrativeMetricsUseCase;
import br.com.worklink.application.admin.usecase.ModerateProfessionalReportUseCase;
import br.com.worklink.application.admin.usecase.ModerateReviewAnalysisRequestUseCase;
import br.com.worklink.application.admin.usecase.UnblockProfessionalUseCase;
import br.com.worklink.application.catalog.port.ListServiceCategoriesPort;
import br.com.worklink.application.catalog.port.ListServiceCitiesPort;
import br.com.worklink.application.catalog.port.LoadServiceCitiesByIdentifiersPort;
import br.com.worklink.application.catalog.port.LoadServiceCategoryByIdentifierPort;
import br.com.worklink.application.catalog.port.LoadServiceCityByIdentifierPort;
import br.com.worklink.application.catalog.port.SaveServiceCategoryPort;
import br.com.worklink.application.catalog.port.SaveServiceCityPort;
import br.com.worklink.application.catalog.usecase.ListServiceCategoriesUseCase;
import br.com.worklink.application.catalog.usecase.ListServiceCitiesUseCase;
import br.com.worklink.application.catalog.usecase.RegisterServiceCategoryUseCase;
import br.com.worklink.application.catalog.usecase.RegisterServiceCityUseCase;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.DeliverAuthenticationOtpPort;
import br.com.worklink.application.authentication.port.ExecuteInTransactionPort;
import br.com.worklink.application.authentication.port.GenerateOneTimePasswordPort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.LoadActiveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.LoadRefreshSessionByTokenHashPort;
import br.com.worklink.application.authentication.port.LocalAuthenticationAccountRepositoryPort;
import br.com.worklink.application.authentication.port.PasswordHashingPort;
import br.com.worklink.application.authentication.port.PasswordRecoveryChallengeRepositoryPort;
import br.com.worklink.application.authentication.port.DeliverPasswordRecoveryTokenPort;
import br.com.worklink.application.authentication.port.RevokeAllCustomerRefreshSessionsPort;
import br.com.worklink.application.authentication.port.SaveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.authentication.port.UpdateAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.UpdateRefreshSessionPort;
import br.com.worklink.application.authentication.usecase.RefreshAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.LoginLocalAuthenticationUseCase;
import br.com.worklink.application.authentication.usecase.RegisterLocalAuthenticationUseCase;
import br.com.worklink.application.authentication.usecase.RequestPasswordRecoveryUseCase;
import br.com.worklink.application.authentication.usecase.ResetPasswordUseCase;
import br.com.worklink.application.authentication.usecase.RequestAuthenticationOtpUseCase;
import br.com.worklink.application.authentication.usecase.RevokeAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.VerifyAuthenticationOtpUseCase;
import br.com.worklink.application.authorization.port.ResolveAuthenticatedPrincipalPort;
import br.com.worklink.application.authorization.usecase.AuthorizeSensitiveActionUseCase;
import br.com.worklink.application.authorization.usecase.ResolveAuthenticatedPrincipalUseCase;
import br.com.worklink.application.contact.port.CreateWhatsappContactLinkPort;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.contact.port.DismissPostContactFeedbackRequestPort;
import br.com.worklink.application.contact.port.ListPendingPostContactFeedbackRequestsPort;
import br.com.worklink.application.contact.port.LoadContactIntentByIdentifierPort;
import br.com.worklink.application.contact.port.MarkPostContactFeedbackRequestAnsweredPort;
import br.com.worklink.application.contact.port.SaveContactIntentPort;
import br.com.worklink.application.contact.port.SavePostContactFeedbackPort;
import br.com.worklink.application.contact.port.SavePostContactFeedbackRequestPort;
import br.com.worklink.application.contact.usecase.DismissPostContactFeedbackRequestUseCase;
import br.com.worklink.application.contact.usecase.ListPendingPostContactFeedbackRequestsUseCase;
import br.com.worklink.application.contact.usecase.RegisterPostContactFeedbackUseCase;
import br.com.worklink.application.contact.usecase.StartProfessionalContactUseCase;
import br.com.worklink.application.metrics.port.CurrentFunctionalMetricTimePort;
import br.com.worklink.application.metrics.port.LoadFunctionalMetricsPort;
import br.com.worklink.application.metrics.port.SaveProfessionalSearchEventPort;
import br.com.worklink.application.metrics.usecase.LoadFunctionalMetricsUseCase;
import br.com.worklink.application.metrics.usecase.RecordProfessionalSearchEventUseCase;
import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.ListProfessionalPortfolioItemsPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.application.professional.port.SaveProfessionalPortfolioItemPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.storage.port.LoadStoredFileMetadataPort;
import br.com.worklink.application.storage.port.SaveStoredFileMetadataPort;
import br.com.worklink.application.location.port.SuggestNearbyServiceCitiesPort;
import br.com.worklink.application.location.usecase.PreviewCitySelectionUseCase;
import br.com.worklink.application.professional.usecase.AddProfessionalPortfolioItemUseCase;
import br.com.worklink.application.professional.usecase.CompleteProfessionalProfileUseCase;
import br.com.worklink.application.professional.usecase.ConfirmProfessionalPhoneVerificationUseCase;
import br.com.worklink.application.professional.usecase.LoadProfessionalDetailUseCase;
import br.com.worklink.application.professional.usecase.ListProfessionalPortfolioItemsUseCase;
import br.com.worklink.application.professional.usecase.ListProfessionalsUseCase;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalUseCase;
import br.com.worklink.application.professional.usecase.RequestProfessionalPhoneVerificationUseCase;
import br.com.worklink.application.review.port.ListProfessionalReviewsByProfessionalIdentifierPort;
import br.com.worklink.application.review.port.LoadProfessionalReviewByIdentifierPort;
import br.com.worklink.application.review.port.LoadPostContactFeedbackByContactIntentIdentifierPort;
import br.com.worklink.application.review.port.SaveProfessionalReviewPort;
import br.com.worklink.application.review.port.SaveProfessionalReviewAnalysisRequestPort;
import br.com.worklink.application.review.port.UpdateProfessionalReviewVisibilityPort;
import br.com.worklink.application.review.usecase.ListProfessionalReviewProfileUseCase;
import br.com.worklink.application.review.usecase.RegisterProfessionalReviewUseCase;
import br.com.worklink.application.review.usecase.RequestProfessionalReviewAnalysisUseCase;
import br.com.worklink.application.report.port.SaveProfessionalReportPort;
import br.com.worklink.application.report.usecase.RegisterProfessionalReportUseCase;
import br.com.worklink.application.storage.usecase.PrepareFileUploadUseCase;
import br.com.worklink.infrastructure.authentication.DisabledPasswordRecoveryDeliveryAdapter;
import br.com.worklink.infrastructure.authentication.DisabledAuthenticationOtpDeliveryAdapter;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

@Configuration
public class WorkLinkUseCaseConfiguration {

    @Bean
    @ConditionalOnMissingBean(DeliverPasswordRecoveryTokenPort.class)
    DeliverPasswordRecoveryTokenPort disabledPasswordRecoveryDeliveryAdapter() {
        return new DisabledPasswordRecoveryDeliveryAdapter();
    }

    @Bean
    @ConditionalOnMissingBean(DeliverAuthenticationOtpPort.class)
    DeliverAuthenticationOtpPort disabledAuthenticationOtpDeliveryAdapter() {
        return new DisabledAuthenticationOtpDeliveryAdapter();
    }

    @Bean
    RegisterServiceCategoryUseCase registerServiceCategoryUseCase(SaveServiceCategoryPort saveServiceCategoryPort) {
        return new RegisterServiceCategoryUseCase(saveServiceCategoryPort);
    }

    @Bean
    ListServiceCategoriesUseCase listServiceCategoriesUseCase(ListServiceCategoriesPort listServiceCategoriesPort) {
        return new ListServiceCategoriesUseCase(listServiceCategoriesPort);
    }

    @Bean
    RegisterServiceCityUseCase registerServiceCityUseCase(SaveServiceCityPort saveServiceCityPort) {
        return new RegisterServiceCityUseCase(saveServiceCityPort);
    }

    @Bean
    ListServiceCitiesUseCase listServiceCitiesUseCase(ListServiceCitiesPort listServiceCitiesPort) {
        return new ListServiceCitiesUseCase(listServiceCitiesPort);
    }

    @Bean
    PreviewCitySelectionUseCase previewCitySelectionUseCase(
            LoadServiceCitiesByIdentifiersPort loadServiceCitiesByIdentifiersPort,
            SuggestNearbyServiceCitiesPort suggestNearbyServiceCitiesPort
    ) {
        return new PreviewCitySelectionUseCase(loadServiceCitiesByIdentifiersPort, suggestNearbyServiceCitiesPort);
    }

    @Bean
    RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase(
            LoadServiceCityByIdentifierPort loadServiceCityByIdentifierPort,
            LoadServiceCategoryByIdentifierPort loadServiceCategoryByIdentifierPort,
            SaveProfessionalPort saveProfessionalPort
    ) {
        return new RegisterBasicProfessionalUseCase(
                loadServiceCityByIdentifierPort,
                loadServiceCategoryByIdentifierPort,
                saveProfessionalPort
        );
    }

    @Bean
    ListProfessionalsUseCase listProfessionalsUseCase(ListProfessionalsPort listProfessionalsPort) {
        return new ListProfessionalsUseCase(listProfessionalsPort);
    }

    @Bean
    LoadProfessionalDetailUseCase loadProfessionalDetailUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort
    ) {
        return new LoadProfessionalDetailUseCase(loadProfessionalByIdentifierPort);
    }

    @Bean
    AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            LoadStoredFileMetadataPort loadStoredFileMetadataPort,
            ListProfessionalPortfolioItemsPort listProfessionalPortfolioItemsPort,
            SaveProfessionalPortfolioItemPort saveProfessionalPortfolioItemPort
    ) {
        return new AddProfessionalPortfolioItemUseCase(
                loadProfessionalByIdentifierPort,
                loadStoredFileMetadataPort,
                listProfessionalPortfolioItemsPort,
                saveProfessionalPortfolioItemPort
        );
    }

    @Bean
    ListProfessionalPortfolioItemsUseCase listProfessionalPortfolioItemsUseCase(
            ListProfessionalPortfolioItemsPort listProfessionalPortfolioItemsPort
    ) {
        return new ListProfessionalPortfolioItemsUseCase(listProfessionalPortfolioItemsPort);
    }

    @Bean
    CompleteProfessionalProfileUseCase completeProfessionalProfileUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            UpdateProfessionalPort updateProfessionalPort,
            ProtectSensitiveValuePort protectSensitiveValuePort
    ) {
        return new CompleteProfessionalProfileUseCase(
                loadProfessionalByIdentifierPort,
                updateProfessionalPort,
                protectSensitiveValuePort
        );
    }

    @Bean
    RequestProfessionalPhoneVerificationUseCase requestProfessionalPhoneVerificationUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            CurrentTimePort currentTimePort,
            @Value("${worklink.security.professional-phone-verification-expiration-minutes}") long expirationMinutes
    ) {
        return new RequestProfessionalPhoneVerificationUseCase(
                loadProfessionalByIdentifierPort,
                currentTimePort,
                Duration.ofMinutes(expirationMinutes)
        );
    }

    @Bean
    ConfirmProfessionalPhoneVerificationUseCase confirmProfessionalPhoneVerificationUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            UpdateProfessionalPort updateProfessionalPort,
            @Value("${worklink.security.professional-phone-verification-code}") String expectedVerificationCode
    ) {
        return new ConfirmProfessionalPhoneVerificationUseCase(
                loadProfessionalByIdentifierPort,
                updateProfessionalPort,
                expectedVerificationCode
        );
    }

    @Bean
    PrepareFileUploadUseCase prepareFileUploadUseCase(
            SaveStoredFileMetadataPort saveStoredFileMetadataPort
    ) {
        return new PrepareFileUploadUseCase(saveStoredFileMetadataPort);
    }

    @Bean
    RequestAuthenticationOtpUseCase requestAuthenticationOtpUseCase(
            GenerateOneTimePasswordPort generateOneTimePasswordPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveAuthenticationOtpChallengePort saveAuthenticationOtpChallengePort,
            LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort,
            DeliverAuthenticationOtpPort deliverAuthenticationOtpPort,
            CurrentTimePort currentTimePort,
            @Value("${worklink.security.otp-expiration-minutes}") long otpExpirationMinutes,
            @Value("${worklink.security.otp-request-cooldown-seconds:45}") long otpRequestCooldownSeconds,
            @Value("${worklink.features.otp-authentication-enabled}") boolean enabled
    ) {
        return new RequestAuthenticationOtpUseCase(
                generateOneTimePasswordPort,
                protectSensitiveValuePort,
                saveAuthenticationOtpChallengePort,
                loadActiveAuthenticationOtpChallengePort,
                deliverAuthenticationOtpPort,
                currentTimePort,
                Duration.ofMinutes(otpExpirationMinutes),
                Duration.ofSeconds(otpRequestCooldownSeconds),
                enabled
        );
    }

    @Bean
    VerifyAuthenticationOtpUseCase verifyAuthenticationOtpUseCase(
            LoadActiveAuthenticationOtpChallengePort loadActiveAuthenticationOtpChallengePort,
            UpdateAuthenticationOtpChallengePort updateAuthenticationOtpChallengePort,
            LoadCustomerAccountByPhoneNumberPort loadCustomerAccountByPhoneNumberPort,
            SaveCustomerAccountPort saveCustomerAccountPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            CurrentTimePort currentTimePort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            @Value("${worklink.security.refresh-token-expiration-days}") long refreshTokenExpirationDays,
            @Value("${worklink.features.otp-authentication-enabled}") boolean enabled
    ) {
        return new VerifyAuthenticationOtpUseCase(
                loadActiveAuthenticationOtpChallengePort,
                updateAuthenticationOtpChallengePort,
                loadCustomerAccountByPhoneNumberPort,
                saveCustomerAccountPort,
                protectSensitiveValuePort,
                currentTimePort,
                issueAccessTokenPort,
                generateSecureTokenPort,
                saveRefreshSessionPort,
                Duration.ofDays(refreshTokenExpirationDays),
                enabled
        );
    }

    @Bean
    RefreshAuthenticationSessionUseCase refreshAuthenticationSessionUseCase(
            LoadRefreshSessionByTokenHashPort loadRefreshSessionByTokenHashPort,
            UpdateRefreshSessionPort updateRefreshSessionPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            CurrentTimePort currentTimePort,
            ExecuteInTransactionPort executeInTransactionPort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            @Value("${worklink.security.refresh-token-expiration-days}") long refreshTokenExpirationDays
    ) {
        return new RefreshAuthenticationSessionUseCase(
                loadRefreshSessionByTokenHashPort,
                updateRefreshSessionPort,
                protectSensitiveValuePort,
                currentTimePort,
                executeInTransactionPort,
                issueAccessTokenPort,
                generateSecureTokenPort,
                saveRefreshSessionPort,
                Duration.ofDays(refreshTokenExpirationDays)
        );
    }

    @Bean
    RevokeAuthenticationSessionUseCase revokeAuthenticationSessionUseCase(
            LoadRefreshSessionByTokenHashPort loadRefreshSessionByTokenHashPort,
            UpdateRefreshSessionPort updateRefreshSessionPort,
            ProtectSensitiveValuePort protectSensitiveValuePort
    ) {
        return new RevokeAuthenticationSessionUseCase(
                loadRefreshSessionByTokenHashPort,
                updateRefreshSessionPort,
                protectSensitiveValuePort
        );
    }

    @Bean
    RegisterLocalAuthenticationUseCase registerLocalAuthenticationUseCase(
            LocalAuthenticationAccountRepositoryPort accountRepository,
            LoadCustomerAccountByPhoneNumberPort loadCustomerByPhone,
            SaveCustomerAccountPort saveCustomer,
            PasswordHashingPort passwordHashingPort,
            CurrentTimePort currentTimePort,
            ExecuteInTransactionPort executeInTransactionPort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            @Value("${worklink.security.refresh-token-expiration-days}") long refreshTokenExpirationDays,
            @Value("${worklink.features.local-authentication-enabled}") boolean enabled
    ) {
        return new RegisterLocalAuthenticationUseCase(
                accountRepository, loadCustomerByPhone, saveCustomer, passwordHashingPort, currentTimePort,
                executeInTransactionPort,
                issueAccessTokenPort, generateSecureTokenPort, protectSensitiveValuePort, saveRefreshSessionPort,
                Duration.ofDays(refreshTokenExpirationDays), enabled
        );
    }

    @Bean
    LoginLocalAuthenticationUseCase loginLocalAuthenticationUseCase(
            LocalAuthenticationAccountRepositoryPort accountRepository,
            PasswordHashingPort passwordHashingPort,
            CurrentTimePort currentTimePort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            @Value("${worklink.security.refresh-token-expiration-days}") long refreshTokenExpirationDays,
            @Value("${worklink.security.maximum-failed-login-attempts}") int maximumFailedAttempts,
            @Value("${worklink.security.login-blocking-minutes}") long blockingMinutes,
            @Value("${worklink.features.local-authentication-enabled}") boolean enabled
    ) {
        return new LoginLocalAuthenticationUseCase(
                accountRepository, passwordHashingPort, currentTimePort, issueAccessTokenPort,
                generateSecureTokenPort, protectSensitiveValuePort, saveRefreshSessionPort,
                Duration.ofDays(refreshTokenExpirationDays), maximumFailedAttempts,
                Duration.ofMinutes(blockingMinutes), enabled
        );
    }

    @Bean
    RequestPasswordRecoveryUseCase requestPasswordRecoveryUseCase(
            LocalAuthenticationAccountRepositoryPort accountRepository,
            PasswordRecoveryChallengeRepositoryPort challengeRepository,
            GenerateSecureTokenPort generateSecureTokenPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            DeliverPasswordRecoveryTokenPort deliveryPort,
            CurrentTimePort currentTimePort,
            @Value("${worklink.security.password-recovery-expiration-minutes}") long expirationMinutes
    ) {
        return new RequestPasswordRecoveryUseCase(
                accountRepository, challengeRepository, generateSecureTokenPort, protectSensitiveValuePort,
                deliveryPort, currentTimePort, Duration.ofMinutes(expirationMinutes)
        );
    }

    @Bean
    ResetPasswordUseCase resetPasswordUseCase(
            PasswordRecoveryChallengeRepositoryPort challengeRepository,
            LocalAuthenticationAccountRepositoryPort accountRepository,
            PasswordHashingPort passwordHashingPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            RevokeAllCustomerRefreshSessionsPort revokeAllSessionsPort,
            CurrentTimePort currentTimePort,
            ExecuteInTransactionPort executeInTransactionPort
    ) {
        return new ResetPasswordUseCase(
                challengeRepository, accountRepository, passwordHashingPort, protectSensitiveValuePort,
                revokeAllSessionsPort, currentTimePort, executeInTransactionPort
        );
    }

    @Bean
    ResolveAuthenticatedPrincipalUseCase resolveAuthenticatedPrincipalUseCase(
            ResolveAuthenticatedPrincipalPort resolveAuthenticatedPrincipalPort
    ) {
        return new ResolveAuthenticatedPrincipalUseCase(resolveAuthenticatedPrincipalPort);
    }

    @Bean
    AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase() {
        return new AuthorizeSensitiveActionUseCase();
    }

    @Bean
    ListAdministrativeProfessionalsUseCase listAdministrativeProfessionalsUseCase(
            ListAdministrativeProfessionalsPort listAdministrativeProfessionalsPort
    ) {
        return new ListAdministrativeProfessionalsUseCase(listAdministrativeProfessionalsPort);
    }

    @Bean
    BlockProfessionalUseCase blockProfessionalUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            UpdateProfessionalPort updateProfessionalPort
    ) {
        return new BlockProfessionalUseCase(loadProfessionalByIdentifierPort, updateProfessionalPort);
    }

    @Bean
    UnblockProfessionalUseCase unblockProfessionalUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            UpdateProfessionalPort updateProfessionalPort
    ) {
        return new UnblockProfessionalUseCase(loadProfessionalByIdentifierPort, updateProfessionalPort);
    }

    @Bean
    ListAdministrativeProfessionalReportsUseCase listAdministrativeProfessionalReportsUseCase(
            ListAdministrativeProfessionalReportsPort listAdministrativeProfessionalReportsPort
    ) {
        return new ListAdministrativeProfessionalReportsUseCase(listAdministrativeProfessionalReportsPort);
    }

    @Bean
    ListAdministrativeReviewAnalysisRequestsUseCase listAdministrativeReviewAnalysisRequestsUseCase(
            ListAdministrativeReviewAnalysisRequestsPort listAdministrativeReviewAnalysisRequestsPort
    ) {
        return new ListAdministrativeReviewAnalysisRequestsUseCase(listAdministrativeReviewAnalysisRequestsPort);
    }

    @Bean
    LoadAdministrativeMetricsUseCase loadAdministrativeMetricsUseCase(
            LoadAdministrativeMetricsPort loadAdministrativeMetricsPort
    ) {
        return new LoadAdministrativeMetricsUseCase(loadAdministrativeMetricsPort);
    }

    @Bean
    RecordProfessionalSearchEventUseCase recordProfessionalSearchEventUseCase(
            SaveProfessionalSearchEventPort saveProfessionalSearchEventPort,
            CurrentFunctionalMetricTimePort currentFunctionalMetricTimePort
    ) {
        return new RecordProfessionalSearchEventUseCase(
                saveProfessionalSearchEventPort,
                currentFunctionalMetricTimePort
        );
    }

    @Bean
    LoadFunctionalMetricsUseCase loadFunctionalMetricsUseCase(
            LoadFunctionalMetricsPort loadFunctionalMetricsPort
    ) {
        return new LoadFunctionalMetricsUseCase(loadFunctionalMetricsPort);
    }

    @Bean
    RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase(
            SaveSensitiveAuditEventPort saveSensitiveAuditEventPort,
            CurrentTimePort currentTimePort
    ) {
        return new RecordSensitiveAuditEventUseCase(saveSensitiveAuditEventPort, currentTimePort);
    }

    @Bean
    StartProfessionalContactUseCase startProfessionalContactUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            SaveContactIntentPort saveContactIntentPort,
            SavePostContactFeedbackRequestPort savePostContactFeedbackRequestPort,
            CurrentContactTimePort currentContactTimePort,
            CreateWhatsappContactLinkPort createWhatsappContactLinkPort
    ) {
        return new StartProfessionalContactUseCase(
                loadProfessionalByIdentifierPort,
                saveContactIntentPort,
                savePostContactFeedbackRequestPort,
                currentContactTimePort,
                createWhatsappContactLinkPort
        );
    }

    @Bean
    RegisterPostContactFeedbackUseCase registerPostContactFeedbackUseCase(
            LoadContactIntentByIdentifierPort loadContactIntentByIdentifierPort,
            SavePostContactFeedbackPort savePostContactFeedbackPort,
            MarkPostContactFeedbackRequestAnsweredPort markPostContactFeedbackRequestAnsweredPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        return new RegisterPostContactFeedbackUseCase(
                loadContactIntentByIdentifierPort,
                savePostContactFeedbackPort,
                markPostContactFeedbackRequestAnsweredPort,
                currentContactTimePort
        );
    }

    @Bean
    ListPendingPostContactFeedbackRequestsUseCase listPendingPostContactFeedbackRequestsUseCase(
            ListPendingPostContactFeedbackRequestsPort listPendingPostContactFeedbackRequestsPort
    ) {
        return new ListPendingPostContactFeedbackRequestsUseCase(listPendingPostContactFeedbackRequestsPort);
    }

    @Bean
    DismissPostContactFeedbackRequestUseCase dismissPostContactFeedbackRequestUseCase(
            DismissPostContactFeedbackRequestPort dismissPostContactFeedbackRequestPort
    ) {
        return new DismissPostContactFeedbackRequestUseCase(dismissPostContactFeedbackRequestPort);
    }

    @Bean
    RegisterProfessionalReviewUseCase registerProfessionalReviewUseCase(
            LoadContactIntentByIdentifierPort loadContactIntentByIdentifierPort,
            LoadPostContactFeedbackByContactIntentIdentifierPort loadPostContactFeedbackByContactIntentIdentifierPort,
            SaveProfessionalReviewPort saveProfessionalReviewPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        return new RegisterProfessionalReviewUseCase(
                loadContactIntentByIdentifierPort,
                loadPostContactFeedbackByContactIntentIdentifierPort,
                saveProfessionalReviewPort,
                currentContactTimePort
        );
    }

    @Bean
    ListProfessionalReviewProfileUseCase listProfessionalReviewProfileUseCase(
            ListProfessionalReviewsByProfessionalIdentifierPort listProfessionalReviewsByProfessionalIdentifierPort
    ) {
        return new ListProfessionalReviewProfileUseCase(listProfessionalReviewsByProfessionalIdentifierPort);
    }

    @Bean
    RequestProfessionalReviewAnalysisUseCase requestProfessionalReviewAnalysisUseCase(
            LoadProfessionalReviewByIdentifierPort loadProfessionalReviewByIdentifierPort,
            SaveProfessionalReviewAnalysisRequestPort saveProfessionalReviewAnalysisRequestPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        return new RequestProfessionalReviewAnalysisUseCase(
                loadProfessionalReviewByIdentifierPort,
                saveProfessionalReviewAnalysisRequestPort,
                currentContactTimePort
        );
    }

    @Bean
    RegisterProfessionalReportUseCase registerProfessionalReportUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            SaveProfessionalReportPort saveProfessionalReportPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        return new RegisterProfessionalReportUseCase(
                loadProfessionalByIdentifierPort,
                saveProfessionalReportPort,
                currentContactTimePort
        );
    }

    @Bean
    ModerateProfessionalReportUseCase moderateProfessionalReportUseCase(
            ModerateProfessionalReportPort moderateProfessionalReportPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        return new ModerateProfessionalReportUseCase(
                moderateProfessionalReportPort,
                currentContactTimePort
        );
    }

    @Bean
    ModerateReviewAnalysisRequestUseCase moderateReviewAnalysisRequestUseCase(
            ModerateReviewAnalysisRequestPort moderateReviewAnalysisRequestPort,
            UpdateProfessionalReviewVisibilityPort updateProfessionalReviewVisibilityPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        return new ModerateReviewAnalysisRequestUseCase(
                moderateReviewAnalysisRequestPort,
                updateProfessionalReviewVisibilityPort,
                currentContactTimePort
        );
    }
}
