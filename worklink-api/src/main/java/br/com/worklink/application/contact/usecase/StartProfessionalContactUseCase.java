package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;
import br.com.worklink.application.contact.port.CreateWhatsappContactLinkPort;
import br.com.worklink.application.contact.port.CurrentContactTimePort;
import br.com.worklink.application.contact.port.SaveContactIntentPort;
import br.com.worklink.application.contact.port.SavePostContactFeedbackRequestPort;
import br.com.worklink.application.professional.port.LoadProfessionalByIdentifierPort;
import br.com.worklink.domain.BusinessRuleViolationException;
import br.com.worklink.domain.contact.ContactIntent;
import br.com.worklink.domain.professional.Professional;

public class StartProfessionalContactUseCase {

    private final LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort;
    private final SaveContactIntentPort saveContactIntentPort;
    private final SavePostContactFeedbackRequestPort savePostContactFeedbackRequestPort;
    private final CurrentContactTimePort currentContactTimePort;
    private final CreateWhatsappContactLinkPort createWhatsappContactLinkPort;

    public StartProfessionalContactUseCase(
            LoadProfessionalByIdentifierPort loadProfessionalByIdentifierPort,
            SaveContactIntentPort saveContactIntentPort,
            SavePostContactFeedbackRequestPort savePostContactFeedbackRequestPort,
            CurrentContactTimePort currentContactTimePort,
            CreateWhatsappContactLinkPort createWhatsappContactLinkPort
    ) {
        this.loadProfessionalByIdentifierPort = loadProfessionalByIdentifierPort;
        this.saveContactIntentPort = saveContactIntentPort;
        this.savePostContactFeedbackRequestPort = savePostContactFeedbackRequestPort;
        this.currentContactTimePort = currentContactTimePort;
        this.createWhatsappContactLinkPort = createWhatsappContactLinkPort;
    }

    public StartProfessionalContactResponse startProfessionalContact(StartProfessionalContactRequest request) {
        AuthenticatedPrincipal authenticatedPrincipal = request.authenticatedPrincipal();
        requireCustomerPrincipal(authenticatedPrincipal);
        Professional professional = loadProfessionalByIdentifierPort
                .loadProfessionalByIdentifier(request.professionalIdentifier())
                .orElseThrow(() -> new ApplicationRuleViolationException("O profissional informado nao foi encontrado."));

        try {
            ContactIntent contactIntent = ContactIntent.registerContactIntent(
                    authenticatedPrincipal.principalIdentifier(),
                    professional.professionalIdentifier(),
                    professional.whatsappNumber(),
                    currentContactTimePort.currentInstant()
            );
            ContactIntent savedContactIntent = saveContactIntentPort.saveContactIntent(contactIntent);
            savePostContactFeedbackRequestPort.savePendingPostContactFeedbackRequest(
                    savedContactIntent.customerIdentifier(),
                    savedContactIntent.contactIntentIdentifier(),
                    savedContactIntent.createdAt()
            );
            String whatsappContactLink = createWhatsappContactLinkPort.createWhatsappContactLink(
                    professional.whatsappNumber()
            );
            return new StartProfessionalContactResponse(
                    savedContactIntent.contactIntentIdentifier(),
                    professional.professionalIdentifier(),
                    professional.professionalName(),
                    whatsappContactLink,
                    savedContactIntent.createdAt()
            );
        } catch (BusinessRuleViolationException exception) {
            throw new ApplicationRuleViolationException(exception.getMessage(), exception);
        }
    }

    private void requireCustomerPrincipal(AuthenticatedPrincipal authenticatedPrincipal) {
        if (authenticatedPrincipal == null || authenticatedPrincipal.profile() != AuthenticatedProfile.CUSTOMER) {
            throw new AuthorizationDeniedException("Apenas cliente autenticado pode iniciar contato.");
        }
    }
}
