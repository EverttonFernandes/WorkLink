package br.com.worklink.infrastructure.review;

import br.com.worklink.application.review.port.ListProfessionalReviewsByProfessionalIdentifierPort;
import br.com.worklink.application.review.port.ListProfessionalReviewsByInternalAuthorIdentifierPort;
import br.com.worklink.application.review.port.LoadProfessionalReviewByIdentifierPort;
import br.com.worklink.application.review.port.SaveProfessionalReviewAnalysisRequestPort;
import br.com.worklink.application.review.port.SaveProfessionalReviewPort;
import br.com.worklink.application.review.port.UpdateProfessionalReviewVisibilityPort;
import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;
import br.com.worklink.domain.review.ProfessionalReview;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcProfessionalReviewRepositoryAdapter implements
        SaveProfessionalReviewPort,
        ListProfessionalReviewsByProfessionalIdentifierPort,
        ListProfessionalReviewsByInternalAuthorIdentifierPort,
        LoadProfessionalReviewByIdentifierPort,
        SaveProfessionalReviewAnalysisRequestPort,
        UpdateProfessionalReviewVisibilityPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcProfessionalReviewRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ProfessionalReview saveProfessionalReview(ProfessionalReview professionalReview) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.professional_reviews (
                    professional_review_identifier,
                    contact_intent_identifier,
                    post_contact_feedback_identifier,
                    professional_identifier,
                    internal_author_identifier,
                    star_rating,
                    comment,
                    anonymous_to_public,
                    public_author_identifier,
                    public_author_display_name,
                    hidden_from_public,
                    created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                professionalReview.professionalReviewIdentifier(),
                professionalReview.contactIntentIdentifier(),
                professionalReview.postContactFeedbackIdentifier(),
                professionalReview.professionalIdentifier(),
                professionalReview.internalAuthorIdentifier(),
                professionalReview.starRating(),
                professionalReview.comment(),
                professionalReview.anonymousToPublic(),
                professionalReview.publicAuthorIdentifier(),
                professionalReview.publicAuthorDisplayName(),
                professionalReview.hiddenFromPublic(),
                Timestamp.from(professionalReview.createdAt())
        );
        return professionalReview;
    }

    @Override
    public List<ProfessionalReview> listProfessionalReviewsByProfessionalIdentifier(UUID professionalIdentifier) {
        return jdbcTemplate.query(
                professionalReviewSelectSql() + """
                WHERE professional_identifier = ?
                  AND hidden_from_public = FALSE
                ORDER BY created_at DESC
                """,
                (resultSet, rowNumber) -> mapProfessionalReview(resultSet),
                professionalIdentifier
        );
    }

    @Override
    public List<ProfessionalReview> listProfessionalReviewsByInternalAuthorIdentifier(UUID internalAuthorIdentifier) {
        return jdbcTemplate.query(
                professionalReviewSelectSql() + """
                WHERE internal_author_identifier = ?
                ORDER BY created_at DESC
                """,
                (resultSet, rowNumber) -> mapProfessionalReview(resultSet),
                internalAuthorIdentifier
        );
    }

    @Override
    public Optional<ProfessionalReview> loadProfessionalReviewByIdentifier(UUID professionalReviewIdentifier) {
        return jdbcTemplate.query(
                professionalReviewSelectSql() + """
                WHERE professional_review_identifier = ?
                """,
                (resultSet, rowNumber) -> mapProfessionalReview(resultSet),
                professionalReviewIdentifier
        ).stream().findFirst();
    }

    @Override
    public ProfessionalReviewAnalysisRequest saveProfessionalReviewAnalysisRequest(
            ProfessionalReviewAnalysisRequest professionalReviewAnalysisRequest
    ) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.professional_review_analysis_requests (
                    review_analysis_request_identifier,
                    professional_review_identifier,
                    professional_identifier,
                    requested_by_professional_identifier,
                    reason,
                    moderation_status,
                    moderation_decision,
                    moderation_notes,
                    decided_at,
                    created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                professionalReviewAnalysisRequest.reviewAnalysisRequestIdentifier(),
                professionalReviewAnalysisRequest.professionalReviewIdentifier(),
                professionalReviewAnalysisRequest.professionalIdentifier(),
                professionalReviewAnalysisRequest.requestedByProfessionalIdentifier(),
                professionalReviewAnalysisRequest.reason(),
                professionalReviewAnalysisRequest.moderationStatus().name(),
                professionalReviewAnalysisRequest.moderationDecision() == null
                        ? null
                        : professionalReviewAnalysisRequest.moderationDecision().name(),
                professionalReviewAnalysisRequest.moderationNotes(),
                professionalReviewAnalysisRequest.decidedAt() == null
                        ? null
                        : Timestamp.from(professionalReviewAnalysisRequest.decidedAt()),
                Timestamp.from(professionalReviewAnalysisRequest.createdAt())
        );
        return professionalReviewAnalysisRequest;
    }

    @Override
    public void updateProfessionalReviewVisibility(UUID professionalReviewIdentifier, boolean hiddenFromPublic) {
        jdbcTemplate.update(
                """
                UPDATE worklink.professional_reviews
                SET hidden_from_public = ?
                WHERE professional_review_identifier = ?
                """,
                hiddenFromPublic,
                professionalReviewIdentifier
        );
    }

    private String professionalReviewSelectSql() {
        return """
                SELECT professional_review_identifier,
                       contact_intent_identifier,
                       post_contact_feedback_identifier,
                       professional_identifier,
                       internal_author_identifier,
                       star_rating,
                       comment,
                       anonymous_to_public,
                       public_author_identifier,
                       public_author_display_name,
                       hidden_from_public,
                       created_at
                FROM worklink.professional_reviews
                """;
    }

    private ProfessionalReview mapProfessionalReview(java.sql.ResultSet resultSet) throws java.sql.SQLException {
        return ProfessionalReview.restoreProfessionalReview(
                resultSet.getObject("professional_review_identifier", UUID.class),
                resultSet.getObject("contact_intent_identifier", UUID.class),
                resultSet.getObject("post_contact_feedback_identifier", UUID.class),
                resultSet.getObject("professional_identifier", UUID.class),
                resultSet.getObject("internal_author_identifier", UUID.class),
                resultSet.getInt("star_rating"),
                resultSet.getString("comment"),
                resultSet.getBoolean("anonymous_to_public"),
                resultSet.getObject("public_author_identifier", UUID.class),
                resultSet.getString("public_author_display_name"),
                resultSet.getBoolean("hidden_from_public"),
                resultSet.getTimestamp("created_at").toInstant()
        );
    }
}
