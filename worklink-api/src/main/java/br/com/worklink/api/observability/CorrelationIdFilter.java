package br.com.worklink.api.observability;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;
import java.util.regex.Pattern;

@Component
public class CorrelationIdFilter extends OncePerRequestFilter {

    public static final String CORRELATION_ID_HEADER = "X-Correlation-Id";
    public static final String CORRELATION_ID_MDC_KEY = "correlationId";

    private static final Pattern SAFE_CORRELATION_ID_PATTERN = Pattern.compile("[A-Za-z0-9._-]{8,80}");

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {
        String correlationIdentifier = resolveCorrelationIdentifier(request);
        MDC.put(CORRELATION_ID_MDC_KEY, correlationIdentifier);
        response.setHeader(CORRELATION_ID_HEADER, correlationIdentifier);
        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.remove(CORRELATION_ID_MDC_KEY);
        }
    }

    private String resolveCorrelationIdentifier(HttpServletRequest request) {
        String receivedCorrelationIdentifier = request.getHeader(CORRELATION_ID_HEADER);
        if (receivedCorrelationIdentifier != null
                && SAFE_CORRELATION_ID_PATTERN.matcher(receivedCorrelationIdentifier).matches()) {
            return receivedCorrelationIdentifier;
        }
        return UUID.randomUUID().toString();
    }
}
