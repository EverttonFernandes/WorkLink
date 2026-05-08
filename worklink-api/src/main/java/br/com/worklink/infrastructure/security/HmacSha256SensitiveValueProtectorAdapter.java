package br.com.worklink.infrastructure.security;

import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.application.security.port.ProtectedSensitiveValuePurpose;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.Locale;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

@Component
public class HmacSha256SensitiveValueProtectorAdapter implements ProtectSensitiveValuePort {

    private static final String HMAC_SHA_256_ALGORITHM = "HmacSHA256";

    private final String sensitiveValuePepper;

    public HmacSha256SensitiveValueProtectorAdapter(
            @Value("${worklink.security.sensitive-value-pepper}") String sensitiveValuePepper
    ) {
        this.sensitiveValuePepper = requireMeaningfulPepper(sensitiveValuePepper);
    }

    @Override
    public String protectSensitiveValue(String rawSensitiveValue, ProtectedSensitiveValuePurpose purpose) {
        String normalizedSensitiveValue = normalizeRequiredValue(rawSensitiveValue);
        ProtectedSensitiveValuePurpose validPurpose = requirePurpose(purpose);
        byte[] protectedValueBytes = calculateHmacSha256(
                "%s:%s".formatted(validPurpose.name(), normalizedSensitiveValue)
        );
        return HexFormat.of().formatHex(protectedValueBytes);
    }

    private byte[] calculateHmacSha256(String valueWithPurpose) {
        try {
            Mac mac = Mac.getInstance(HMAC_SHA_256_ALGORITHM);
            mac.init(new SecretKeySpec(sensitiveValuePepper.getBytes(StandardCharsets.UTF_8), HMAC_SHA_256_ALGORITHM));
            return mac.doFinal(valueWithPurpose.getBytes(StandardCharsets.UTF_8));
        } catch (NoSuchAlgorithmException | InvalidKeyException exception) {
            throw new IllegalStateException("Nao foi possivel proteger o valor sensivel.", exception);
        }
    }

    private static String normalizeRequiredValue(String rawSensitiveValue) {
        if (rawSensitiveValue == null || rawSensitiveValue.isBlank()) {
            throw new IllegalArgumentException("O valor sensivel e obrigatorio para protecao.");
        }
        return rawSensitiveValue.trim().toLowerCase(Locale.ROOT);
    }

    private static ProtectedSensitiveValuePurpose requirePurpose(ProtectedSensitiveValuePurpose purpose) {
        if (purpose == null) {
            throw new IllegalArgumentException("A finalidade da protecao do valor sensivel e obrigatoria.");
        }
        return purpose;
    }

    private static String requireMeaningfulPepper(String sensitiveValuePepper) {
        if (sensitiveValuePepper == null || sensitiveValuePepper.isBlank()) {
            throw new IllegalArgumentException("O pepper de valores sensiveis e obrigatorio.");
        }
        return sensitiveValuePepper;
    }
}
