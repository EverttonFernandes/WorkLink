package br.com.worklink.infrastructure.observability;

import java.util.regex.Pattern;

public class SensitiveLogValueSanitizer {

    private static final String REDACTED_VALUE = "[REDACTED]";
    private static final Pattern TOKEN_PATTERN = Pattern.compile(
            "(?i)(access[_-]?token|refresh[_-]?token|authorization|secret|api[_-]?key|otp|one[_-]?time[_-]?password)=([^\\s,;]+)"
    );
    private static final Pattern BRAZILIAN_DOCUMENT_PATTERN = Pattern.compile("\\b\\d{3}\\.?\\d{3}\\.?\\d{3}-?\\d{2}\\b");
    private static final Pattern BRAZILIAN_COMPANY_DOCUMENT_PATTERN = Pattern.compile("\\b\\d{2}\\.?\\d{3}\\.?\\d{3}/?\\d{4}-?\\d{2}\\b");
    private static final Pattern PHONE_NUMBER_PATTERN = Pattern.compile("\\b(?:\\+?55)?\\d{10,11}\\b");

    public String sanitize(String rawValue) {
        if (rawValue == null || rawValue.isBlank()) {
            return "";
        }
        String sanitizedValue = TOKEN_PATTERN.matcher(rawValue).replaceAll("$1=" + REDACTED_VALUE);
        sanitizedValue = BRAZILIAN_COMPANY_DOCUMENT_PATTERN.matcher(sanitizedValue).replaceAll(REDACTED_VALUE);
        sanitizedValue = BRAZILIAN_DOCUMENT_PATTERN.matcher(sanitizedValue).replaceAll(REDACTED_VALUE);
        return PHONE_NUMBER_PATTERN.matcher(sanitizedValue).replaceAll(REDACTED_VALUE);
    }
}
