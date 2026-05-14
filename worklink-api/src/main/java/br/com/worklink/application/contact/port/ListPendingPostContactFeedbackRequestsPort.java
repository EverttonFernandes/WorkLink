package br.com.worklink.application.contact.port;

import java.util.List;
import java.util.UUID;

public interface ListPendingPostContactFeedbackRequestsPort {

    List<PostContactFeedbackRequestProjection> listPendingPostContactFeedbackRequests(UUID customerIdentifier);
}
