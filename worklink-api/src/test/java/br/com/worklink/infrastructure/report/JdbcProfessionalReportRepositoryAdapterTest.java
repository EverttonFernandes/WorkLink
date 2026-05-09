package br.com.worklink.infrastructure.report;

import br.com.worklink.domain.report.ProfessionalReport;
import br.com.worklink.domain.report.ProfessionalReportReason;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class JdbcProfessionalReportRepositoryAdapterTest {

    @Test
    @DisplayName("GIVEN denuncia profissional WHEN salvar THEN deve persistir dados rastreaveis")
    void shouldPersistProfessionalReport() {
        // GIVEN
        JdbcTemplate jdbcTemplate = mock(JdbcTemplate.class);
        JdbcProfessionalReportRepositoryAdapter adapter = new JdbcProfessionalReportRepositoryAdapter(jdbcTemplate);
        ProfessionalReport professionalReport = ProfessionalReport.registerProfessionalReport(
                UUID.randomUUID(),
                UUID.randomUUID(),
                ProfessionalReportReason.THREAT,
                "Ameaca relatada",
                UUID.randomUUID(),
                Instant.parse("2026-05-09T23:40:00Z")
        );

        // WHEN
        ProfessionalReport savedProfessionalReport = adapter.saveProfessionalReport(professionalReport);

        // THEN
        assertThat(savedProfessionalReport).isEqualTo(professionalReport);
        verify(jdbcTemplate).update(
                any(String.class),
                eq(professionalReport.professionalReportIdentifier()),
                eq(professionalReport.professionalIdentifier()),
                eq(professionalReport.reporterIdentifier()),
                eq(professionalReport.reportReason().name()),
                eq(professionalReport.description()),
                eq(professionalReport.evidenceFileIdentifier()),
                eq(professionalReport.seriousCase()),
                eq(professionalReport.authorityGuidance()),
                eq(professionalReport.createdAt())
        );
    }
}
