package br.com.worklink.application.admin.port;

import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;



@FunctionalInterface
public interface ModerateReviewAnalysisRequestPort {

    Optional<ProfessionalReviewAnalysisRequest> moderateReviewAnalysisRequest(
            UUID reviewAnalysisRequestIdentifier,
            ModerationStatus moderationStatus,
            ModerationDecision moderationDecision,
            String moderationNotes,
            Instant decidedAt
    );
}
