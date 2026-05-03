import '../../../core/enums/view_status.dart';

class SearchState {
  const SearchState({
    this.status = ViewStatus.initial,
    this.query = '',
    this.favorites = const <String>[],
    this.results = const <String>[],
    this.isSearching = false,
    this.message,
  });

  final ViewStatus status;
  final String query;
  final List<String> favorites;
  final List<String> results;
  final bool isSearching;
  final String? message;

  bool get isSearchMode => query.trim().isNotEmpty;

  SearchState copyWith({
    ViewStatus? status,
    String? query,
    List<String>? favorites,
    List<String>? results,
    bool? isSearching,
    String? message,
    bool clearMessage = false,
  }) {
    return SearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      favorites: favorites ?? this.favorites,
      results: results ?? this.results,
      isSearching: isSearching ?? this.isSearching,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
