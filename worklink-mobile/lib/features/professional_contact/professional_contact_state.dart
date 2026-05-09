import 'professional_contact_intention.dart';

enum ProfessionalContactStatus {
  idle,
  registeringContactIntention,
  openingWhatsapp,
  completed,
  failed,
}

class ProfessionalContactState {
  const ProfessionalContactState({
    this.status = ProfessionalContactStatus.idle,
    this.contactIntention,
    this.errorMessage,
  });

  final ProfessionalContactStatus status;
  final ProfessionalContactIntention? contactIntention;
  final String? errorMessage;

  bool get isBusy =>
      status == ProfessionalContactStatus.registeringContactIntention ||
      status == ProfessionalContactStatus.openingWhatsapp;

  bool get hasRegisteredContactIntention => contactIntention != null;

  bool get hasError =>
      status == ProfessionalContactStatus.failed &&
      errorMessage != null &&
      errorMessage!.trim().isNotEmpty;

  ProfessionalContactState copyWith({
    ProfessionalContactStatus? status,
    ProfessionalContactIntention? contactIntention,
    String? errorMessage,
  }) {
    return ProfessionalContactState(
      status: status ?? this.status,
      contactIntention: contactIntention ?? this.contactIntention,
      errorMessage: errorMessage,
    );
  }
}
