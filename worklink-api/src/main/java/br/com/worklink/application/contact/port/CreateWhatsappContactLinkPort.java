package br.com.worklink.application.contact.port;

@FunctionalInterface
public interface CreateWhatsappContactLinkPort {

    String createWhatsappContactLink(String whatsappNumber);
}
