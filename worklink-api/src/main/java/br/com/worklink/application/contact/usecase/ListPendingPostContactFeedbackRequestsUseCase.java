package br.com.worklink.application.contact.usecase;

import br.com.worklink.application.contact.port.ListPendingPostContactFeedbackRequestsPort;
import br.com.worklink.application.contact.port.PostContactFeedbackRequestProjection;

import java.util.List;
import java.util.UUID;

public class ListPendingPostContactFeedbackRequestsUseCase {

    private final ListPendingPostContactFeedbackRequestsPort listPendingPostContactFeedbackRequestsPort;

    public ListPendingPostContactFeedbackRequestsUseCase(
            ListPendingPostContactFeedbackRequestsPort listPendingPostContactFeedbackRequestsPort
    ) {
        this.listPendingPostContactFeedbackRequestsPort = listPendingPostContactFeedbackRequestsPort;
    }

    public List<PendingPostContactFeedbackRequestResponse> listPendingPostContactFeedbackRequests(UUID customerIdentifier) {
        return listPendingPostContactFeedbackRequestsPort.listPendingPostContactFeedbackRequests(customerIdentifier)
                .stream()
                .map(this::mapResponse)
                .toList();
    }

    private PendingPostContactFeedbackRequestResponse mapResponse(
            PostContactFeedbackRequestProjection projection
    ) {
        return new PendingPostContactFeedbackRequestResponse(
                projection.contactIntentIdentifier(),
                projection.professionalIdentifier(),
                projection.professionalName(),
                projection.contactCreatedAt()
        );
    }
}
