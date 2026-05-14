package br.com.worklink.api.admin;

import br.com.worklink.api.authorization.AuthenticatedPrincipalHttpResolver;
import br.com.worklink.application.admin.usecase.BlockProfessionalUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeProfessionalReportsUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeProfessionalsUseCase;
import br.com.worklink.application.admin.usecase.ListAdministrativeReviewAnalysisRequestsUseCase;
import br.com.worklink.application.admin.usecase.LoadAdministrativeMetricsUseCase;
import br.com.worklink.application.admin.usecase.ModerateProfessionalReportRequest;
import br.com.worklink.application.admin.usecase.ModerateProfessionalReportUseCase;
import br.com.worklink.application.admin.usecase.ModerateReviewAnalysisRequest;
import br.com.worklink.application.admin.usecase.ModerateReviewAnalysisRequestUseCase;
import br.com.worklink.application.admin.usecase.UnblockProfessionalUseCase;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventRequest;
import br.com.worklink.application.audit.usecase.RecordSensitiveAuditEventUseCase;
import br.com.worklink.application.audit.usecase.SensitiveAuditAction;
import br.com.worklink.application.audit.usecase.SensitiveAuditOutcome;
import br.com.worklink.application.audit.usecase.SensitiveAuditTargetType;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthorizeSensitiveActionUseCase;
import br.com.worklink.application.authorization.usecase.SensitiveAction;
import br.com.worklink.application.metrics.usecase.LoadFunctionalMetricsUseCase;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/admin")
public class AdminController {

    private final AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver;
    private final AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase;
    private final RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase;
    private final ListAdministrativeProfessionalsUseCase listAdministrativeProfessionalsUseCase;
    private final BlockProfessionalUseCase blockProfessionalUseCase;
    private final UnblockProfessionalUseCase unblockProfessionalUseCase;
    private final ListAdministrativeProfessionalReportsUseCase listAdministrativeProfessionalReportsUseCase;
    private final ListAdministrativeReviewAnalysisRequestsUseCase listAdministrativeReviewAnalysisRequestsUseCase;
    private final ModerateProfessionalReportUseCase moderateProfessionalReportUseCase;
    private final ModerateReviewAnalysisRequestUseCase moderateReviewAnalysisRequestUseCase;
    private final LoadAdministrativeMetricsUseCase loadAdministrativeMetricsUseCase;
    private final LoadFunctionalMetricsUseCase loadFunctionalMetricsUseCase;

    public AdminController(
            AuthenticatedPrincipalHttpResolver authenticatedPrincipalHttpResolver,
            AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase,
            RecordSensitiveAuditEventUseCase recordSensitiveAuditEventUseCase,
            ListAdministrativeProfessionalsUseCase listAdministrativeProfessionalsUseCase,
            BlockProfessionalUseCase blockProfessionalUseCase,
            UnblockProfessionalUseCase unblockProfessionalUseCase,
            ListAdministrativeProfessionalReportsUseCase listAdministrativeProfessionalReportsUseCase,
            ListAdministrativeReviewAnalysisRequestsUseCase listAdministrativeReviewAnalysisRequestsUseCase,
            ModerateProfessionalReportUseCase moderateProfessionalReportUseCase,
            ModerateReviewAnalysisRequestUseCase moderateReviewAnalysisRequestUseCase,
            LoadAdministrativeMetricsUseCase loadAdministrativeMetricsUseCase,
            LoadFunctionalMetricsUseCase loadFunctionalMetricsUseCase
    ) {
        this.authenticatedPrincipalHttpResolver = authenticatedPrincipalHttpResolver;
        this.authorizeSensitiveActionUseCase = authorizeSensitiveActionUseCase;
        this.recordSensitiveAuditEventUseCase = recordSensitiveAuditEventUseCase;
        this.listAdministrativeProfessionalsUseCase = listAdministrativeProfessionalsUseCase;
        this.blockProfessionalUseCase = blockProfessionalUseCase;
        this.unblockProfessionalUseCase = unblockProfessionalUseCase;
        this.listAdministrativeProfessionalReportsUseCase = listAdministrativeProfessionalReportsUseCase;
        this.listAdministrativeReviewAnalysisRequestsUseCase = listAdministrativeReviewAnalysisRequestsUseCase;
        this.moderateProfessionalReportUseCase = moderateProfessionalReportUseCase;
        this.moderateReviewAnalysisRequestUseCase = moderateReviewAnalysisRequestUseCase;
        this.loadAdministrativeMetricsUseCase = loadAdministrativeMetricsUseCase;
        this.loadFunctionalMetricsUseCase = loadFunctionalMetricsUseCase;
    }

    @GetMapping("/professionals")
    List<AdministrativeProfessionalHttpResponse> listAdministrativeProfessionals(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.ACCESS_ADMINISTRATIVE_DATA
        );
        auditAdministrativeAccess(authenticatedPrincipal, SensitiveAuditTargetType.PROFESSIONAL_PROFILE);
        return listAdministrativeProfessionalsUseCase.listAdministrativeProfessionals().stream()
                .map(AdministrativeProfessionalHttpResponse::fromResponse)
                .toList();
    }

    @PostMapping("/professionals/{professionalIdentifier}/block")
    AdministrativeProfessionalHttpResponse blockProfessional(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @PathVariable UUID professionalIdentifier
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.BLOCK_PROFESSIONAL
        );
        AdministrativeProfessionalHttpResponse response = AdministrativeProfessionalHttpResponse.fromResponse(
                blockProfessionalUseCase.blockProfessional(professionalIdentifier)
        );
        auditProfessionalModeration(
                authenticatedPrincipal,
                SensitiveAuditAction.BLOCK_PROFESSIONAL,
                professionalIdentifier
        );
        return response;
    }

    @PostMapping("/professionals/{professionalIdentifier}/unblock")
    AdministrativeProfessionalHttpResponse unblockProfessional(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @PathVariable UUID professionalIdentifier
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.UNBLOCK_PROFESSIONAL
        );
        AdministrativeProfessionalHttpResponse response = AdministrativeProfessionalHttpResponse.fromResponse(
                unblockProfessionalUseCase.unblockProfessional(professionalIdentifier)
        );
        auditProfessionalModeration(
                authenticatedPrincipal,
                SensitiveAuditAction.UNBLOCK_PROFESSIONAL,
                professionalIdentifier
        );
        return response;
    }

    @GetMapping("/reports")
    List<AdministrativeProfessionalReportHttpResponse> listAdministrativeProfessionalReports(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.ACCESS_THIRD_PARTY_REPORT
        );
        auditAdministrativeAccess(authenticatedPrincipal, SensitiveAuditTargetType.REPORT);
        return listAdministrativeProfessionalReportsUseCase.listAdministrativeProfessionalReports().stream()
                .map(AdministrativeProfessionalReportHttpResponse::fromResponse)
                .toList();
    }

    @PostMapping("/reports/{professionalReportIdentifier}/moderation")
    AdministrativeProfessionalReportHttpResponse moderateProfessionalReport(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @PathVariable UUID professionalReportIdentifier,
            @RequestBody ModerateProfessionalReportHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.ACCESS_THIRD_PARTY_REPORT
        );
        AdministrativeProfessionalReportHttpResponse response = AdministrativeProfessionalReportHttpResponse.fromResponse(
                moderateProfessionalReportUseCase.moderateProfessionalReport(new ModerateProfessionalReportRequest(
                        professionalReportIdentifier,
                        request.moderationStatus(),
                        request.moderationDecision(),
                        request.moderationNotes()
                ))
        );
        auditAdministrativeModeration(
                authenticatedPrincipal,
                SensitiveAuditAction.MODERATE_PROFESSIONAL_REPORT,
                professionalReportIdentifier,
                SensitiveAuditTargetType.REPORT
        );
        return response;
    }

    @GetMapping("/review-analysis-requests")
    List<AdministrativeReviewAnalysisRequestHttpResponse> listAdministrativeReviewAnalysisRequests(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.ACCESS_ADMINISTRATIVE_DATA
        );
        auditAdministrativeAccess(authenticatedPrincipal, SensitiveAuditTargetType.REVIEW);
        return listAdministrativeReviewAnalysisRequestsUseCase.listAdministrativeReviewAnalysisRequests().stream()
                .map(AdministrativeReviewAnalysisRequestHttpResponse::fromResponse)
                .toList();
    }

    @PostMapping("/review-analysis-requests/{reviewAnalysisRequestIdentifier}/moderation")
    AdministrativeReviewAnalysisRequestHttpResponse moderateReviewAnalysisRequest(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @PathVariable UUID reviewAnalysisRequestIdentifier,
            @RequestBody ModerateReviewAnalysisRequestHttpRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.ACCESS_ADMINISTRATIVE_DATA
        );
        AdministrativeReviewAnalysisRequestHttpResponse response =
                AdministrativeReviewAnalysisRequestHttpResponse.fromResponse(
                        moderateReviewAnalysisRequestUseCase.moderateReviewAnalysisRequest(
                                new ModerateReviewAnalysisRequest(
                                        reviewAnalysisRequestIdentifier,
                                        request.moderationStatus(),
                                        request.moderationDecision(),
                                        request.moderationNotes()
                                )
                        )
                );
        auditAdministrativeModeration(
                authenticatedPrincipal,
                SensitiveAuditAction.MODERATE_REVIEW_ANALYSIS_REQUEST,
                reviewAnalysisRequestIdentifier,
                SensitiveAuditTargetType.REVIEW
        );
        return response;
    }

    @GetMapping("/metrics")
    AdministrativeMetricsHttpResponse loadAdministrativeMetrics(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.ACCESS_ADMINISTRATIVE_DATA
        );
        auditAdministrativeAccess(authenticatedPrincipal, SensitiveAuditTargetType.ADMINISTRATIVE_SESSION);
        return AdministrativeMetricsHttpResponse.fromResponse(loadAdministrativeMetricsUseCase.loadAdministrativeMetrics());
    }

    @GetMapping("/functional-metrics")
    FunctionalMetricsHttpResponse loadFunctionalMetrics(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = authorizeAdministrator(
                authorizationHeader,
                SensitiveAction.ACCESS_ADMINISTRATIVE_DATA
        );
        auditAdministrativeAccess(authenticatedPrincipal, SensitiveAuditTargetType.ADMINISTRATIVE_SESSION);
        return FunctionalMetricsHttpResponse.fromResponse(loadFunctionalMetricsUseCase.loadFunctionalMetrics());
    }

    private AuthenticatedPrincipal authorizeAdministrator(String authorizationHeader, SensitiveAction sensitiveAction) {
        AuthenticatedPrincipal authenticatedPrincipal = authenticatedPrincipalHttpResolver.resolveAuthenticatedPrincipal(
                authorizationHeader
        );
        authorizeSensitiveActionUseCase.authorizeSensitiveAction(authenticatedPrincipal, sensitiveAction);
        return authenticatedPrincipal;
    }

    private void auditAdministrativeAccess(
            AuthenticatedPrincipal authenticatedPrincipal,
            SensitiveAuditTargetType sensitiveAuditTargetType
    ) {
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                SensitiveAuditAction.ACCESS_ADMINISTRATIVE_DATA,
                sensitiveAuditTargetType,
                authenticatedPrincipal.principalIdentifier(),
                SensitiveAuditOutcome.SUCCESS
        ));
    }

    private void auditProfessionalModeration(
            AuthenticatedPrincipal authenticatedPrincipal,
            SensitiveAuditAction sensitiveAuditAction,
            UUID professionalIdentifier
    ) {
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                sensitiveAuditAction,
                SensitiveAuditTargetType.PROFESSIONAL_PROFILE,
                professionalIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));
    }

    private void auditAdministrativeModeration(
            AuthenticatedPrincipal authenticatedPrincipal,
            SensitiveAuditAction sensitiveAuditAction,
            UUID targetIdentifier,
            SensitiveAuditTargetType sensitiveAuditTargetType
    ) {
        recordSensitiveAuditEventUseCase.recordSensitiveAuditEvent(new RecordSensitiveAuditEventRequest(
                authenticatedPrincipal,
                sensitiveAuditAction,
                sensitiveAuditTargetType,
                targetIdentifier,
                SensitiveAuditOutcome.SUCCESS
        ));
    }
}
