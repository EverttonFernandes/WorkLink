package br.com.worklink.infrastructure.report;

import br.com.worklink.application.report.port.SaveProfessionalReportPort;
import br.com.worklink.domain.report.ProfessionalReport;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class JdbcProfessionalReportRepositoryAdapter implements SaveProfessionalReportPort {

    private final JdbcTemplate jdbcTemplate;

    public JdbcProfessionalReportRepositoryAdapter(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public ProfessionalReport saveProfessionalReport(ProfessionalReport professionalReport) {
        jdbcTemplate.update(
                """
                INSERT INTO worklink.professional_reports (
                    professional_report_identifier,
                    professional_identifier,
                    reporter_identifier,
                    report_reason,
                    description,
                    evidence_file_identifier,
                    serious_case,
                    authority_guidance,
                    created_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                professionalReport.professionalReportIdentifier(),
                professionalReport.professionalIdentifier(),
                professionalReport.reporterIdentifier(),
                professionalReport.reportReason().name(),
                professionalReport.description(),
                professionalReport.evidenceFileIdentifier(),
                professionalReport.seriousCase(),
                professionalReport.authorityGuidance(),
                professionalReport.createdAt()
        );
        return professionalReport;
    }
}
