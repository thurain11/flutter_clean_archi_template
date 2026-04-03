enum {{feature_pascal}}Status { initial, loading, loaded, error }

class {{feature_pascal}}State {
  const {{feature_pascal}}State({
    this.status = {{feature_pascal}}Status.initial,
    this.errorMessage,
  });

  final {{feature_pascal}}Status status;
  final String? errorMessage;

  {{feature_pascal}}State copyWith({
    {{feature_pascal}}Status? status,
    String? errorMessage,
  }) {
    return {{feature_pascal}}State(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
