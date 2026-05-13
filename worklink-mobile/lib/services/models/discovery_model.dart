// ignore_for_file: sort_constructors_first

import 'professional_model.dart';

class DiscoveryResult {
  const DiscoveryResult({
    required this.professionals,
  });

  final List<Professional> professionals;

  factory DiscoveryResult.fromJsonList(List<dynamic> jsonList) {
    return DiscoveryResult(
      professionals: jsonList
          .map(
            (json) => Professional.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList(),
    );
  }
}

class DiscoveryRequest {
  const DiscoveryRequest({
    this.categoryIdentifier,
    this.cityIdentifier,
    this.cityIdentifiers = const [],
    this.keyword,
  });

  final String? categoryIdentifier;
  final String? cityIdentifier;
  final List<String> cityIdentifiers;
  final String? keyword;

  Map<String, Object?> toQueryParameters() {
    return {
      'categoryIdentifier': categoryIdentifier,
      'cityIdentifier': cityIdentifier,
      if (cityIdentifiers.isNotEmpty) 'cityIdentifiers': cityIdentifiers,
      'keyword': keyword,
    };
  }
}
