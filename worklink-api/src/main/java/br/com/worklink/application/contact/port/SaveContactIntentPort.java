package br.com.worklink.application.contact.port;

import br.com.worklink.domain.contact.ContactIntent;

public interface SaveContactIntentPort {

    ContactIntent saveContactIntent(ContactIntent contactIntent);
}
