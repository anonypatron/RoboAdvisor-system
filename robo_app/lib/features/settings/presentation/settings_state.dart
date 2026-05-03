import '../../../core/enums/view_status.dart';

class SettingsState {
  const SettingsState({
    this.status = ViewStatus.initial,
    this.apiUrl = '',
    this.message,
  });

  final ViewStatus status;
  final String apiUrl;
  final String? message;

  SettingsState copyWith({
    ViewStatus? status,
    String? apiUrl,
    String? message,
    bool clearMessage = false,
  }) {
    return SettingsState(
      status: status ?? this.status,
      apiUrl: apiUrl ?? this.apiUrl,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
