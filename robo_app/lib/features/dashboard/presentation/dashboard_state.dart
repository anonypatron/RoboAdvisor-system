import '../../../core/enums/view_status.dart';
import '../../../domain/entities/dashboard_entity.dart';

class DashboardState {
  const DashboardState({
    this.status = ViewStatus.initial,
    this.data,
    this.message,
    this.isSubmittingTrade = false,
  });

  final ViewStatus status;
  final DashboardEntity? data;
  final String? message;
  final bool isSubmittingTrade;

  DashboardState copyWith({
    ViewStatus? status,
    DashboardEntity? data,
    String? message,
    bool clearMessage = false,
    bool? isSubmittingTrade,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      message: clearMessage ? null : message ?? this.message,
      isSubmittingTrade: isSubmittingTrade ?? this.isSubmittingTrade,
    );
  }
}
