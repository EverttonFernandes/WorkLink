package br.com.worklink.api.authentication;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.usecase.AuthenticationOtpRequestResponse;
import br.com.worklink.application.authentication.usecase.AuthenticationTokenResponse;
import br.com.worklink.application.authentication.usecase.LoginLocalAuthenticationRequest;
import br.com.worklink.application.authentication.usecase.LoginLocalAuthenticationUseCase;
import br.com.worklink.application.authentication.usecase.PasswordRecoveryRequestResponse;
import br.com.worklink.application.authentication.usecase.RefreshAuthenticationSessionRequest;
import br.com.worklink.application.authentication.usecase.RefreshAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.RequestAuthenticationOtpRequest;
import br.com.worklink.application.authentication.usecase.RequestAuthenticationOtpUseCase;
import br.com.worklink.application.authentication.usecase.RequestPasswordRecoveryRequest;
import br.com.worklink.application.authentication.usecase.RequestPasswordRecoveryUseCase;
import br.com.worklink.application.authentication.usecase.RegisterLocalAuthenticationRequest;
import br.com.worklink.application.authentication.usecase.RegisterLocalAuthenticationUseCase;
import br.com.worklink.application.authentication.usecase.RevokeAuthenticationSessionRequest;
import br.com.worklink.application.authentication.usecase.RevokeAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.ResetPasswordRequest;
import br.com.worklink.application.authentication.usecase.ResetPasswordUseCase;
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
    private final RegisterLocalAuthenticationUseCase registerLocalAuthenticationUseCase;
    private final LoginLocalAuthenticationUseCase loginLocalAuthenticationUseCase;
    private final RequestPasswordRecoveryUseCase requestPasswordRecoveryUseCase;
    private final ResetPasswordUseCase resetPasswordUseCase;

    public AuthenticationController(
            RequestAuthenticationOtpUseCase requestAuthenticationOtpUseCase,
            VerifyAuthenticationOtpUseCase verifyAuthenticationOtpUseCase,
            RefreshAuthenticationSessionUseCase refreshAuthenticationSessionUseCase,
            RevokeAuthenticationSessionUseCase revokeAuthenticationSessionUseCase,
            RegisterLocalAuthenticationUseCase registerLocalAuthenticationUseCase,
            LoginLocalAuthenticationUseCase loginLocalAuthenticationUseCase,
            RequestPasswordRecoveryUseCase requestPasswordRecoveryUseCase,
            ResetPasswordUseCase resetPasswordUseCase
    ) {
        this.requestAuthenticationOtpUseCase = requestAuthenticationOtpUseCase;
        this.verifyAuthenticationOtpUseCase = verifyAuthenticationOtpUseCase;
        this.refreshAuthenticationSessionUseCase = refreshAuthenticationSessionUseCase;
        this.revokeAuthenticationSessionUseCase = revokeAuthenticationSessionUseCase;
        this.registerLocalAuthenticationUseCase = registerLocalAuthenticationUseCase;
        this.loginLocalAuthenticationUseCase = loginLocalAuthenticationUseCase;
        this.requestPasswordRecoveryUseCase = requestPasswordRecoveryUseCase;
        this.resetPasswordUseCase = resetPasswordUseCase;
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    AuthenticationTokenHttpResponse register(@RequestBody RegisterLocalAuthenticationHttpRequest request) {
        requireMatchingPasswords(request.password(), request.passwordConfirmation());
        AuthenticationTokenResponse response = registerLocalAuthenticationUseCase.register(
                new RegisterLocalAuthenticationRequest(
                        request.fullName(), request.phoneNumber(), request.emailAddress(),
                        request.password(), request.legalAccepted()
                )
        );
        return AuthenticationTokenHttpResponse.fromResponse(response);
    }

    @PostMapping("/login")
    AuthenticationTokenHttpResponse login(@RequestBody LoginLocalAuthenticationHttpRequest request) {
        return AuthenticationTokenHttpResponse.fromResponse(loginLocalAuthenticationUseCase.login(
                new LoginLocalAuthenticationRequest(request.emailAddress(), request.password())
        ));
    }

    @PostMapping("/password-recovery/request")
    @ResponseStatus(HttpStatus.ACCEPTED)
    PasswordRecoveryRequestHttpResponse requestPasswordRecovery(
            @RequestBody RequestPasswordRecoveryHttpRequest request
    ) {
        PasswordRecoveryRequestResponse response = requestPasswordRecoveryUseCase.requestRecovery(
                new RequestPasswordRecoveryRequest(request.emailAddress())
        );
        return new PasswordRecoveryRequestHttpResponse(response.message());
    }

    @PostMapping("/password-recovery/reset")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void resetPassword(@RequestBody ResetPasswordHttpRequest request) {
        requireMatchingPasswords(request.newPassword(), request.newPasswordConfirmation());
        resetPasswordUseCase.resetPassword(new ResetPasswordRequest(request.recoveryToken(), request.newPassword()));
    }

    private static void requireMatchingPasswords(String password, String passwordConfirmation) {
        if (password == null || !password.equals(passwordConfirmation)) {
            throw new ApplicationRuleViolationException("A confirmacao da senha nao confere.");
        }
    }

    @PostMapping("/otp/request")
    AuthenticationOtpRequestHttpResponse requestAuthenticationOtp(
            @RequestBody RequestAuthenticationOtpHttpRequest request
    ) {
        AuthenticationOtpRequestResponse response = requestAuthenticationOtpUseCase.requestAuthenticationOtp(
                new RequestAuthenticationOtpRequest(
                        request.phoneNumber(),
                        request.deliveryChannel(),
                        request.emailAddress()
                )
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
