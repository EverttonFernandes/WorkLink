package br.com.worklink.application.security.port;

@FunctionalInterface
public interface ProtectSensitiveValuePort {

    String protectSensitiveValue(String rawSensitiveValue, ProtectedSensitiveValuePurpose purpose);
}
