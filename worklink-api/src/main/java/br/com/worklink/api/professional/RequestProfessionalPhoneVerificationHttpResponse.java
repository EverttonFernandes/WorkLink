package br.com.worklink.api.professional;

import br.com.worklink.application.professional.usecase.RequestProfessionalPhoneVerificationResponse;

import java.time.Instant;
import java.util.UUID;

public record RequestProfessionalPhoneVerificationHttpResponse(
        UUID professionalIdentifier,
        String message,
        Instant expiresAt
) {

    static RequestProfessionalPhoneVerificationHttpResponse fromResponse(
            RequestProfessionalPhoneVerificationResponse response
    ) {
        return new RequestProfessionalPhoneVerificationHttpResponse(
                response.professionalIdentifier(),
                response.message(),
                response.expiresAt()
        );
    }
}
