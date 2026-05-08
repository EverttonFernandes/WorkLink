package br.com.worklink.application.security.port;

public interface ProtectSensitiveValuePort {

    String protectSensitiveValue(String rawSensitiveValue, ProtectedSensitiveValuePurpose purpose);
}
