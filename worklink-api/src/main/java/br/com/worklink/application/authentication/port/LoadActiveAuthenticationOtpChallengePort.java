package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;

import java.util.Optional;

public interface LoadActiveAuthenticationOtpChallengePort {

    Optional<AuthenticationOtpChallenge> loadActiveAuthenticationOtpChallengeByPhoneNumber(String phoneNumber);
}
