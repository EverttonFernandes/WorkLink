package br.com.worklink.application.contact.port;

import java.util.List;
import java.util.UUID;



@FunctionalInterface
public interface ListPendingPostContactFeedbackRequestsPort {

    List<PostContactFeedbackRequestProjection> listPendingPostContactFeedbackRequests(UUID customerIdentifier);
}
