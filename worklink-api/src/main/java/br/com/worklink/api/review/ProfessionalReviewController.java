package br.com.worklink.api.review;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.review.usecase.RegisterProfessionalReviewRequest;
import br.com.worklink.application.review.usecase.RegisterProfessionalReviewResponse;
import br.com.worklink.application.review.usecase.RegisterProfessionalReviewUseCase;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/professional-reviews")
public class ProfessionalReviewController {

    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final RegisterProfessionalReviewUseCase registerProfessionalReviewUseCase;
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    public ProfessionalReviewController(
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            RegisterProfessionalReviewUseCase registerProfessionalReviewUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase
    ) {
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.registerProfessionalReviewUseCase = registerProfessionalReviewUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    RegisterProfessionalReviewHttpResponse registerProfessionalReview(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody RegisterProfessionalReviewHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        RegisterProfessionalReviewResponse response = registerProfessionalReviewUseCase.registerProfessionalReview(
                new RegisterProfessionalReviewRequest(
                        authenticatedPrincipal,
                        request.contactIntentIdentifier(),
                        request.starRating(),
                        request.comment(),
                        request.anonymousToPublic()
                )
        );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.REGISTER_ANONYMOUS_REVIEW,
                SensitiveAuditTargetType.REVIEW,
                response.professionalReviewIdentifier(),
                SensitiveAuditOutcome.SUCCESS
        ));
        return RegisterProfessionalReviewHttpResponse.fromUseCaseResponse(response);
    }
}
