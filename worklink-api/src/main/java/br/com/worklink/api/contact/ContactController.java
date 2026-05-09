package br.com.worklink.api.contact;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.contact.usecase.StartProfessionalContactRequest;
import br.com.worklink.application.contact.usecase.StartProfessionalContactResponse;
import br.com.worklink.application.contact.usecase.StartProfessionalContactUseCase;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/contact-intentions")
public class ContactController {

    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final StartProfessionalContactUseCase startProfessionalContactUseCase;
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    public ContactController(
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            StartProfessionalContactUseCase startProfessionalContactUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase
    ) {
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.startProfessionalContactUseCase = startProfessionalContactUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    StartProfessionalContactHttpResponse startProfessionalContact(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody StartProfessionalContactHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        StartProfessionalContactResponse startProfessionalContactResponse =
                startProfessionalContactUseCase.startProfessionalContact(new StartProfessionalContactRequest(
                        authenticatedPrincipal,
                        request.professionalIdentifier()
                ));
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.REGISTER_CONTACT_INTENTION,
                SensitiveAuditTargetType.CONTACT_INTENTION,
                startProfessionalContactResponse.contactIntentIdentifier(),
                SensitiveAuditOutcome.SUCCESS
        ));
        return StartProfessionalContactHttpResponse.fromUseCaseResponse(startProfessionalContactResponse);
    }
}
