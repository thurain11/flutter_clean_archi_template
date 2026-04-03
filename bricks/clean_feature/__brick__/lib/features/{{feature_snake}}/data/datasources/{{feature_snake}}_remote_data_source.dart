import '../models/{{feature_snake}}_model.dart';

abstract class {{feature_pascal}}RemoteDataSource {
  Future<{{feature_pascal}}Model> get{{feature_pascal}}();
}

class {{feature_pascal}}RemoteDataSourceImpl
    implements {{feature_pascal}}RemoteDataSource {
  const {{feature_pascal}}RemoteDataSourceImpl();

  @override
  Future<{{feature_pascal}}Model> get{{feature_pascal}}() async {
    // TODO: Replace with real API integration.
    return const {{feature_pascal}}Model(id: '1');
  }
}
