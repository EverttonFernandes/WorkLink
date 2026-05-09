package br.com.worklink.api.contact;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.contact.usecase.RegisterPostContactFeedbackRequest;
import br.com.worklink.application.contact.usecase.RegisterPostContactFeedbackResponse;
import br.com.worklink.application.contact.usecase.RegisterPostContactFeedbackUseCase;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/post-contact-feedbacks")
public class PostContactFeedbackController {

    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final RegisterPostContactFeedbackUseCase registerPostContactFeedbackUseCase;
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    public PostContactFeedbackController(
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            RegisterPostContactFeedbackUseCase registerPostContactFeedbackUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase
    ) {
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.registerPostContactFeedbackUseCase = registerPostContactFeedbackUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    RegisterPostContactFeedbackHttpResponse registerPostContactFeedback(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody RegisterPostContactFeedbackHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        RegisterPostContactFeedbackResponse response = registerPostContactFeedbackUseCase.registerPostContactFeedback(
                new RegisterPostContactFeedbackRequest(
                        authenticatedPrincipal,
                        request.contactIntentIdentifier(),
                        request.conversationOutcome(),
                        request.contactResponsiveness(),
                        request.serviceExecutionOutcome()
                )
        );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.REGISTER_POST_CONTACT_FEEDBACK,
                SensitiveAuditTargetType.CONTACT_INTENTION,
                response.contactIntentIdentifier(),
                SensitiveAuditOutcome.SUCCESS
        ));
        return RegisterPostContactFeedbackHttpResponse.fromUseCaseResponse(response);
    }
}
