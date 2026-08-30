package br.com.worklink.api.professional;

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
import br.com.worklink.application.professional.usecase.AddProfessionalPortfolioItemRequest;
import br.com.worklink.application.professional.usecase.AddProfessionalPortfolioItemUseCase;
import br.com.worklink.application.professional.usecase.ListProfessionalPortfolioItemsUseCase;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/professionals/{professionalIdentifier}/portfolio-items")
public class ProfessionalPortfolioController {

    private final AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase;
    private final ListProfessionalPortfolioItemsUseCase listProfessionalPortfolioItemsUseCase;
    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;

    public ProfessionalPortfolioController(
            AddProfessionalPortfolioItemUseCase addProfessionalPortfolioItemUseCase,
            ListProfessionalPortfolioItemsUseCase listProfessionalPortfolioItemsUseCase,
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase
    ) {
        this.addProfessionalPortfolioItemUseCase = addProfessionalPortfolioItemUseCase;
        this.listProfessionalPortfolioItemsUseCase = listProfessionalPortfolioItemsUseCase;
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.authorizeSensitiveActionUseCase = authorizeSensitiveActionUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
    }

    @GetMapping
    List<ProfessionalPortfolioItemHttpResponse> listProfessionalPortfolioItems(
            @PathVariable UUID professionalIdentifier,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(authorizationHeader);
        return listProfessionalPortfolioItemsUseCase.listProfessionalPortfolioItems(professionalIdentifier)
                .stream()
                .map(ProfessionalPortfolioItemHttpResponse::fromResponse)
                .toList();
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ProfessionalPortfolioItemHttpResponse addProfessionalPortfolioItem(
            @PathVariable UUID professionalIdentifier,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody AddProfessionalPortfolioItemHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        authorizeSensitiveActionUseCase.authorizeOwnedSensitiveAction(
                authenticatedPrincipal,
                SensitiveAction.MANAGE_PROFESSIONAL_PORTFOLIO,
                new AuthorizationOwnership(professionalIdentifier)
        );
        ProfessionalPortfolioItemHttpResponse response = ProfessionalPortfolioItemHttpResponse.fromResponse(
                addProfessionalPortfolioItemUseCase.addProfessionalPortfolioItem(
                        new AddProfessionalPortfolioItemRequest(
                                professionalIdentifier,
                                request.fileIdentifier(),
                                request.title(),
                                request.description(),
                                request.displayOrder()
                        )
                )
        );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.ADD_PROFESSIONAL_PORTFOLIO_ITEM,
                SensitiveAuditTargetType.PROFESSIONAL_PROFILE,
                professionalIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));
        return response;
    }
}
