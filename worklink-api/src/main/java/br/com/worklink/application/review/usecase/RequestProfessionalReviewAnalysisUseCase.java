package br.com.worklink.application.review.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.review.port.LoadProfessionalReviewByIdentifierPort;
import br.com.worklink.application.review.port.SaveProfessionalReviewAnalysisRequestPort;
import br.com.worklink.domain.review.ProfessionalReview;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

public class RequestProfessionalReviewAnalysisUseCase {

    private final LoadProfessionalReviewByIdentifierPort loadProfessionalReviewByIdentifierPort;
    private final SaveProfessionalReviewAnalysisRequestPort saveProfessionalReviewAnalysisRequestPort;
    private final CurrentContactTimePort currentContactTimePort;

    public RequestProfessionalReviewAnalysisUseCase(
            LoadProfessionalReviewByIdentifierPort loadProfessionalReviewByIdentifierPort,
            SaveProfessionalReviewAnalysisRequestPort saveProfessionalReviewAnalysisRequestPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        this.loadProfessionalReviewByIdentifierPort = loadProfessionalReviewByIdentifierPort;
        this.saveProfessionalReviewAnalysisRequestPort = saveProfessionalReviewAnalysisRequestPort;
        this.currentContactTimePort = currentContactTimePort;
    }

    public RequestProfessionalReviewAnalysisResponse requestProfessionalReviewAnalysis(
            RequestProfessionalReviewAnalysisRequest request
    ) {
        AuthenticatedPrincipal authenticatedPrincipal = requireProfessionalPrincipal(request.authenticatedPrincipal());
        ProfessionalReview professionalReview = loadProfessionalReviewByIdentifierPort
                .loadProfessionalReviewByIdentifier(request.professionalReviewIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException("A avaliacao solicitada para analise nao existe."));
        if (!professionalReview.professionalIdentifier().equals(authenticatedPrincipal.principalIdentifier())) {
            throw new AuthorizationDeniedException("Apenas o profissional avaliado pode solicitar analise da avaliacao.");
        }
        ProfessionalReviewAnalysisRequest analysisRequest = ProfessionalReviewAnalysisRequest
                .requestProfessionalReviewAnalysis(
                        professionalReview.professionalReviewIdentifier(),
                        professionalReview.professionalIdentifier(),
                        authenticatedPrincipal.principalIdentifier(),
                        request.reason(),
                        currentContactTimePort.currentInstant()
                );
        return RequestProfessionalReviewAnalysisResponse.fromAnalysisRequest(
                saveProfessionalReviewAnalysisRequestPort.saveProfessionalReviewAnalysisRequest(analysisRequest)
        );
    }

    private AuthenticatedPrincipal requireProfessionalPrincipal(AuthenticatedPrincipal authenticatedPrincipal) {
        if (authenticatedPrincipal == null || authenticatedPrincipal.profile() != AuthenticatedProfile.PROFESSIONAL) {
            throw new AuthorizationDeniedException("Apenas profissional autenticado pode solicitar analise da avaliacao.");
        }
        return authenticatedPrincipal;
    }
}
