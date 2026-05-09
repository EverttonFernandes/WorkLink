import 'package:flutter/foundation.dart';

import 'professional_contact_intention.dart';
import 'professional_contact_state.dart';

typedef RegisterProfessionalContactIntention
    = Future<ProfessionalContactIntention> Function(
  String professionalIdentifier,
);

typedef OpenProfessionalWhatsappContact = Future<bool> Function(
  String whatsappContactLink,
);

class ProfessionalContactController extends ChangeNotifier {
  ProfessionalContactController({
    required this.registerProfessionalContactIntention,
    required this.openProfessionalWhatsappContact,
  });

  final RegisterProfessionalContactIntention
      registerProfessionalContactIntention;
  final OpenProfessionalWhatsappContact openProfessionalWhatsappContact;

  ProfessionalContactState _state = const ProfessionalContactState();

  ProfessionalContactState get state => _state;

  Future<void> startProfessionalContact(String professionalIdentifier) async {
    _setState(
      const ProfessionalContactState(
        status: ProfessionalContactStatus.registeringContactIntention,
      ),
    );

    try {
      final contactIntention =
          await registerProfessionalContactIntention(professionalIdentifier);
      _setState(
        ProfessionalContactState(
          status: ProfessionalContactStatus.openingWhatsapp,
          contactIntention: contactIntention,
        ),
      );
      final whatsappOpened = await openProfessionalWhatsappContact(
        contactIntention.whatsappContactLink,
      );
      if (!whatsappOpened) {
        _setState(
          ProfessionalContactState(
            status: ProfessionalContactStatus.failed,
            contactIntention: contactIntention,
            errorMessage:
                'Nao foi possivel abrir o WhatsApp. Tente novamente em instantes.',
          ),
        );
        return;
      }
      _setState(
        ProfessionalContactState(
          status: ProfessionalContactStatus.completed,
          contactIntention: contactIntention,
        ),
      );
    } catch (_) {
      _setState(
        const ProfessionalContactState(
          status: ProfessionalContactStatus.failed,
          errorMessage:
              'Nao foi possivel registrar sua intencao de contato agora.',
        ),
      );
    }
  }

  void _setState(ProfessionalContactState nextState) {
    _state = nextState;
    notifyListeners();
  }
}
