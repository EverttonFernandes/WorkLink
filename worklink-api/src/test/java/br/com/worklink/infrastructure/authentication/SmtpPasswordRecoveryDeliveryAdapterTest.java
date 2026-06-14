package br.com.worklink.infrastructure.authentication;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

class SmtpPasswordRecoveryDeliveryAdapterTest {

    @Test
    @DisplayName("GIVEN token de recuperacao WHEN enviar email THEN deve montar mensagem com link")
    void shouldSendPasswordRecoveryLinkByElectronicMail() {
        // GIVEN
        JavaMailSender mailSender = mock(JavaMailSender.class);
        doNothing().when(mailSender).send(any(SimpleMailMessage.class));
        SmtpPasswordRecoveryDeliveryAdapter adapter = new SmtpPasswordRecoveryDeliveryAdapter(
                mailSender,
                "no-reply@profissionalperto.local",
                "https://profissionalperto.app/redefinir-senha"
        );

        // WHEN
        adapter.deliverPasswordRecoveryToken("cliente@example.com", "token-opaco");

        // THEN
        org.mockito.ArgumentCaptor<SimpleMailMessage> messageCaptor =
                org.mockito.ArgumentCaptor.forClass(SimpleMailMessage.class);
        verify(mailSender).send(messageCaptor.capture());
        SimpleMailMessage message = messageCaptor.getValue();
        assertThat(message.getTo()).containsExactly("cliente@example.com");
        assertThat(message.getFrom()).isEqualTo("no-reply@profissionalperto.local");
        assertThat(message.getText()).contains("https://profissionalperto.app/redefinir-senha?token=token-opaco");
    }
}
