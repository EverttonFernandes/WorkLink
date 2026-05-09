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
import br.com.worklink.application.metrics.usecase.RecordProfessionalSearchEventRequest;
import br.com.worklink.application.metrics.usecase.RecordProfessionalSearchEventUseCase;
import br.com.worklink.application.observability.usecase.OperationalEvent;
import br.com.worklink.application.observability.usecase.OperationalEventSeverity;
import br.com.worklink.application.observability.usecase.OperationalEventType;
import br.com.worklink.application.observability.usecase.RecordOperationalEventUseCase;
import br.com.worklink.application.professional.usecase.CompleteProfessionalProfileRequest;
import br.com.worklink.application.professional.usecase.CompleteProfessionalProfileUseCase;
import br.com.worklink.application.professional.port.ProfessionalSearchCriteria;
import br.com.worklink.application.professional.usecase.ListProfessionalsUseCase;
import br.com.worklink.application.professional.usecase.ProfessionalResponse;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalRequest;
import br.com.worklink.application.professional.usecase.RegisterBasicProfessionalUseCase;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/professionals")
public class ProfessionalController {

    private final RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase;
    private final ListProfessionalsUseCase listProfessionalsUseCase;
    private final CompleteProfessionalProfileUseCase completeProfessionalProfileUseCase;
    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;
    private final RecordProfessionalSearchEventUseCase recordProfessionalSearchEventUseCase;
    private final RecordOperationalEventUseCase recordOperationalEventUseCase;

    public ProfessionalController(
            RegisterBasicProfessionalUseCase registerBasicProfessionalUseCase,
            ListProfessionalsUseCase listProfessionalsUseCase,
            CompleteProfessionalProfileUseCase completeProfessionalProfileUseCase,
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase,
            RecordProfessionalSearchEventUseCase recordProfessionalSearchEventUseCase,
            RecordOperationalEventUseCase recordOperationalEventUseCase
    ) {
        this.registerBasicProfessionalUseCase = registerBasicProfessionalUseCase;
        this.listProfessionalsUseCase = listProfessionalsUseCase;
        this.completeProfessionalProfileUseCase = completeProfessionalProfileUseCase;
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.authorizeSensitiveActionUseCase = authorizeSensitiveActionUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
        this.recordProfessionalSearchEventUseCase = recordProfessionalSearchEventUseCase;
        this.recordOperationalEventUseCase = recordOperationalEventUseCase;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    ProfessionalHttpResponse registerBasicProfessional(@RequestBody RegisterBasicProfessionalHttpRequest request) {
        ProfessionalResponse professionalResponse = registerBasicProfessionalUseCase.registerBasicProfessional(
                new RegisterBasicProfessionalRequest(
                        request.professionalName(),
                        request.whatsappNumber(),
                        request.cityIdentifier(),
                        request.categoryIdentifier(),
                        request.shortDescription()
                )
        );
        return ProfessionalHttpResponse.fromProfessionalResponse(professionalResponse);
    }

    @GetMapping
    List<ProfessionalHttpResponse> listProfessionals(
            @RequestParam(required = false) UUID categoryIdentifier,
            @RequestParam(required = false) UUID cityIdentifier,
            @RequestParam(required = false) List<UUID> cityIdentifiers,
            @RequestParam(required = false) String keyword
    ) {
        ProfessionalSearchCriteria professionalSearchCriteria = new ProfessionalSearchCriteria(
                Optional.ofNullable(categoryIdentifier),
                selectedCityIdentifiers(cityIdentifier, cityIdentifiers),
                Optional.ofNullable(keyword)
        );
        List<ProfessionalHttpResponse> professionalResponses = listProfessionalsUseCase
                .listProfessionals(professionalSearchCriteria)
                .stream()
                .map(ProfessionalHttpResponse::fromProfessionalResponse)
                .toList();
        recordProfessionalSearch(professionalSearchCriteria, professionalResponses.size());
        return professionalResponses;
    }

    @PatchMapping("/{professionalIdentifier}/profile")
    ProfessionalHttpResponse completeProfessionalProfile(
            @PathVariable UUID professionalIdentifier,
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @RequestBody CompleteProfessionalProfileHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        authorizeSensitiveActionUseCase.authorizeOwnedSensitiveAction(
                authenticatedPrincipal,
                SensitiveAction.COMPLETE_PROFESSIONAL_PROFILE,
                new AuthorizationOwnership(professionalIdentifier)
        );
        ProfessionalResponse professionalResponse = completeProfessionalProfileUseCase.completeProfessionalProfile(
                new CompleteProfessionalProfileRequest(
                        professionalIdentifier,
                        request.profilePhotoFileIdentifier(),
                        request.documentNumber(),
                        request.usefulLink(),
                        request.portfolioDescription(),
                        request.serviceDescription(),
                        request.availabilityStatus()
                )
        );
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.COMPLETE_PROFESSIONAL_PROFILE,
                SensitiveAuditTargetType.PROFESSIONAL_PROFILE,
                professionalIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));
        return ProfessionalHttpResponse.fromProfessionalResponse(professionalResponse);
    }

    private Set<UUID> selectedCityIdentifiers(UUID cityIdentifier, List<UUID> cityIdentifiers) {
        Set<UUID> selectedCityIdentifiers = new LinkedHashSet<>();
        if (cityIdentifier != null) {
            selectedCityIdentifiers.add(cityIdentifier);
        }
        if (cityIdentifiers != null) {
            selectedCityIdentifiers.addAll(cityIdentifiers);
        }
        return selectedCityIdentifiers;
    }

    private void recordProfessionalSearch(ProfessionalSearchCriteria professionalSearchCriteria, int resultCount) {
        recordProfessionalSearchEventUseCase.recordProfessionalSearchEvent(new RecordProfessionalSearchEventRequest(
                professionalSearchCriteria.categoryIdentifier().orElse(null),
                professionalSearchCriteria.cityIdentifiers(),
                professionalSearchCriteria.keyword().orElse(null),
                resultCount
        ));
        recordOperationalEventUseCase.recordOperationalEvent(new OperationalEvent(
                OperationalEventType.FUNCTIONAL_METRIC_FLOW,
                OperationalEventSeverity.INFO,
                "Busca de profissionais registrada para metricas funcionais.",
                Map.of(
                        "resultCount", Integer.toString(resultCount),
                        "cityFilterCount", Integer.toString(professionalSearchCriteria.cityIdentifiers().size())
                )
        ));
    }
}
