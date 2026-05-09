package br.com.worklink.infrastructure.review;

import br.com.worklink.application.review.port.SaveProfessionalReviewPort;
import br.com.worklink.domain.review.ProfessionalReview;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class JdbcProfessionalReviewRepositoryAdapter implements SaveProfessionalReviewPort {

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
                    created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
                professionalReview.createdAt()
        );
        return professionalReview;
    }
}
