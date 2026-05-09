package br.com.worklink.domain.report;

public enum ProfessionalReportReason {

    FRAUD(false),
    HARASSMENT(true),
    THREAT(true),
    FAKE_PROFILE(false),
    SERVICE_NOT_PERFORMED(false),
    OTHER(false);

    private final boolean serious;

    ProfessionalReportReason(boolean serious) {
        this.serious = serious;
    }

    public boolean isSerious() {
        return serious;
    }
}
