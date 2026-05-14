package br.com.worklink.infrastructure.admin;

import br.com.worklink.application.admin.port.ListAdministrativeProfessionalReportsPort;
import br.com.worklink.application.admin.port.ListAdministrativeProfessionalsPort;
import br.com.worklink.application.admin.port.ListAdministrativeReviewAnalysisRequestsPort;
import br.com.worklink.application.admin.port.LoadAdministrativeMetricsPort;
import br.com.worklink.application.admin.port.ModerateProfessionalReportPort;
import br.com.worklink.application.admin.port.ModerateReviewAnalysisRequestPort;
import br.com.worklink.domain.moderation.ModerationDecision;
import br.com.worklink.domain.moderation.ModerationStatus;
import br.com.worklink.domain.professional.Professional;
import br.com.worklink.domain.professional.ProfessionalAvailabilityStatus;
import br.com.worklink.domain.professional.ProfessionalProfileClassification;
import br.com.worklink.domain.report.ProfessionalReport;
import br.com.worklink.domain.report.ProfessionalReportReason;
import br.com.worklink.domain.review.ProfessionalReviewAnalysisRequest;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcAdministrativeRepositoryAdapter implements
        ListAdministrativeProfessionalsPort,
        ListAdministrativeProfessionalReportsPort,
        ListAdministrativeReviewAnalysisRequestsPort,
        ModerateProfessionalReportPort,
        ModerateReviewAnalysisRequestPort,
        LoadAdministrativeMetricsPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcAdministrativeRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Professional> listAdministrativeProfessionals() {
        return jdbcTemplate.query(
                """
                SELECT professional_identifier,
                       professional_name,
                       whatsapp_number,
                       city_identifier,
                       category_identifier,
                       short_description,
                       profile_photo_file_identifier,
                       document_number_hash,
                       useful_link,
                       portfolio_description,
                       service_description,
                       profile_completeness_percentage,
                       profile_classification,
                       availability_status,
                       phone_number_verified,
                       quality_guarantee,
                       blocked
                FROM worklink.professionals
                ORDER BY professional_name ASC
                """,
                (resultSet, rowNumber) -> mapProfessional(resultSet)
        );
    }

    @Override
    public List<ProfessionalReport> listAdministrativeProfessionalReports() {
        return jdbcTemplate.query(
                """
                SELECT professional_report_identifier,
                       professional_identifier,
                       reporter_identifier,
                       report_reason,
                       description,
                       evidence_file_identifier,
                       serious_case,
                       authority_guidance,
                       moderation_status,
                       moderation_decision,
                       moderation_notes,
                       decided_at,
                       created_at
                FROM worklink.professional_reports
                ORDER BY serious_case DESC, created_at DESC
                """,
                (resultSet, rowNumber) -> ProfessionalReport.restoreProfessionalReport(
                        resultSet.getObject("professional_report_identifier", UUID.class),
                        resultSet.getObject("professional_identifier", UUID.class),
                        resultSet.getObject("reporter_identifier", UUID.class),
                        ProfessionalReportReason.valueOf(resultSet.getString("report_reason")),
                        resultSet.getString("description"),
                        resultSet.getObject("evidence_file_identifier", UUID.class),
                        resultSet.getBoolean("serious_case"),
                        resultSet.getString("authority_guidance"),
                        ModerationStatus.valueOf(resultSet.getString("moderation_status")),
                        nullableModerationDecision(resultSet.getString("moderation_decision")),
                        resultSet.getString("moderation_notes"),
                        nullableInstant(resultSet, "decided_at"),
                        resultSet.getTimestamp("created_at").toInstant()
                )
        );
    }

    @Override
    public List<ProfessionalReviewAnalysisRequest> listAdministrativeReviewAnalysisRequests() {
        return jdbcTemplate.query(
                """
                SELECT review_analysis_request_identifier,
                       professional_review_identifier,
                       professional_identifier,
                       requested_by_professional_identifier,
                       reason,
                       moderation_status,
                       moderation_decision,
                       moderation_notes,
                       decided_at,
                       created_at
                FROM worklink.professional_review_analysis_requests
                ORDER BY created_at DESC
                """,
                (resultSet, rowNumber) -> ProfessionalReviewAnalysisRequest.restoreProfessionalReviewAnalysisRequest(
                        resultSet.getObject("review_analysis_request_identifier", UUID.class),
                        resultSet.getObject("professional_review_identifier", UUID.class),
                        resultSet.getObject("professional_identifier", UUID.class),
                        resultSet.getObject("requested_by_professional_identifier", UUID.class),
                        resultSet.getString("reason"),
                        ModerationStatus.valueOf(resultSet.getString("moderation_status")),
                        nullableModerationDecision(resultSet.getString("moderation_decision")),
                        resultSet.getString("moderation_notes"),
                        nullableInstant(resultSet, "decided_at"),
                        resultSet.getTimestamp("created_at").toInstant()
                )
        );
    }

    @Override
    public Optional<ProfessionalReport> moderateProfessionalReport(
            UUID professionalReportIdentifier,
            ModerationStatus moderationStatus,
            ModerationDecision moderationDecision,
            String moderationNotes,
            Instant decidedAt
    ) {
        int updatedRows = jdbcTemplate.update(
                """
                UPDATE worklink.professional_reports
                SET moderation_status = ?,
                    moderation_decision = ?,
                    moderation_notes = ?,
                    decided_at = ?
                WHERE professional_report_identifier = ?
                """,
                moderationStatus.name(),
                moderationDecision == null ? null : moderationDecision.name(),
                moderationNotes,
                decidedAt,
                professionalReportIdentifier
        );
        if (updatedRows == 0) {
            return Optional.empty();
        }
        return jdbcTemplate.query(
                """
                SELECT professional_report_identifier,
                       professional_identifier,
                       reporter_identifier,
                       report_reason,
                       description,
                       evidence_file_identifier,
                       serious_case,
                       authority_guidance,
                       moderation_status,
                       moderation_decision,
                       moderation_notes,
                       decided_at,
                       created_at
                FROM worklink.professional_reports
                WHERE professional_report_identifier = ?
                """,
                (resultSet, rowNumber) -> ProfessionalReport.restoreProfessionalReport(
                        resultSet.getObject("professional_report_identifier", UUID.class),
                        resultSet.getObject("professional_identifier", UUID.class),
                        resultSet.getObject("reporter_identifier", UUID.class),
                        ProfessionalReportReason.valueOf(resultSet.getString("report_reason")),
                        resultSet.getString("description"),
                        resultSet.getObject("evidence_file_identifier", UUID.class),
                        resultSet.getBoolean("serious_case"),
                        resultSet.getString("authority_guidance"),
                        ModerationStatus.valueOf(resultSet.getString("moderation_status")),
                        nullableModerationDecision(resultSet.getString("moderation_decision")),
                        resultSet.getString("moderation_notes"),
                        nullableInstant(resultSet, "decided_at"),
                        resultSet.getTimestamp("created_at").toInstant()
                ),
                professionalReportIdentifier
        ).stream().findFirst();
    }

    @Override
    public Optional<ProfessionalReviewAnalysisRequest> moderateReviewAnalysisRequest(
            UUID reviewAnalysisRequestIdentifier,
            ModerationStatus moderationStatus,
            ModerationDecision moderationDecision,
            String moderationNotes,
            Instant decidedAt
    ) {
        int updatedRows = jdbcTemplate.update(
                """
                UPDATE worklink.professional_review_analysis_requests
                SET moderation_status = ?,
                    moderation_decision = ?,
                    moderation_notes = ?,
                    decided_at = ?
                WHERE review_analysis_request_identifier = ?
                """,
                moderationStatus.name(),
                moderationDecision == null ? null : moderationDecision.name(),
                moderationNotes,
                decidedAt,
                reviewAnalysisRequestIdentifier
        );
        if (updatedRows == 0) {
            return Optional.empty();
        }
        return jdbcTemplate.query(
                """
                SELECT review_analysis_request_identifier,
                       professional_review_identifier,
                       professional_identifier,
                       requested_by_professional_identifier,
                       reason,
                       moderation_status,
                       moderation_decision,
                       moderation_notes,
                       decided_at,
                       created_at
                FROM worklink.professional_review_analysis_requests
                WHERE review_analysis_request_identifier = ?
                """,
                (resultSet, rowNumber) -> ProfessionalReviewAnalysisRequest.restoreProfessionalReviewAnalysisRequest(
                        resultSet.getObject("review_analysis_request_identifier", UUID.class),
                        resultSet.getObject("professional_review_identifier", UUID.class),
                        resultSet.getObject("professional_identifier", UUID.class),
                        resultSet.getObject("requested_by_professional_identifier", UUID.class),
                        resultSet.getString("reason"),
                        ModerationStatus.valueOf(resultSet.getString("moderation_status")),
                        nullableModerationDecision(resultSet.getString("moderation_decision")),
                        resultSet.getString("moderation_notes"),
                        nullableInstant(resultSet, "decided_at"),
                        resultSet.getTimestamp("created_at").toInstant()
                ),
                reviewAnalysisRequestIdentifier
        ).stream().findFirst();
    }

    @Override
    public long countProfessionals() {
        return requireCount("SELECT COUNT(*) FROM worklink.professionals");
    }

    @Override
    public long countBlockedProfessionals() {
        return requireCount("SELECT COUNT(*) FROM worklink.professionals WHERE blocked = TRUE");
    }

    @Override
    public long countProfessionalReports() {
        return requireCount("SELECT COUNT(*) FROM worklink.professional_reports");
    }

    @Override
    public long countReviewAnalysisRequests() {
        return requireCount("SELECT COUNT(*) FROM worklink.professional_review_analysis_requests");
    }

    @Override
    public long countServiceCategories() {
        return requireCount("SELECT COUNT(*) FROM worklink.service_categories");
    }

    private Professional mapProfessional(ResultSet resultSet) throws SQLException {
        return Professional.restoreProfessional(
                resultSet.getObject("professional_identifier", UUID.class),
                resultSet.getString("professional_name"),
                resultSet.getString("whatsapp_number"),
                resultSet.getObject("city_identifier", UUID.class),
                resultSet.getObject("category_identifier", UUID.class),
                resultSet.getString("short_description"),
                resultSet.getObject("profile_photo_file_identifier", UUID.class),
                resultSet.getString("document_number_hash"),
                resultSet.getString("useful_link"),
                resultSet.getString("portfolio_description"),
                resultSet.getString("service_description"),
                resultSet.getInt("profile_completeness_percentage"),
                ProfessionalProfileClassification.valueOf(resultSet.getString("profile_classification")),
                ProfessionalAvailabilityStatus.valueOf(resultSet.getString("availability_status")),
                resultSet.getBoolean("phone_number_verified"),
                resultSet.getBoolean("quality_guarantee"),
                resultSet.getBoolean("blocked")
        );
    }

    private long requireCount(String sql) {
        Long count = jdbcTemplate.queryForObject(sql, Long.class);
        return count == null ? 0 : count;
    }

    private ModerationDecision nullableModerationDecision(String moderationDecision) {
        if (moderationDecision == null || moderationDecision.isBlank()) {
            return null;
        }
        return ModerationDecision.valueOf(moderationDecision);
    }

    private Instant nullableInstant(ResultSet resultSet, String columnName) throws SQLException {
        java.sql.Timestamp timestamp = resultSet.getTimestamp(columnName);
        return timestamp == null ? null : timestamp.toInstant();
    }
}
