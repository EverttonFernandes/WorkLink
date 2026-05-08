package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.IssuedAccessToken;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.UUID;

@Component
public class HmacSha256JwtAccessTokenIssuerAdapter implements IssueAccessTokenPort {

    private static final String HMAC_SHA_256_ALGORITHM = "HmacSHA256";
    private static final Base64.Encoder BASE64_URL_ENCODER = Base64.getUrlEncoder().withoutPadding();

    private final String jwtSecret;
    private final Duration accessTokenDuration;

    public HmacSha256JwtAccessTokenIssuerAdapter(
            @Value("${worklink.security.jwt-secret}") String jwtSecret,
            @Value("${worklink.security.access-token-expiration-minutes}") long accessTokenExpirationMinutes
    ) {
        if (jwtSecret == null || jwtSecret.isBlank()) {
            throw new IllegalArgumentException("O segredo JWT e obrigatorio.");
        }
        this.jwtSecret = jwtSecret;
        this.accessTokenDuration = Duration.ofMinutes(accessTokenExpirationMinutes);
    }

    @Override
    public IssuedAccessToken issueAccessToken(UUID customerIdentifier, String profile, Instant issuedAt) {
        Instant expiresAt = issuedAt.plus(accessTokenDuration);
        String header = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
        String payload = """
                {"sub":"%s","profile":"%s","iat":%d,"exp":%d}
                """.formatted(customerIdentifier, profile, issuedAt.getEpochSecond(), expiresAt.getEpochSecond()).trim();
        String unsignedToken = "%s.%s".formatted(encode(header.getBytes(StandardCharsets.UTF_8)),
                encode(payload.getBytes(StandardCharsets.UTF_8)));
        return new IssuedAccessToken("%s.%s".formatted(unsignedToken, sign(unsignedToken)), expiresAt);
    }

    private String sign(String unsignedToken) {
        try {
            Mac mac = Mac.getInstance(HMAC_SHA_256_ALGORITHM);
            mac.init(new SecretKeySpec(jwtSecret.getBytes(StandardCharsets.UTF_8), HMAC_SHA_256_ALGORITHM));
            return encode(mac.doFinal(unsignedToken.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException | InvalidKeyException exception) {
            throw new IllegalStateException("Nao foi possivel assinar o access token.", exception);
        }
    }

    private static String encode(byte[] bytes) {
        return BASE64_URL_ENCODER.encodeToString(bytes);
    }
}
