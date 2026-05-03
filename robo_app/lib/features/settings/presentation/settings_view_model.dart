import 'package:flutter/foundation.dart';

import '../../../core/enums/view_status.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../utils/logger.dart';
import 'settings_state.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required SettingsRepository repository})
    : _repository = repository;

  final SettingsRepository _repository;

  SettingsState _state = const SettingsState();

  SettingsState get state => _state;

  Future<void> load() async {
    _state = _state.copyWith(status: ViewStatus.loading, clearMessage: true);
    notifyListeners();

    try {
      final String apiUrl = await _repository.getApiBaseUrl();
      _state = _state.copyWith(status: ViewStatus.success, apiUrl: apiUrl);
    } catch (error, stackTrace) {
      logger.e('settings load failed', error: error, stackTrace: stackTrace);
      _state = _state.copyWith(
        status: ViewStatus.error,
        message: 'Failed to load settings.',
      );
    }

    notifyListeners();
  }
}
