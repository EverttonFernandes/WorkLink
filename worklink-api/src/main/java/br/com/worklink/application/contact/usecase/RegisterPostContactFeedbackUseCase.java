package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.contact.port.LoadContactIntentByIdentifierPort;
import br.com.worklink.application.contact.port.SavePostContactFeedbackPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.contact.ContactConversationOutcome;
import br.com.worklink.domain.contact.ContactIntent;
import br.com.worklink.domain.contact.ContactResponsiveness;
import br.com.worklink.domain.contact.PostContactFeedback;
import br.com.worklink.domain.contact.ServiceExecutionOutcome;

public class RegisterPostContactFeedbackUseCase {

    private final LoadContactIntentByIdentifierPort loadContactIntentByIdentifierPort;
    private final SavePostContactFeedbackPort savePostContactFeedbackPort;
    private final CurrentContactTimePort currentContactTimePort;

    public RegisterPostContactFeedbackUseCase(
            LoadContactIntentByIdentifierPort loadContactIntentByIdentifierPort,
            SavePostContactFeedbackPort savePostContactFeedbackPort,
            CurrentContactTimePort currentContactTimePort
    ) {
        this.loadContactIntentByIdentifierPort = loadContactIntentByIdentifierPort;
        this.savePostContactFeedbackPort = savePostContactFeedbackPort;
        this.currentContactTimePort = currentContactTimePort;
    }

    public RegisterPostContactFeedbackResponse registerPostContactFeedback(RegisterPostContactFeedbackRequest request) {
        AuthenticatedPrincipal authenticatedPrincipal = request.authenticatedPrincipal();
        requireCustomerPrincipal(authenticatedPrincipal);
        ContactIntent contactIntent = loadContactIntentByIdentifierPort
                .loadContactIntentByIdentifier(request.contactIntentIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException("A intencao de contato informada nao foi encontrada."));
        if (!contactIntent.customerIdentifier().equals(authenticatedPrincipal.principalIdentifier())) {
            throw new AuthorizationDeniedException("Apenas o cliente que iniciou o contato pode registrar feedback.");
        }

        try {
            PostContactFeedback postContactFeedback = PostContactFeedback.registerPostContactFeedback(
                    contactIntent.contactIntentIdentifier(),
                    contactIntent.customerIdentifier(),
                    ContactConversationOutcome.valueOf(request.conversationOutcome()),
                    ContactResponsiveness.valueOf(request.contactResponsiveness()),
                    ServiceExecutionOutcome.valueOf(request.serviceExecutionOutcome()),
                    currentContactTimePort.currentInstant()
            );
            PostContactFeedback savedPostContactFeedback = savePostContactFeedbackPort.savePostContactFeedback(postContactFeedback);
            return new RegisterPostContactFeedbackResponse(
                    savedPostContactFeedback.postContactFeedbackIdentifier(),
                    savedPostContactFeedback.contactIntentIdentifier(),
                    savedPostContactFeedback.conversationOutcome().name(),
                    savedPostContactFeedback.contactResponsiveness().name(),
                    savedPostContactFeedback.serviceExecutionOutcome().name(),
                    savedPostContactFeedback.createdAt()
            );
        } catch (BusinessRuleViolationException | IllegalArgumentException | NullPointerException exception) {
            throw new ApplicationRuleViolationException("As respostas do feedback pos-contato sao invalidas.", exception);
        }
    }

    private void requireCustomerPrincipal(AuthenticatedPrincipal authenticatedPrincipal) {
        if (authenticatedPrincipal == null || authenticatedPrincipal.profile() != AuthenticatedProfile.CUSTOMER) {
            throw new AuthorizationDeniedException("Apenas cliente autenticado pode registrar feedback pos-contato.");
        }
    }
}
