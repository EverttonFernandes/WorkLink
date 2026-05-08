package br.com.worklink.application.authentication.port;

import java.time.Instant;
import java.util.UUID;

public interface IssueAccessTokenPort {

    IssuedAccessToken issueAccessToken(UUID customerIdentifier, String profile, Instant issuedAt);
}
