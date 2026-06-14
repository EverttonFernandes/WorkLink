package br.com.worklink.infrastructure.authentication;

import br.com.worklink.application.authentication.port.DeliverPasswordRecoveryTokenPort;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(
        name = "worklink.integrations.password-recovery.delivery-mode",
        havingValue = "smtp"
)
public class SmtpPasswordRecoveryDeliveryAdapter implements DeliverPasswordRecoveryTokenPort {

    private final JavaMailSender mailSender;
    private final String senderEmailAddress;
    private final String resetBaseUrl;

    public SmtpPasswordRecoveryDeliveryAdapter(
            JavaMailSender mailSender,
            @Value("${worklink.integrations.password-recovery.sender-email-address}") String senderEmailAddress,
            @Value("${worklink.integrations.password-recovery.reset-base-url}") String resetBaseUrl
    ) {
        this.mailSender = mailSender;
        this.senderEmailAddress = senderEmailAddress;
        this.resetBaseUrl = resetBaseUrl;
    }

    @Override
    public void deliverPasswordRecoveryToken(String normalizedEmailAddress, String rawToken) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(senderEmailAddress);
        message.setTo(normalizedEmailAddress);
        message.setSubject("Profissional Perto - redefinicao de senha");
        message.setText("""
                Recebemos um pedido para redefinir sua senha.

                Abra este link para continuar:
                %s?token=%s

                Se voce nao pediu a redefinicao, ignore esta mensagem.
                """.formatted(resetBaseUrl, rawToken));
        mailSender.send(message);
    }
}
