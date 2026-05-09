package br.com.worklink.application.report.port;

import br.com.worklink.domain.report.ProfessionalReport;

public interface SaveProfessionalReportPort {

    ProfessionalReport saveProfessionalReport(ProfessionalReport professionalReport);
}
