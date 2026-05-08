package br.com.worklink.api;

import br.com.worklink.application.ApplicationRuleViolationException;
import br.com.worklink.application.AuthenticationRequiredException;
import br.com.worklink.application.AuthorizationDeniedException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class WorkLinkApiExceptionHandler {

    @ExceptionHandler(ApplicationRuleViolationException.class)
    ResponseEntity<WorkLinkApiErrorResponse> handleApplicationRuleViolationException(ApplicationRuleViolationException exception) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new WorkLinkApiErrorResponse(exception.getMessage()));
    }

    @ExceptionHandler(AuthenticationRequiredException.class)
    ResponseEntity<WorkLinkApiErrorResponse> handleAuthenticationRequiredException(AuthenticationRequiredException exception) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(new WorkLinkApiErrorResponse(exception.getMessage()));
    }

    @ExceptionHandler(AuthorizationDeniedException.class)
    ResponseEntity<WorkLinkApiErrorResponse> handleAuthorizationDeniedException(AuthorizationDeniedException exception) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(new WorkLinkApiErrorResponse(exception.getMessage()));
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    ResponseEntity<WorkLinkApiErrorResponse> handleHttpMessageNotReadableException() {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new WorkLinkApiErrorResponse("O corpo da requisicao contem campos invalidos ou fora do contrato."));
    }
}
