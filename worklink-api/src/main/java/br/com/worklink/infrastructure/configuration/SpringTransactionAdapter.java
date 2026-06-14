package br.com.worklink.infrastructure.configuration;

import br.com.worklink.application.authentication.port.ExecuteInTransactionPort;

import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.function.Supplier;

@Component
public class SpringTransactionAdapter implements ExecuteInTransactionPort {

    private final TransactionTemplate transactionTemplate;

    public SpringTransactionAdapter(TransactionTemplate transactionTemplate) {
        this.transactionTemplate = transactionTemplate;
    }

    @Override
    public <T> T execute(Supplier<T> action) {
        return transactionTemplate.execute(transactionStatus -> action.get());
    }
}
