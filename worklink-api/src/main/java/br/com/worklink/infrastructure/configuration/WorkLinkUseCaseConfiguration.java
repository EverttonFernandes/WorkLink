package br.com.worklink.infrastructure.configuration;

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
import br.com.worklink.application.authentication.port.GenerateOneTimePasswordPort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.LoadActiveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.LoadRefreshSessionByTokenHashPort;
import br.com.worklink.application.authentication.port.SaveAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.authentication.port.UpdateAuthenticationOtpChallengePort;
import br.com.worklink.application.authentication.port.UpdateRefreshSessionPort;
import br.com.worklink.application.authentication.usecase.RefreshAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.RequestAuthenticationOtpUseCase;
import br.com.worklink.application.authentication.usecase.RevokeAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.VerifyAuthenticationOtpUseCase;
import br.com.worklink.application.professional.port.ListProfessionalsPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.application.professional.port.SaveProfessionalPort;
import br.com.worklink.application.professional.port.UpdateProfessionalPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.storage.port.SaveStoredFileMetadataPort;
import br.com.worklink.application.location.port.SuggestNearbyServiceCitiesPort;
import br.com.worklink.application.location.usecase.PreviewCitySelectionUseCase;
import br.com.worklink.application.professional.usecase.CompleteProfessionalProfileUseCase;
import br.com.worklink.application.professional.usecase.ListProfessionalsUseCase;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalUseCase;
import br.com.worklink.application.storage.usecase.PrepareFileUploadUseCase;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

@Configuration
public class WorkLinkUseCaseConfiguration {

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
            CurrentTimePort currentTimePort,
            @Value("${worklink.security.otp-expiration-minutes}") long otpExpirationMinutes
    ) {
        return new RequestAuthenticationOtpUseCase(
                generateOneTimePasswordPort,
                protectSensitiveValuePort,
                saveAuthenticationOtpChallengePort,
                currentTimePort,
                Duration.ofMinutes(otpExpirationMinutes)
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
            @Value("${worklink.security.refresh-token-expiration-days}") long refreshTokenExpirationDays
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
                Duration.ofDays(refreshTokenExpirationDays)
        );
    }

    @Bean
    RefreshAuthenticationSessionUseCase refreshAuthenticationSessionUseCase(
            LoadRefreshSessionByTokenHashPort loadRefreshSessionByTokenHashPort,
            UpdateRefreshSessionPort updateRefreshSessionPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            CurrentTimePort currentTimePort,
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
}
