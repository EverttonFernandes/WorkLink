package br.com.worklink.api.customer;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthorizationOwnership;
import br.com.worklink.application.authorization.usecase.AuthorizeSensitiveActionUseCase;
import br.com.worklink.application.authorization.usecase.SensitiveAction;
import br.com.worklink.application.contact.usecase.DismissPostContactFeedbackRequestUseCase;
import br.com.worklink.application.contact.usecase.ListPendingPostContactFeedbackRequestsUseCase;
import br.com.worklink.application.customer.usecase.CustomerProfileResponse;
import br.com.worklink.application.customer.usecase.LoadCustomerProfileUseCase;
import br.com.worklink.application.customer.usecase.RemoveCustomerSavedProfessionalUseCase;
import br.com.worklink.application.customer.usecase.SaveCustomerProfessionalUseCase;
import br.com.worklink.application.customer.usecase.UpdateCustomerProfilePreferencesRequest;
import br.com.worklink.application.customer.usecase.UpdateCustomerProfilePreferencesUseCase;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;
import java.util.List;

@RestController
@RequestMapping("/api/v1/customers/me")
public class CustomerProfileController {

    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;
    private final LoadCustomerProfileUseCase loadCustomerProfileUseCase;
    private final UpdateCustomerProfilePreferencesUseCase updateCustomerProfilePreferencesUseCase;
    private final SaveCustomerProfessionalUseCase saveCustomerProfessionalUseCase;
    private final RemoveCustomerSavedProfessionalUseCase removeCustomerSavedProfessionalUseCase;
    private final ListPendingPostContactFeedbackRequestsUseCase listPendingPostContactFeedbackRequestsUseCase;
    private final DismissPostContactFeedbackRequestUseCase dismissPostContactFeedbackRequestUseCase;
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    public CustomerProfileController(
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase,
            LoadCustomerProfileUseCase loadCustomerProfileUseCase,
            UpdateCustomerProfilePreferencesUseCase updateCustomerProfilePreferencesUseCase,
            SaveCustomerProfessionalUseCase saveCustomerProfessionalUseCase,
            RemoveCustomerSavedProfessionalUseCase removeCustomerSavedProfessionalUseCase,
            ListPendingPostContactFeedbackRequestsUseCase listPendingPostContactFeedbackRequestsUseCase,
            DismissPostContactFeedbackRequestUseCase dismissPostContactFeedbackRequestUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase
    ) {
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.authorizeSensitiveActionUseCase = authorizeSensitiveActionUseCase;
        this.loadCustomerProfileUseCase = loadCustomerProfileUseCase;
        this.updateCustomerProfilePreferencesUseCase = updateCustomerProfilePreferencesUseCase;
        this.saveCustomerProfessionalUseCase = saveCustomerProfessionalUseCase;
        this.removeCustomerSavedProfessionalUseCase = removeCustomerSavedProfessionalUseCase;
        this.listPendingPostContactFeedbackRequestsUseCase = listPendingPostContactFeedbackRequestsUseCase;
        this.dismissPostContactFeedbackRequestUseCase = dismissPostContactFeedbackRequestUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
    }

    @GetMapping("/profile")
    CustomerProfileHttpResponse loadCustomerProfile(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = resolveAndAuthorizeCustomer(authorizationHeader);
        CustomerProfileResponse customerProfileResponse = loadCustomerProfileUseCase.loadCustomerProfile(
                authenticatedPrincipal.principalIdentifier()
        );
        return CustomerProfileHttpResponse.fromUseCaseResponse(customerProfileResponse);
    }

    @GetMapping("/post-contact-feedback-requests")
    List<PendingPostContactFeedbackRequestHttpResponse> listPendingPostContactFeedbackRequests(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = resolveAndAuthorizeCustomer(authorizationHeader);
        return listPendingPostContactFeedbackRequestsUseCase
                .listPendingPostContactFeedbackRequests(authenticatedPrincipal.principalIdentifier())
                .stream()
                .map(PendingPostContactFeedbackRequestHttpResponse::fromUseCaseResponse)
                .toList();
    }

    @PatchMapping("/profile/preferences")
    CustomerProfileHttpResponse updateCustomerProfilePreferences(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody UpdateCustomerProfilePreferencesHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = resolveAndAuthorizeCustomer(authorizationHeader);
        CustomerProfileResponse customerProfileResponse =
                updateCustomerProfilePreferencesUseCase.updateCustomerProfilePreferences(
                        new UpdateCustomerProfilePreferencesRequest(
                                authenticatedPrincipal,
                                request.whatsappNotificationsEnabled(),
                                request.profilePersonalizationEnabled()
                        )
                );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.UPDATE_CUSTOMER_PROFILE_PREFERENCES,
                SensitiveAuditTargetType.CUSTOMER_PROFILE,
                authenticatedPrincipal.principalIdentifier(),
                SensitiveAuditOutcome.SUCCESS
        ));
        return CustomerProfileHttpResponse.fromUseCaseResponse(customerProfileResponse);
    }

    @PostMapping("/saved-professionals/{professionalIdentifier}")
    @ResponseStatus(HttpStatus.OK)
    CustomerProfileHttpResponse saveCustomerProfessional(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @PathVariable UUID professionalIdentifier
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = resolveAndAuthorizeCustomer(authorizationHeader);
        CustomerProfileResponse customerProfileResponse = saveCustomerProfessionalUseCase.saveCustomerProfessional(
                authenticatedPrincipal.principalIdentifier(),
                professionalIdentifier
        );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.SAVE_CUSTOMER_PROFESSIONAL,
                SensitiveAuditTargetType.PROFESSIONAL_PROFILE,
                professionalIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));
        return CustomerProfileHttpResponse.fromUseCaseResponse(customerProfileResponse);
    }

    @DeleteMapping("/saved-professionals/{professionalIdentifier}")
    CustomerProfileHttpResponse removeCustomerSavedProfessional(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @PathVariable UUID professionalIdentifier
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = resolveAndAuthorizeCustomer(authorizationHeader);
        CustomerProfileResponse customerProfileResponse =
                removeCustomerSavedProfessionalUseCase.removeCustomerSavedProfessional(
                        authenticatedPrincipal.principalIdentifier(),
                        professionalIdentifier
                );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.REMOVE_CUSTOMER_SAVED_PROFESSIONAL,
                SensitiveAuditTargetType.PROFESSIONAL_PROFILE,
                professionalIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));
        return CustomerProfileHttpResponse.fromUseCaseResponse(customerProfileResponse);
    }

    @PostMapping("/post-contact-feedback-requests/{contactIntentIdentifier}/dismiss")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void dismissPostContactFeedbackRequest(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @PathVariable UUID contactIntentIdentifier
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = resolveAndAuthorizeCustomer(authorizationHeader);
        dismissPostContactFeedbackRequestUseCase.dismissPostContactFeedbackRequest(
                authenticatedPrincipal.principalIdentifier(),
                contactIntentIdentifier
        );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.DISMISS_POST_CONTACT_FEEDBACK_REQUEST,
                SensitiveAuditTargetType.CONTACT_INTENTION,
                contactIntentIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));
    }

    private AuthenticatedPrincipal resolveAndAuthorizeCustomer(String authorizationHeader) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver
                .resolveAuthenticatedPrincipal(authorizationHeader);
        authorizeSensitiveActionUseCase.authorizeOwnedSensitiveAction(
                authenticatedPrincipal,
                SensitiveAction.ACCESS_PRIVATE_CUSTOMER_DATA,
                new AuthorizationOwnership(authenticatedPrincipal.principalIdentifier())
        );
        return authenticatedPrincipal;
    }
}
