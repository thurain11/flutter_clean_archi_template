import '../../domain/entities/{{feature_snake}}.dart';
import '../../domain/repositories/{{feature_snake}}_repository.dart';
import '../datasources/{{feature_snake}}_remote_data_source.dart';

class {{feature_pascal}}RepositoryImpl implements {{feature_pascal}}Repository {
  const {{feature_pascal}}RepositoryImpl(this._remoteDataSource);

  final {{feature_pascal}}RemoteDataSource _remoteDataSource;

  @override
  Future<{{feature_pascal}}> get{{feature_pascal}}() {
    return _remoteDataSource.get{{feature_pascal}}();
  }
}
