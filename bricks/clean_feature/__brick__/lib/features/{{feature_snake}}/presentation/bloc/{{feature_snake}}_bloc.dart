import 'package:bloc/bloc.dart';

import '../../domain/usecases/get_{{feature_snake}}.dart';
import '{{feature_snake}}_event.dart';
import '{{feature_snake}}_state.dart';

class {{feature_pascal}}Bloc
    extends Bloc<{{feature_pascal}}Event, {{feature_pascal}}State> {
  {{feature_pascal}}Bloc(this._get{{feature_pascal}})
      : super(const {{feature_pascal}}State()) {
    on<Fetch{{feature_pascal}}Requested>(_onFetchRequested);
  }

  final Get{{feature_pascal}} _get{{feature_pascal}};

  Future<void> _onFetchRequested(
    Fetch{{feature_pascal}}Requested event,
    Emitter<{{feature_pascal}}State> emit,
  ) async {
    emit(state.copyWith(status: {{feature_pascal}}Status.loading));

    try {
      await _get{{feature_pascal}}();
      emit(state.copyWith(status: {{feature_pascal}}Status.loaded));
    } catch (error) {
      emit(
        state.copyWith(
          status: {{feature_pascal}}Status.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
