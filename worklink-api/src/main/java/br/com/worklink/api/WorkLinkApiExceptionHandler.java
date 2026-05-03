package br.com.worklink.api;

import br.com.worklink.application.ApplicationRuleViolationException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class WorkLinkApiExceptionHandler {

    @ExceptionHandler(ApplicationRuleViolationException.class)
    ResponseEntity<WorkLinkApiErrorResponse> handleApplicationRuleViolationException(ApplicationRuleViolationException exception) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new WorkLinkApiErrorResponse(exception.getMessage()));
    }
}
