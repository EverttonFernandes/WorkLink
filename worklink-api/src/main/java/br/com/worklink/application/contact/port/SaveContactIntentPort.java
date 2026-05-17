package br.com.worklink.application.contact.port;

import br.com.worklink.domain.contact.ContactIntent;



@FunctionalInterface
public interface SaveContactIntentPort {

    ContactIntent saveContactIntent(ContactIntent contactIntent);
}
