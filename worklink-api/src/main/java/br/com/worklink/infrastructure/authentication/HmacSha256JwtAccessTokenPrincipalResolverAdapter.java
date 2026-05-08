package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authorization.port.ResolveAuthenticatedPrincipalPort;
import br.com.worklink.application.authorization.usecase.AuthenticatedPrincipal;
import br.com.worklink.application.authorization.usecase.AuthenticatedProfile;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.Base64;
import java.util.Optional;
import java.util.UUID;

@Component
public class HmacSha256JwtAccessTokenPrincipalResolverAdapter implements ResolveAuthenticatedPrincipalPort {

    private static final String HMAC_SHA_256_ALGORITHM = "HmacSHA256";
    private static final Base64.Decoder BASE64_URL_DECODER = Base64.getUrlDecoder();
    private static final Base64.Encoder BASE64_URL_ENCODER = Base64.getUrlEncoder().withoutPadding();

    private final String jwtSecret;
    private final ObjectMapper objectMapper;
    private final CurrentTimePort currentTimePort;

    public HmacSha256JwtAccessTokenPrincipalResolverAdapter(
            @Value("${worklink.security.jwt-secret}") String jwtSecret,
            ObjectMapper objectMapper,
            CurrentTimePort currentTimePort
    ) {
        if (jwtSecret == null || jwtSecret.isBlank()) {
            throw new IllegalArgumentException("O segredo JWT e obrigatorio.");
        }
        this.jwtSecret = jwtSecret;
        this.objectMapper = objectMapper;
        this.currentTimePort = currentTimePort;
    }

    @Override
    public Optional<AuthenticatedPrincipal> resolveAuthenticatedPrincipal(String accessToken) {
        try {
            String[] tokenParts = accessToken.split("\\.");
            if (tokenParts.length != 3 || !hasValidSignature(tokenParts)) {
                return Optional.empty();
            }
            JsonNode payload = objectMapper.readTree(BASE64_URL_DECODER.decode(tokenParts[1]));
            Instant expiresAt = Instant.ofEpochSecond(payload.path("exp").asLong());
            if (!expiresAt.isAfter(currentTimePort.currentInstant())) {
                return Optional.empty();
            }
            UUID principalIdentifier = UUID.fromString(payload.path("sub").asText());
            AuthenticatedProfile profile = AuthenticatedProfile.fromTokenProfile(payload.path("profile").asText());
            return Optional.of(new AuthenticatedPrincipal(principalIdentifier, profile));
        } catch (Exception exception) {
            return Optional.empty();
        }
    }

    private boolean hasValidSignature(String[] tokenParts) {
        String unsignedToken = "%s.%s".formatted(tokenParts[0], tokenParts[1]);
        String expectedSignature = sign(unsignedToken);
        return MessageDigest.isEqual(
                expectedSignature.getBytes(StandardCharsets.UTF_8),
                tokenParts[2].getBytes(StandardCharsets.UTF_8)
        );
    }

    private String sign(String unsignedToken) {
        try {
            Mac mac = Mac.getInstance(HMAC_SHA_256_ALGORITHM);
            mac.init(new SecretKeySpec(jwtSecret.getBytes(StandardCharsets.UTF_8), HMAC_SHA_256_ALGORITHM));
            return BASE64_URL_ENCODER.encodeToString(mac.doFinal(unsignedToken.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception exception) {
            throw new IllegalStateException("Nao foi possivel validar o access token.", exception);
        }
    }
}
