import 'package:flutter/foundation.dart';

import 'customer_profile_state.dart';

class CustomerProfileController extends ChangeNotifier {
  CustomerProfileController({
    required CustomerProfileState initialState,
    this.onPreferencesChanged,
  }) : _state = initialState;

  CustomerProfileState _state;
  final Future<CustomerProfileState> Function({
    required bool whatsappNotificationsEnabled,
    required bool profilePersonalizationEnabled,
  })? onPreferencesChanged;

  CustomerProfileState get state => _state;

  Future<void> changeWhatsappNotifications(bool enabled) async {
    _updateState(_state.copyWith(whatsappNotificationsEnabled: enabled));
    await _persistPreferences();
  }

  Future<void> changeProfilePersonalization(bool enabled) async {
    _updateState(_state.copyWith(profilePersonalizationEnabled: enabled));
    await _persistPreferences();
  }

  void logout() {
    _updateState(_state.copyWith(loggedOut: true));
  }

  void _updateState(CustomerProfileState state) {
    _state = state;
    notifyListeners();
  }

  Future<void> replaceState(CustomerProfileState state) async {
    _updateState(state);
  }

  Future<void> _persistPreferences() async {
    final preferencesUpdater = onPreferencesChanged;
    if (preferencesUpdater == null) {
      return;
    }
    final persistedState = await preferencesUpdater(
      whatsappNotificationsEnabled: _state.whatsappNotificationsEnabled,
      profilePersonalizationEnabled: _state.profilePersonalizationEnabled,
    );
    _updateState(persistedState);
  }
}
