package br.com.worklink.application.review.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.contact.port.LoadContactIntentByIdentifierPort;
import br.com.worklink.application.privacy.usecase.ReviewAuthorPrivacyProjection;
import br.com.worklink.application.review.port.LoadPostContactFeedbackByContactIntentIdentifierPort;
import br.com.worklink.application.review.port.SaveProfessionalReviewPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.contact.ContactIntent;
import br.com.worklink.domain.contact.PostContactFeedback;
import br.com.worklink.domain.contact.ServiceExecutionOutcome;
import br.com.worklink.domain.review.ProfessionalReview;

public class RegisterProfessionalReviewUseCase {

    private static final String IDENTIFIED_REVIEW_AUTHOR_DISPLAY_NAME = "Cliente WorkLink";

    private final LoadContactIntentByIdentifierPort loadContactIntentByIdentifierPort;
    private final LoadPostContactFeedbackByContactIntentIdentifierPort loadPostContactFeedbackByContactIntentIdentifierPort;
    private final SaveProfessionalReviewPort saveProfessionalReviewPort;
    private final CurrentContactTimePort currentContactTimePort;

    public RegisterProfessionalReviewUseCase(
            LoadContactIntentByIdentifierPort loadContactIntentByIdentifierPort,
            LoadPostContactFeedbackByContactIntentIdentifierPort loadPostContactFeedbackByContactIntentIdentifierPort,
            SaveProfessionalReviewPort saveProfessionalReviewPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        this.loadContactIntentByIdentifierPort = loadContactIntentByIdentifierPort;
        this.loadPostContactFeedbackByContactIntentIdentifierPort = loadPostContactFeedbackByContactIntentIdentifierPort;
        this.saveProfessionalReviewPort = saveProfessionalReviewPort;
        this.currentContactTimePort = currentContactTimePort;
    }

    public RegisterProfessionalReviewResponse registerProfessionalReview(RegisterProfessionalReviewRequest request) {
        AuthenticatedPrincipal authenticatedPrincipal = request.authenticatedPrincipal();
        requireCustomerPrincipal(authenticatedPrincipal);
        ContactIntent contactIntent = loadContactIntentByIdentifierPort
                .loadContactIntentByIdentifier(request.contactIntentIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException("A intencao de contato informada nao foi encontrada."));
        if (!contactIntent.customerIdentifier().equals(authenticatedPrincipal.principalIdentifier())) {
            throw new AuthorizationDeniedException("Apenas o cliente que iniciou o contato pode avaliar o profissional.");
        }
        PostContactFeedback postContactFeedback = loadPostContactFeedbackByContactIntentIdentifierPort
                .loadPostContactFeedbackByContactIntentIdentifier(contactIntent.contactIntentIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException("A avaliacao exige feedback pos-contato registrado."));
        if (postContactFeedback.serviceExecutionOutcome() != ServiceExecutionOutcome.SERVICE_PERFORMED) {
            throw new ApplicationRuleViolationException("A avaliacao exige servico realizado.");
        }

        try {
            ReviewAuthorPrivacyProjection privacyProjection = ReviewAuthorPrivacyProjection.fromReviewAuthor(
                    authenticatedPrincipal.principalIdentifier(),
                    request.anonymousToPublic() ? null : authenticatedPrincipal.principalIdentifier(),
                    request.anonymousToPublic() ? null : IDENTIFIED_REVIEW_AUTHOR_DISPLAY_NAME,
                    request.anonymousToPublic()
            );
            ProfessionalReview professionalReview = ProfessionalReview.registerProfessionalReview(
                    contactIntent.contactIntentIdentifier(),
                    postContactFeedback.postContactFeedbackIdentifier(),
                    contactIntent.professionalIdentifier(),
                    authenticatedPrincipal.principalIdentifier(),
                    request.starRating(),
                    request.comment(),
                    privacyProjection.anonymousToPublic(),
                    privacyProjection.publicAuthorIdentifier(),
                    privacyProjection.publicAuthorDisplayName(),
                    currentContactTimePort.currentInstant()
            );
            return responseFromReview(saveProfessionalReviewPort.saveProfessionalReview(professionalReview));
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException("A avaliacao profissional informada e invalida.", exception);
        }
    }

    private RegisterProfessionalReviewResponse responseFromReview(ProfessionalReview professionalReview) {
        return new RegisterProfessionalReviewResponse(
                professionalReview.professionalReviewIdentifier(),
                professionalReview.contactIntentIdentifier(),
                professionalReview.professionalIdentifier(),
                professionalReview.starRating(),
                professionalReview.comment(),
                professionalReview.anonymousToPublic(),
                professionalReview.publicAuthorIdentifier(),
                professionalReview.publicAuthorDisplayName(),
                professionalReview.createdAt()
        );
    }

    private void requireCustomerPrincipal(AuthenticatedPrincipal authenticatedPrincipal) {
        if (authenticatedPrincipal == null || authenticatedPrincipal.profile() != AuthenticatedProfile.CUSTOMER) {
            throw new AuthorizationDeniedException("Apenas cliente autenticado pode avaliar profissional.");
        }
    }
}
