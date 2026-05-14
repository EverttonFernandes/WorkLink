package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.ResourceNotFoundException;
import br.com.worklink.application.contact.port.DismissPostContactFeedbackRequestPort;

import java.util.UUID;

public class DismissPostContactFeedbackRequestUseCase {

    private final DismissPostContactFeedbackRequestPort dismissPostContactFeedbackRequestPort;

    public DismissPostContactFeedbackRequestUseCase(
            DismissPostContactFeedbackRequestPort dismissPostContactFeedbackRequestPort
    ) {
        this.dismissPostContactFeedbackRequestPort = dismissPostContactFeedbackRequestPort;
    }

    public void dismissPostContactFeedbackRequest(UUID customerIdentifier, UUID contactIntentIdentifier) {
        boolean dismissed = dismissPostContactFeedbackRequestPort.dismissPostContactFeedbackRequest(
                customerIdentifier,
                contactIntentIdentifier
        );
        if (!dismissed) {
            throw new ResourceNotFoundException("Solicitacao de feedback pendente nao encontrada.");
        }
    }
}
