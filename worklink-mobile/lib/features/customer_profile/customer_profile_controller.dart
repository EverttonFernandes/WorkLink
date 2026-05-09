import 'package:flutter/foundation.dart';

import 'customer_profile_state.dart';

class CustomerProfileController extends ChangeNotifier {
  CustomerProfileController({
    required CustomerProfileState initialState,
  }) : _state = initialState;

  CustomerProfileState _state;

  CustomerProfileState get state => _state;

  void changeWhatsappNotifications(bool enabled) {
    _updateState(_state.copyWith(whatsappNotificationsEnabled: enabled));
  }

  void changeProfilePersonalization(bool enabled) {
    _updateState(_state.copyWith(profilePersonalizationEnabled: enabled));
  }

  void logout() {
    _updateState(_state.copyWith(loggedOut: true));
  }

  void _updateState(CustomerProfileState state) {
    _state = state;
    notifyListeners();
  }
}
