import '../../domain/entities/{{feature_snake}}.dart';

class {{feature_pascal}}Model extends {{feature_pascal}} {
  const {{feature_pascal}}Model({required super.id});

  factory {{feature_pascal}}Model.fromJson(Map<String, dynamic> json) {
    return {{feature_pascal}}Model(
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
