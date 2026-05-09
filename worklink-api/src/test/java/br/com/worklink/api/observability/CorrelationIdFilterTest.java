package br.com.worklink.api.observability;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.assertj.core.api.Assertions.assertThat;

class CorrelationIdFilterTest {

    private final CorrelationIdFilter correlationIdFilter = new CorrelationIdFilter();

    @Test
    @DisplayName("GIVEN requisicao com correlation id valido WHEN filtrar THEN deve preservar identificador no header")
    void shouldPreserveValidCorrelationIdentifier() throws Exception {
        // GIVEN
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();
        request.addHeader(CorrelationIdFilter.CORRELATION_ID_HEADER, "valid-correlation-123");
        FilterChain filterChain = (servletRequest, servletResponse) ->
                assertThat(MDC.get(CorrelationIdFilter.CORRELATION_ID_MDC_KEY)).isEqualTo("valid-correlation-123");

        // WHEN
        correlationIdFilter.doFilter(request, response, filterChain);

        // THEN
        assertThat(response.getHeader(CorrelationIdFilter.CORRELATION_ID_HEADER)).isEqualTo("valid-correlation-123");
        assertThat(MDC.get(CorrelationIdFilter.CORRELATION_ID_MDC_KEY)).isNull();
    }

    @Test
    @DisplayName("GIVEN requisicao sem correlation id WHEN filtrar THEN deve gerar identificador seguro")
    void shouldGenerateSafeCorrelationIdentifierWhenHeaderIsMissing() throws Exception {
        // GIVEN
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain filterChain = (servletRequest, servletResponse) ->
                assertThat(MDC.get(CorrelationIdFilter.CORRELATION_ID_MDC_KEY)).isNotBlank();

        // WHEN
        correlationIdFilter.doFilter(request, response, filterChain);

        // THEN
        assertThat(response.getHeader(CorrelationIdFilter.CORRELATION_ID_HEADER))
                .isNotBlank()
                .hasSize(36);
    }

    @Test
    @DisplayName("GIVEN correlation id inseguro WHEN filtrar THEN deve substituir por identificador gerado")
    void shouldReplaceUnsafeCorrelationIdentifier() throws Exception {
        // GIVEN
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();
        request.addHeader(CorrelationIdFilter.CORRELATION_ID_HEADER, "bad\nvalue");
        FilterChain filterChain = (servletRequest, servletResponse) ->
                assertThat(MDC.get(CorrelationIdFilter.CORRELATION_ID_MDC_KEY)).isNotEqualTo("bad\nvalue");

        // WHEN
        correlationIdFilter.doFilter(request, response, filterChain);

        // THEN
        assertThat(response.getHeader(CorrelationIdFilter.CORRELATION_ID_HEADER)).isNotEqualTo("bad\nvalue");
    }
}
