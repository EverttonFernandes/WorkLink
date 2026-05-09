package br.com.worklink.application.observability.usecase;

public enum OperationalEventType {
    AUTHENTICATION_FLOW,
    AUTHORIZATION_DENIED,
    PRIVACY_GUARDRAIL,
    SENSITIVE_AUDIT_FLOW,
    STORAGE_FLOW,
    API_REQUEST_FAILURE
}
