package br.com.worklink.application.authentication.port;

import br.com.worklink.domain.authentication.AuthenticationOtpChallenge;

public interface SaveAuthenticationOtpChallengePort {

    AuthenticationOtpChallenge saveAuthenticationOtpChallenge(AuthenticationOtpChallenge authenticationOtpChallenge);
}
