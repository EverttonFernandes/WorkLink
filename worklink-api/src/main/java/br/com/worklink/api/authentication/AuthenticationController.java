package br.com.worklink.api.authentication;

import br.com.worklink.application.authentication.usecase.AuthenticationOtpRequestResponse;
import br.com.worklink.application.authentication.usecase.AuthenticationTokenResponse;
import br.com.worklink.application.authentication.usecase.RefreshAuthenticationSessionRequest;
import br.com.worklink.application.authentication.usecase.RefreshAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.RequestAuthenticationOtpRequest;
import br.com.worklink.application.authentication.usecase.RequestAuthenticationOtpUseCase;
import br.com.worklink.application.authentication.usecase.RevokeAuthenticationSessionRequest;
import br.com.worklink.application.authentication.usecase.RevokeAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.VerifyAuthenticationOtpRequest;
import br.com.worklink.application.authentication.usecase.VerifyAuthenticationOtpUseCase;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/authentication")
public class AuthenticationController {

    private final RequestAuthenticationOtpUseCase requestAuthenticationOtpUseCase;
    private final VerifyAuthenticationOtpUseCase verifyAuthenticationOtpUseCase;
    private final RefreshAuthenticationSessionUseCase refreshAuthenticationSessionUseCase;
    private final RevokeAuthenticationSessionUseCase revokeAuthenticationSessionUseCase;

    public AuthenticationController(
            RequestAuthenticationOtpUseCase requestAuthenticationOtpUseCase,
            VerifyAuthenticationOtpUseCase verifyAuthenticationOtpUseCase,
            RefreshAuthenticationSessionUseCase refreshAuthenticationSessionUseCase,
            RevokeAuthenticationSessionUseCase revokeAuthenticationSessionUseCase
    ) {
        this.requestAuthenticationOtpUseCase = requestAuthenticationOtpUseCase;
        this.verifyAuthenticationOtpUseCase = verifyAuthenticationOtpUseCase;
        this.refreshAuthenticationSessionUseCase = refreshAuthenticationSessionUseCase;
        this.revokeAuthenticationSessionUseCase = revokeAuthenticationSessionUseCase;
    }

    @PostMapping("/otp/request")
    AuthenticationOtpRequestHttpResponse requestAuthenticationOtp(
            @RequestBody RequestAuthenticationOtpHttpRequest request
    ) {
        AuthenticationOtpRequestResponse response = requestAuthenticationOtpUseCase.requestAuthenticationOtp(
                new RequestAuthenticationOtpRequest(request.phoneNumber())
        );
        return AuthenticationOtpRequestHttpResponse.fromResponse(response);
    }

    @PostMapping("/otp/verify")
    AuthenticationTokenHttpResponse verifyAuthenticationOtp(
            @RequestBody VerifyAuthenticationOtpHttpRequest request
    ) {
        AuthenticationTokenResponse response = verifyAuthenticationOtpUseCase.verifyAuthenticationOtp(
                new VerifyAuthenticationOtpRequest(request.phoneNumber(), request.oneTimePassword())
        );
        return AuthenticationTokenHttpResponse.fromResponse(response);
    }

    @PostMapping("/session/refresh")
    AuthenticationTokenHttpResponse refreshAuthenticationSession(
            @RequestBody RefreshAuthenticationSessionHttpRequest request
    ) {
        AuthenticationTokenResponse response = refreshAuthenticationSessionUseCase.refreshAuthenticationSession(
                new RefreshAuthenticationSessionRequest(request.refreshToken())
        );
        return AuthenticationTokenHttpResponse.fromResponse(response);
    }

    @PostMapping("/session/revoke")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void revokeAuthenticationSession(@RequestBody RevokeAuthenticationSessionHttpRequest request) {
        revokeAuthenticationSessionUseCase.revokeAuthenticationSession(
                new RevokeAuthenticationSessionRequest(request.refreshToken())
        );
    }
}
