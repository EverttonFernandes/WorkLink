package br.com.worklink.application.contact.port;

import br.com.worklink.domain.contact.PostContactFeedback;



@FunctionalInterface
public interface SavePostContactFeedbackPort {

    PostContactFeedback savePostContactFeedback(PostContactFeedback postContactFeedback);
}
