import '../entities/{{feature_snake}}.dart';
import '../repositories/{{feature_snake}}_repository.dart';

class Get{{feature_pascal}} {
  const Get{{feature_pascal}}(this._repository);

  final {{feature_pascal}}Repository _repository;

  Future<{{feature_pascal}}> call() {
    return _repository.get{{feature_pascal}}();
  }
}
