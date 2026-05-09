package br.com.worklink.infrastructure.contact;

import br.com.worklink.application.contact.port.CreateWhatsappContactLinkPort;

import org.springframework.stereotype.Component;

@Component
public class WhatsappContactLinkAdapter implements CreateWhatsappContactLinkPort {

    @Override
    public String createWhatsappContactLink(String whatsappNumber) {
        String digitsOnlyWhatsappNumber = whatsappNumber.replaceAll("\\D", "");
        return "https://wa.me/%s".formatted(digitsOnlyWhatsappNumber);
    }
}
