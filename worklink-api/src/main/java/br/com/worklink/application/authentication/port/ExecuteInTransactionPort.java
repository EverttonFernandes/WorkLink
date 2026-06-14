package br.com.worklink.application.authentication.port;

import java.util.function.Supplier;

@FunctionalInterface
public interface ExecuteInTransactionPort {

    <T> T execute(Supplier<T> action);
}
