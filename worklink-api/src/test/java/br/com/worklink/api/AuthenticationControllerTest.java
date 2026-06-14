package br.com.worklink.api;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.InvalidAuthenticationCredentialsException;
import br.com.worklink.api.authentication.AuthenticationController;
import br.com.worklink.application.authentication.usecase.AuthenticationOtpRequestResponse;
import br.com.worklink.application.authentication.usecase.AuthenticationTokenResponse;
import br.com.worklink.application.authentication.usecase.LoginLocalAuthenticationUseCase;
import br.com.worklink.application.authentication.usecase.PasswordRecoveryRequestResponse;
import br.com.worklink.application.authentication.usecase.RefreshAuthenticationSessionRequest;
import br.com.worklink.application.authentication.usecase.RefreshAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.RequestAuthenticationOtpRequest;
import br.com.worklink.application.authentication.usecase.RequestAuthenticationOtpUseCase;
import br.com.worklink.application.authentication.usecase.RequestPasswordRecoveryUseCase;
import br.com.worklink.application.authentication.usecase.RegisterLocalAuthenticationUseCase;
import br.com.worklink.application.authentication.usecase.RevokeAuthenticationSessionRequest;
import br.com.worklink.application.authentication.usecase.RevokeAuthenticationSessionUseCase;
import br.com.worklink.application.authentication.usecase.ResetPasswordUseCase;
import br.com.worklink.application.authentication.usecase.VerifyAuthenticationOtpRequest;
import br.com.worklink.application.authentication.usecase.VerifyAuthenticationOtpUseCase;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthenticationController.class)
class AuthenticationControllerTest {

    private static final Instant CURRENT_INSTANT = Instant.parse("2026-05-08T20:00:00Z");
    private static final UUID CUSTOMER_IDENTIFIER = UUID.randomUUID();

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private RequestAuthenticationOtpUseCase requestAuthenticationOtpUseCase;

    @MockBean
    private VerifyAuthenticationOtpUseCase verifyAuthenticationOtpUseCase;

    @MockBean
    private RefreshAuthenticationSessionUseCase refreshAuthenticationSessionUseCase;

    @MockBean
    private RevokeAuthenticationSessionUseCase revokeAuthenticationSessionUseCase;

    @MockBean
    private RegisterLocalAuthenticationUseCase registerLocalAuthenticationUseCase;

    @MockBean
    private LoginLocalAuthenticationUseCase loginLocalAuthenticationUseCase;

    @MockBean
    private RequestPasswordRecoveryUseCase requestPasswordRecoveryUseCase;

    @MockBean
    private ResetPasswordUseCase resetPasswordUseCase;

    @Test
    @DisplayName("GIVEN cadastro local valido WHEN cadastrar THEN deve retornar tokens")
    void shouldReturnTokensWhenRegisteringLocalAccount() throws Exception {
        // GIVEN
        when(registerLocalAuthenticationUseCase.register(any())).thenReturn(authenticationTokenResponse());

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "fullName":"Cliente Exemplo",
                                  "phoneNumber":"51999999999",
                                  "emailAddress":"cliente@example.com",
                                  "password":"senha-segura-123",
                                  "passwordConfirmation":"senha-segura-123",
                                  "legalAccepted":true
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.accessToken").value("access-token"));
    }

    @Test
    @DisplayName("GIVEN credenciais locais WHEN autenticar THEN deve retornar tokens")
    void shouldReturnTokensWhenLoggingIn() throws Exception {
        // GIVEN
        when(loginLocalAuthenticationUseCase.login(any())).thenReturn(authenticationTokenResponse());

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"emailAddress":"cliente@example.com","password":"senha-segura-123"}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.refreshToken").value("refresh-token"));
    }

    @Test
    @DisplayName("GIVEN credenciais invalidas WHEN autenticar THEN deve retornar unauthorized generico")
    void shouldReturnUnauthorizedWhenLocalCredentialsAreInvalid() throws Exception {
        // GIVEN
        when(loginLocalAuthenticationUseCase.login(any()))
                .thenThrow(new InvalidAuthenticationCredentialsException("E-mail ou senha invalidos."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"emailAddress":"cliente@example.com","password":"senha-incorreta"}
                                """))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message").value("E-mail ou senha invalidos."));
    }

    @Test
    @DisplayName("GIVEN email WHEN solicitar recuperacao THEN deve retornar mensagem generica")
    void shouldReturnGenericMessageWhenRequestingPasswordRecovery() throws Exception {
        // GIVEN
        when(requestPasswordRecoveryUseCase.requestRecovery(any())).thenReturn(
                new PasswordRecoveryRequestResponse(
                        "Se o e-mail estiver cadastrado, enviaremos instrucoes para redefinir a senha."
                )
        );

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/password-recovery/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"emailAddress\":\"cliente@example.com\"}"))
                .andExpect(status().isAccepted())
                .andExpect(jsonPath("$.message").exists());
    }

    @Test
    @DisplayName("GIVEN provedor indisponivel WHEN solicitar recuperacao THEN deve retornar erro de regra")
    void shouldReturnBadRequestWhenPasswordRecoveryIsUnavailable() throws Exception {
        // GIVEN
        when(requestPasswordRecoveryUseCase.requestRecovery(any()))
                .thenThrow(new ApplicationRuleViolationException("A recuperacao de senha esta indisponivel."));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/password-recovery/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"emailAddress\":\"cliente@example.com\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("A recuperacao de senha esta indisponivel."));
    }

    @Test
    @DisplayName("GIVEN token valido WHEN redefinir senha THEN deve retornar sem conteudo")
    void shouldReturnNoContentWhenResettingPassword() throws Exception {
        // GIVEN / WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/password-recovery/reset")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "recoveryToken":"opaque-token",
                                  "newPassword":"nova-senha-segura-123",
                                  "newPasswordConfirmation":"nova-senha-segura-123"
                                }
                                """))
                .andExpect(status().isNoContent());
    }

    @Test
    @DisplayName("GIVEN telefone WHEN solicitar OTP THEN deve retornar mensagem generica")
    void shouldReturnGenericMessageWhenRequestingAuthenticationOtp() throws Exception {
        // GIVEN
        when(requestAuthenticationOtpUseCase.requestAuthenticationOtp(any(RequestAuthenticationOtpRequest.class)))
                .thenReturn(new AuthenticationOtpRequestResponse(
                        "Se os dados puderem ser autenticados, um codigo sera enviado pelo canal escolhido.",
                        CURRENT_INSTANT.plusSeconds(300),
                        List.of("SMS", "WHATSAPP", "EMAIL"),
                        true
                ));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/otp/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(
                                new PhoneBody("51999999999", "WHATSAPP", null)
                        )))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message")
                        .value("Se os dados puderem ser autenticados, um codigo sera enviado pelo canal escolhido."))
                .andExpect(jsonPath("$.expiresAt").exists())
                .andExpect(jsonPath("$.deliveryChannels[0]").value("SMS"))
                .andExpect(jsonPath("$.deliveryChannels[1]").value("WHATSAPP"))
                .andExpect(jsonPath("$.deliveryChannels[2]").value("EMAIL"))
                .andExpect(jsonPath("$.simulatedDelivery").value(true));
        verify(requestAuthenticationOtpUseCase).requestAuthenticationOtp(argThat(request ->
                request.phoneNumber().equals("51999999999")
                        && request.deliveryChannel().equals("WHATSAPP")
                        && request.emailAddress() == null
        ));
    }

    @Test
    @DisplayName("GIVEN OTP correto WHEN verificar THEN deve retornar tokens")
    void shouldReturnTokensWhenVerifyingAuthenticationOtp() throws Exception {
        // GIVEN
        when(verifyAuthenticationOtpUseCase.verifyAuthenticationOtp(any(VerifyAuthenticationOtpRequest.class)))
                .thenReturn(authenticationTokenResponse());

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new OtpBody("51999999999", "123456"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.customerIdentifier").value(CUSTOMER_IDENTIFIER.toString()))
                .andExpect(jsonPath("$.accessToken").value("access-token"))
                .andExpect(jsonPath("$.refreshToken").value("refresh-token"))
                .andExpect(jsonPath("$.accessTokenExpiresAt").exists())
                .andExpect(jsonPath("$.refreshTokenExpiresAt").exists());
    }

    @Test
    @DisplayName("GIVEN refresh token WHEN renovar sessao THEN deve retornar novos tokens")
    void shouldReturnNewTokensWhenRefreshingSession() throws Exception {
        // GIVEN
        when(refreshAuthenticationSessionUseCase.refreshAuthenticationSession(any(RefreshAuthenticationSessionRequest.class)))
                .thenReturn(authenticationTokenResponse());

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/session/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new RefreshTokenBody("refresh-token"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.refreshToken").value("refresh-token"));
    }

    @Test
    @DisplayName("GIVEN refresh token WHEN revogar sessao THEN deve retornar sem conteudo")
    void shouldReturnNoContentWhenRevokingSession() throws Exception {
        // GIVEN
        RefreshTokenBody body = new RefreshTokenBody("refresh-token");

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/session/revoke")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(body)))
                .andExpect(status().isNoContent());
        verify(revokeAuthenticationSessionUseCase).revokeAuthenticationSession(argThat(this::hasExpectedRefreshToken));
    }

    private boolean hasExpectedRefreshToken(RevokeAuthenticationSessionRequest request) {
        return request.refreshToken().equals("refresh-token");
    }

    private AuthenticationTokenResponse authenticationTokenResponse() {
        return new AuthenticationTokenResponse(
                CUSTOMER_IDENTIFIER,
                "access-token",
                "refresh-token",
                CURRENT_INSTANT.plusSeconds(900),
                CURRENT_INSTANT.plusSeconds(2_592_000)
        );
    }

    private record PhoneBody(String phoneNumber, String deliveryChannel, String emailAddress) {
    }

    private record OtpBody(String phoneNumber, String oneTimePassword) {
    }

    private record RefreshTokenBody(String refreshToken) {
    }
}
