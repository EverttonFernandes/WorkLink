// ignore_for_file: sort_constructors_first

class ContactIntention {
  const ContactIntention({
    required this.contactIntentIdentifier,
    required this.professionalIdentifier,
    required this.professionalName,
    required this.whatsappContactLink,
    required this.createdAt,
    required this.externalNegotiationNotice,
    required this.noServiceGuaranteeNotice,
  });

  final String contactIntentIdentifier;
  final String professionalIdentifier;
  final String professionalName;
  final String whatsappContactLink;
  final DateTime createdAt;
  final String externalNegotiationNotice;
  final String noServiceGuaranteeNotice;

  factory ContactIntention.fromJson(Map<String, dynamic> json) {
    return ContactIntention(
      contactIntentIdentifier:
          json['contactIntentIdentifier']?.toString() ?? '',
      professionalIdentifier: json['professionalIdentifier']?.toString() ?? '',
      professionalName: json['professionalName']?.toString() ?? '',
      whatsappContactLink: json['whatsappContactLink']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'].toString()),
      externalNegotiationNotice:
          json['externalNegotiationNotice']?.toString() ?? '',
      noServiceGuaranteeNotice:
          json['noServiceGuaranteeNotice']?.toString() ?? '',
    );
  }
}

class PostContactFeedback {
  const PostContactFeedback({
    required this.postContactFeedbackIdentifier,
    required this.contactIntentIdentifier,
    required this.conversationOutcome,
    required this.contactResponsiveness,
    required this.serviceExecutionOutcome,
    required this.createdAt,
  });

  final String postContactFeedbackIdentifier;
  final String contactIntentIdentifier;
  final String conversationOutcome;
  final String contactResponsiveness;
  final String serviceExecutionOutcome;
  final DateTime createdAt;

  factory PostContactFeedback.fromJson(Map<String, dynamic> json) {
    return PostContactFeedback(
      postContactFeedbackIdentifier:
          json['postContactFeedbackIdentifier']?.toString() ?? '',
      contactIntentIdentifier:
          json['contactIntentIdentifier']?.toString() ?? '',
      conversationOutcome: json['conversationOutcome']?.toString() ?? '',
      contactResponsiveness: json['contactResponsiveness']?.toString() ?? '',
      serviceExecutionOutcome:
          json['serviceExecutionOutcome']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}

class RegisterPostContactFeedbackRequest {
  const RegisterPostContactFeedbackRequest({
    required this.contactIntentIdentifier,
    required this.conversationOutcome,
    required this.contactResponsiveness,
    required this.serviceExecutionOutcome,
  });

  final String contactIntentIdentifier;
  final String conversationOutcome;
  final String contactResponsiveness;
  final String serviceExecutionOutcome;

  Map<String, Object?> toJson() {
    return {
      'contactIntentIdentifier': contactIntentIdentifier,
      'conversationOutcome': conversationOutcome,
      'contactResponsiveness': contactResponsiveness,
      'serviceExecutionOutcome': serviceExecutionOutcome,
    };
  }
}
