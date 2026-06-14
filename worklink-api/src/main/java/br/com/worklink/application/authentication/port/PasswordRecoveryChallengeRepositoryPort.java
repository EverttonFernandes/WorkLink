package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.PasswordRecoveryChallenge;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

public interface PasswordRecoveryChallengeRepositoryPort {

    PasswordRecoveryChallenge save(PasswordRecoveryChallenge challenge);

    Optional<PasswordRecoveryChallenge> loadByTokenHash(String tokenHash);

    PasswordRecoveryChallenge update(PasswordRecoveryChallenge challenge);

    boolean markAsUsedIfActive(UUID challengeIdentifier);

    void deleteExpiredOrUsedChallenges(Instant currentInstant);
}
