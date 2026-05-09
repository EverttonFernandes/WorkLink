package br.com.worklink.application.authorization.usecase;

import br.com.worklink.application.AuthorizationDeniedException;

import java.util.EnumSet;

public class AuthorizeSensitiveActionUseCase {

    private static final String FORBIDDEN_MESSAGE = "Acesso negado para este recurso.";

    private static final EnumSet<SensitiveAction> ADMINISTRATIVE_ACTIONS = EnumSet.of(
            SensitiveAction.REGISTER_SERVICE_CATEGORY,
            SensitiveAction.REGISTER_SERVICE_CITY,
            SensitiveAction.ACCESS_ADMINISTRATIVE_DATA,
            SensitiveAction.ACCESS_INTERNAL_REVIEW_AUTHORSHIP,
            SensitiveAction.ACCESS_THIRD_PARTY_REPORT,
            SensitiveAction.BLOCK_PROFESSIONAL,
            SensitiveAction.UNBLOCK_PROFESSIONAL
    );

    public void authorizeSensitiveAction(AuthenticatedPrincipal authenticatedPrincipal, SensitiveAction sensitiveAction) {
        if (authenticatedPrincipal.profile() == AuthenticatedProfile.ADMINISTRATOR) {
            return;
        }
        if (ADMINISTRATIVE_ACTIONS.contains(sensitiveAction)) {
            throw new AuthorizationDeniedException(FORBIDDEN_MESSAGE);
        }
        throw new AuthorizationDeniedException(FORBIDDEN_MESSAGE);
    }

    public void authorizeOwnedSensitiveAction(
            AuthenticatedPrincipal authenticatedPrincipal,
            SensitiveAction sensitiveAction,
            AuthorizationOwnership authorizationOwnership
    ) {
        if (authenticatedPrincipal.profile() == AuthenticatedProfile.ADMINISTRATOR) {
            return;
        }
        if (isAllowedOwnedAction(authenticatedPrincipal, sensitiveAction, authorizationOwnership)) {
            return;
        }
        throw new AuthorizationDeniedException(FORBIDDEN_MESSAGE);
    }

    private boolean isAllowedOwnedAction(
            AuthenticatedPrincipal authenticatedPrincipal,
            SensitiveAction sensitiveAction,
            AuthorizationOwnership authorizationOwnership
    ) {
        if (sensitiveAction == SensitiveAction.COMPLETE_PROFESSIONAL_PROFILE) {
            return authenticatedPrincipal.profile() == AuthenticatedProfile.PROFESSIONAL
                    && authenticatedPrincipal.principalIdentifier().equals(authorizationOwnership.ownerIdentifier());
        }
        if (sensitiveAction == SensitiveAction.ACCESS_PRIVATE_CUSTOMER_DATA) {
            return authenticatedPrincipal.profile() == AuthenticatedProfile.CUSTOMER
                    && authenticatedPrincipal.principalIdentifier().equals(authorizationOwnership.ownerIdentifier());
        }
        return false;
    }
}
