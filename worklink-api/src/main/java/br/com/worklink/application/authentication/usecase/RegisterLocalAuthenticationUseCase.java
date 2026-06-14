package br.com.worklink.application.authentication.usecase;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.authentication.port.CurrentTimePort;
import br.com.worklink.application.authentication.port.ExecuteInTransactionPort;
import br.com.worklink.application.authentication.port.GenerateSecureTokenPort;
import br.com.worklink.application.authentication.port.IssueAccessTokenPort;
import br.com.worklink.application.authentication.port.LoadCustomerAccountByPhoneNumberPort;
import br.com.worklink.application.authentication.port.LocalAuthenticationAccountRepositoryPort;
import br.com.worklink.application.authentication.port.PasswordHashingPort;
import br.com.worklink.application.authentication.port.SaveCustomerAccountPort;
import br.com.worklink.application.authentication.port.SaveRefreshSessionPort;
import br.com.worklink.application.security.port.ProtectSensitiveValuePort;
import br.com.worklink.domain.authentication.CustomerAccount;
import br.com.worklink.domain.authentication.LocalAuthenticationAccount;

import java.time.Duration;
import java.time.Instant;

public class RegisterLocalAuthenticationUseCase {

    private final LocalAuthenticationAccountRepositoryPort accountRepository;
    private final LoadCustomerAccountByPhoneNumberPort loadCustomerByPhone;
    private final SaveCustomerAccountPort saveCustomer;
    private final PasswordHashingPort passwordHashingPort;
    private final CurrentTimePort currentTimePort;
    private final ExecuteInTransactionPort executeInTransactionPort;
    private final AuthenticationSessionTokenFactory tokenFactory;
    private final boolean enabled;

    public RegisterLocalAuthenticationUseCase(
            LocalAuthenticationAccountRepositoryPort accountRepository,
            LoadCustomerAccountByPhoneNumberPort loadCustomerByPhone,
            SaveCustomerAccountPort saveCustomer,
            PasswordHashingPort passwordHashingPort,
            CurrentTimePort currentTimePort,
            ExecuteInTransactionPort executeInTransactionPort,
            IssueAccessTokenPort issueAccessTokenPort,
            GenerateSecureTokenPort generateSecureTokenPort,
            ProtectSensitiveValuePort protectSensitiveValuePort,
            SaveRefreshSessionPort saveRefreshSessionPort,
            Duration refreshTokenDuration,
            boolean enabled
    ) {
        this.accountRepository = accountRepository;
        this.loadCustomerByPhone = loadCustomerByPhone;
        this.saveCustomer = saveCustomer;
        this.passwordHashingPort = passwordHashingPort;
        this.currentTimePort = currentTimePort;
        this.executeInTransactionPort = executeInTransactionPort;
        this.tokenFactory = new AuthenticationSessionTokenFactory(
                issueAccessTokenPort, generateSecureTokenPort, protectSensitiveValuePort,
                saveRefreshSessionPort, refreshTokenDuration
        );
        this.enabled = enabled;
    }

    public AuthenticationTokenResponse register(RegisterLocalAuthenticationRequest request) {
        requireEnabled();
        return executeInTransactionPort.execute(() -> {
            String normalizedEmailAddress = LocalAuthenticationAccount.normalizeEmailAddress(request.emailAddress());
            if (accountRepository.loadByNormalizedEmailAddress(normalizedEmailAddress).isPresent()) {
                throw new ApplicationRuleViolationException("Nao foi possivel concluir o cadastro.");
            }
            String normalizedPhoneNumber = request.phoneNumber().trim();
            if (loadCustomerByPhone.loadCustomerAccountByPhoneNumber(normalizedPhoneNumber).isPresent()) {
                throw new ApplicationRuleViolationException(
                        "Este telefone ja pertence a uma conta existente. Entre com o canal ja cadastrado."
                );
            }
            String password = LocalAuthenticationPasswordPolicy.requireValidPassword(request.password());
            Instant currentInstant = currentTimePort.currentInstant();
            CustomerAccount customerAccount = saveCustomer.saveCustomerAccount(
                    CustomerAccount.registerCustomerAccount(normalizedPhoneNumber, currentInstant)
            );
            LocalAuthenticationAccount account = LocalAuthenticationAccount.register(
                    customerAccount.customerIdentifier(),
                    request.fullName(),
                    normalizedPhoneNumber,
                    normalizedEmailAddress,
                    passwordHashingPort.hashPassword(password),
                    request.legalAccepted(),
                    currentInstant
            );
            accountRepository.save(account);
            return tokenFactory.createTokenResponse(customerAccount.customerIdentifier(), currentInstant);
        });
    }

    private void requireEnabled() {
        if (!enabled) {
            throw new ApplicationRuleViolationException("A autenticacao local esta indisponivel.");
        }
    }
}
