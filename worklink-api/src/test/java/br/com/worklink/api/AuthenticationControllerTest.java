package br.com.worklink.api;

import br.com.worklink.api.authentication.AuthenticationController;
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

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
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

    @Test
    @DisplayName("GIVEN telefone WHEN solicitar OTP THEN deve retornar mensagem generica")
    void shouldReturnGenericMessageWhenRequestingAuthenticationOtp() throws Exception {
        // GIVEN
        when(requestAuthenticationOtpUseCase.requestAuthenticationOtp(any(RequestAuthenticationOtpRequest.class)))
                .thenReturn(new AuthenticationOtpRequestResponse(
                        "Se o telefone puder ser autenticado, um codigo sera enviado.",
                        CURRENT_INSTANT.plusSeconds(300)
                ));

        // WHEN / THEN
        mockMvc.perform(post("/api/v1/authentication/otp/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new PhoneBody("51999999999"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Se o telefone puder ser autenticado, um codigo sera enviado."))
                .andExpect(jsonPath("$.expiresAt").exists());
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

    private record PhoneBody(String phoneNumber) {
    }

    private record OtpBody(String phoneNumber, String oneTimePassword) {
    }

    private record RefreshTokenBody(String refreshToken) {
    }
}
