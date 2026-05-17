package br.com.worklink.application.admin.port;

import br.com.worklink.domain.report.ProfessionalReport;

import java.util.List;



@FunctionalInterface
public interface ListAdministrativeProfessionalReportsPort {

    List<ProfessionalReport> listAdministrativeProfessionalReports();
}
