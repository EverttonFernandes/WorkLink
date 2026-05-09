package br.com.worklink.domain.report;

import br.com.worklink.domain.BusinessRuleViolationException;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Instant;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ProfessionalReportTest {

    @Test
    @DisplayName("GIVEN motivo valido WHEN registrar denuncia THEN deve normalizar campos opcionais")
    void shouldRegisterProfessionalReportWithOptionalEvidence() {
        // GIVEN
        UUID professionalIdentifier = UUID.randomUUID();
        UUID reporterIdentifier = UUID.randomUUID();
        UUID evidenceFileIdentifier = UUID.randomUUID();

        // WHEN
        ProfessionalReport professionalReport = ProfessionalReport.registerProfessionalReport(
                professionalIdentifier,
                reporterIdentifier,
                ProfessionalReportReason.FRAUD,
                "  Perfil falso e cobranca antecipada  ",
                evidenceFileIdentifier,
                Instant.parse("2026-05-09T23:00:00Z")
        );

        // THEN
        assertThat(professionalReport.professionalReportIdentifier()).isNotNull();
        assertThat(professionalReport.professionalIdentifier()).isEqualTo(professionalIdentifier);
        assertThat(professionalReport.reporterIdentifier()).isEqualTo(reporterIdentifier);
        assertThat(professionalReport.reportReason()).isEqualTo(ProfessionalReportReason.FRAUD);
        assertThat(professionalReport.description()).isEqualTo("Perfil falso e cobranca antecipada");
        assertThat(professionalReport.evidenceFileIdentifier()).isEqualTo(evidenceFileIdentifier);
        assertThat(professionalReport.seriousCase()).isFalse();
        assertThat(professionalReport.authorityGuidance()).isNull();
    }

    @Test
    @DisplayName("GIVEN motivo ausente WHEN registrar denuncia THEN deve bloquear")
    void shouldBlockProfessionalReportWithoutReason() {
        // GIVEN / WHEN / THEN
        assertThatThrownBy(() -> ProfessionalReport.registerProfessionalReport(
                UUID.randomUUID(),
                UUID.randomUUID(),
                null,
                "Descricao",
                null,
                Instant.parse("2026-05-09T23:00:00Z")
        )).isInstanceOf(BusinessRuleViolationException.class)
                .hasMessage("O motivo da denuncia e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN motivo grave WHEN registrar denuncia THEN deve orientar autoridades")
    void shouldGuideAuthoritiesForSeriousReportReason() {
        // GIVEN / WHEN
        ProfessionalReport professionalReport = ProfessionalReport.registerProfessionalReport(
                UUID.randomUUID(),
                UUID.randomUUID(),
                ProfessionalReportReason.THREAT,
                "Ameaca durante o atendimento",
                null,
                Instant.parse("2026-05-09T23:00:00Z")
        );

        // THEN
        assertThat(professionalReport.seriousCase()).isTrue();
        assertThat(professionalReport.authorityGuidance()).contains("autoridades competentes");
    }
}
