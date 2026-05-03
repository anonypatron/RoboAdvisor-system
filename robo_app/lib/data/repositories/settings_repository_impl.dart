import '../../domain/repositories/settings_repository.dart';
import '../datasources/remote/robo_remote_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required RoboRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RoboRemoteDataSource _remoteDataSource;

  @override
  Future<String> getApiBaseUrl() async {
    return _remoteDataSource.baseUrl;
  }
}
