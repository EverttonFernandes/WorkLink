package br.com.worklink.application.authorization.usecase;

import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.AuthorizationDeniedException;
import br.com.worklink.application.authorization.port.ResolveAuthenticatedPrincipalPort;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class AuthorizationUseCaseTest {

    private static final UUID PRINCIPAL_IDENTIFIER = UUID.randomUUID();
    private static final UUID OTHER_RESOURCE_OWNER_IDENTIFIER = UUID.randomUUID();

    private final AuthorizeSensitiveActionUseCase authorizeSensitiveActionUseCase = new AuthorizeSensitiveActionUseCase();

    @Test
    @DisplayName("GIVEN cliente WHEN acessar acao administrativa THEN deve negar acesso")
    void givenCustomerWhenAccessAdministrativeActionThenShouldDenyAccess() {
        // GIVEN
        AuthenticatedPrincipal customerPrincipal = customerPrincipal();

        // WHEN / THEN
        assertThatThrownBy(() -> authorizeSensitiveActionUseCase.authorizeSensitiveAction(
                customerPrincipal,
                SensitiveAction.ACCESS_ADMINISTRATIVE_DATA
        )).isInstanceOf(AuthorizationDeniedException.class)
                .hasMessage("Acesso negado para este recurso.");
    }

    @Test
    @DisplayName("GIVEN administrador WHEN acessar acao administrativa THEN deve permitir acesso")
    void givenAdministratorWhenAccessAdministrativeActionThenShouldAllowAccess() {
        // GIVEN
        AuthenticatedPrincipal administratorPrincipal = new AuthenticatedPrincipal(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.ADMINISTRATOR
        );

        // WHEN / THEN
        authorizeSensitiveActionUseCase.authorizeSensitiveAction(
                administratorPrincipal,
                SensitiveAction.ACCESS_ADMINISTRATIVE_DATA
        );
    }

    @Test
    @DisplayName("GIVEN cliente dono do recurso WHEN acessar dado privado THEN deve permitir acesso")
    void givenCustomerResourceOwnerWhenAccessPrivateDataThenShouldAllowAccess() {
        // GIVEN
        AuthenticatedPrincipal customerPrincipal = customerPrincipal();

        // WHEN / THEN
        authorizeSensitiveActionUseCase.authorizeOwnedSensitiveAction(
                customerPrincipal,
                SensitiveAction.ACCESS_PRIVATE_CUSTOMER_DATA,
                new AuthorizationOwnership(PRINCIPAL_IDENTIFIER)
        );
    }

    @Test
    @DisplayName("GIVEN cliente diferente do dono WHEN acessar dado privado THEN deve negar acesso")
    void givenDifferentCustomerWhenAccessPrivateDataThenShouldDenyAccess() {
        // GIVEN
        AuthenticatedPrincipal customerPrincipal = customerPrincipal();

        // WHEN / THEN
        assertThatThrownBy(() -> authorizeSensitiveActionUseCase.authorizeOwnedSensitiveAction(
                customerPrincipal,
                SensitiveAction.ACCESS_PRIVATE_CUSTOMER_DATA,
                new AuthorizationOwnership(OTHER_RESOURCE_OWNER_IDENTIFIER)
        )).isInstanceOf(AuthorizationDeniedException.class);
    }

    @Test
    @DisplayName("GIVEN profissional dono do perfil WHEN alterar perfil THEN deve permitir acesso")
    void givenProfessionalResourceOwnerWhenCompleteProfessionalProfileThenShouldAllowAccess() {
        // GIVEN
        AuthenticatedPrincipal professionalPrincipal = new AuthenticatedPrincipal(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.PROFESSIONAL
        );

        // WHEN / THEN
        authorizeSensitiveActionUseCase.authorizeOwnedSensitiveAction(
                professionalPrincipal,
                SensitiveAction.COMPLETE_PROFESSIONAL_PROFILE,
                new AuthorizationOwnership(PRINCIPAL_IDENTIFIER)
        );
    }

    @Test
    @DisplayName("GIVEN profissional diferente do dono WHEN alterar perfil THEN deve negar acesso")
    void givenDifferentProfessionalWhenCompleteProfessionalProfileThenShouldDenyAccess() {
        // GIVEN
        AuthenticatedPrincipal professionalPrincipal = new AuthenticatedPrincipal(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.PROFESSIONAL
        );

        // WHEN / THEN
        assertThatThrownBy(() -> authorizeSensitiveActionUseCase.authorizeOwnedSensitiveAction(
                professionalPrincipal,
                SensitiveAction.COMPLETE_PROFESSIONAL_PROFILE,
                new AuthorizationOwnership(OTHER_RESOURCE_OWNER_IDENTIFIER)
        )).isInstanceOf(AuthorizationDeniedException.class);
    }

    @Test
    @DisplayName("GIVEN profissional dono do perfil WHEN gerenciar portfolio THEN deve permitir acesso")
    void givenProfessionalResourceOwnerWhenManageProfessionalPortfolioThenShouldAllowAccess() {
        // GIVEN
        AuthenticatedPrincipal professionalPrincipal = new AuthenticatedPrincipal(
                PRINCIPAL_IDENTIFIER,
                AuthenticatedProfile.PROFESSIONAL
        );

        // WHEN / THEN
        authorizeSensitiveActionUseCase.authorizeOwnedSensitiveAction(
                professionalPrincipal,
                SensitiveAction.MANAGE_PROFESSIONAL_PORTFOLIO,
                new AuthorizationOwnership(PRINCIPAL_IDENTIFIER)
        );
    }

    @Test
    @DisplayName("GIVEN token valido WHEN resolver principal THEN deve retornar principal autenticado")
    void givenValidTokenWhenResolvePrincipalThenShouldReturnAuthenticatedPrincipal() {
        // GIVEN
        ResolveAuthenticatedPrincipalUseCase useCase = new ResolveAuthenticatedPrincipalUseCase(
                accessToken -> Optional.of(customerPrincipal())
        );

        // WHEN
        AuthenticatedPrincipal authenticatedPrincipal = useCase.resolveAuthenticatedPrincipal("valid-token");

        // THEN
        assertThat(authenticatedPrincipal).isEqualTo(customerPrincipal());
    }

    @Test
    @DisplayName("GIVEN token invalido WHEN resolver principal THEN deve exigir autenticacao")
    void givenInvalidTokenWhenResolvePrincipalThenShouldRequireAuthentication() {
        // GIVEN
        ResolveAuthenticatedPrincipalPort resolveAuthenticatedPrincipalPort = accessToken -> Optional.empty();
        ResolveAuthenticatedPrincipalUseCase useCase = new ResolveAuthenticatedPrincipalUseCase(resolveAuthenticatedPrincipalPort);

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.resolveAuthenticatedPrincipal("invalid-token"))
                .isInstanceOf(AuthenticationRequiredException.class)
                .hasMessage("Autenticacao obrigatoria para este recurso.");
    }

    @Test
    @DisplayName("GIVEN token vazio WHEN resolver principal THEN deve exigir autenticacao")
    void givenBlankTokenWhenResolvePrincipalThenShouldRequireAuthentication() {
        // GIVEN
        ResolveAuthenticatedPrincipalUseCase useCase = new ResolveAuthenticatedPrincipalUseCase(
                accessToken -> Optional.of(customerPrincipal())
        );

        // WHEN / THEN
        assertThatThrownBy(() -> useCase.resolveAuthenticatedPrincipal(" "))
                .isInstanceOf(AuthenticationRequiredException.class)
                .hasMessage("Autenticacao obrigatoria para este recurso.");
    }

    @Test
    @DisplayName("GIVEN principal sem identificador WHEN criar principal THEN deve rejeitar valor")
    void givenMissingIdentifierWhenCreatePrincipalThenShouldRejectValue() {
        // WHEN / THEN
        assertThatThrownBy(() -> new AuthenticatedPrincipal(null, AuthenticatedProfile.CUSTOMER))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("O identificador do principal autenticado e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN principal sem perfil WHEN criar principal THEN deve rejeitar valor")
    void givenMissingProfileWhenCreatePrincipalThenShouldRejectValue() {
        // WHEN / THEN
        assertThatThrownBy(() -> new AuthenticatedPrincipal(PRINCIPAL_IDENTIFIER, null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("O perfil autenticado e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN ownership sem dono WHEN criar ownership THEN deve rejeitar valor")
    void givenMissingOwnerWhenCreateOwnershipThenShouldRejectValue() {
        // WHEN / THEN
        assertThatThrownBy(() -> new AuthorizationOwnership(null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("O identificador do dono do recurso e obrigatorio.");
    }

    @Test
    @DisplayName("GIVEN perfil de token invalido WHEN converter perfil THEN deve rejeitar valor")
    void givenInvalidTokenProfileWhenConvertProfileThenShouldRejectValue() {
        // WHEN / THEN
        assertThatThrownBy(() -> AuthenticatedProfile.fromTokenProfile("ROOT"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Perfil autenticado invalido.");
    }

    private AuthenticatedPrincipal customerPrincipal() {
        return new AuthenticatedPrincipal(PRINCIPAL_IDENTIFIER, AuthenticatedProfile.CUSTOMER);
    }
}
