package br.com.worklink.application.authentication.port;

import java.util.UUID;

@FunctionalInterface
public interface RevokeAllCustomerRefreshSessionsPort {

    void revokeAllCustomerRefreshSessions(UUID customerIdentifier);
}
