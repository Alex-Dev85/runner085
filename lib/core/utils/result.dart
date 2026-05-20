import 'package:runner085/core/domain/failures/app_failure.dart';

/// A Result type that represents either a success or a failure.
/// Inspired by Kotlin's Result and Rust's Result types.
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppFailure failure) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final failure) => failure,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) {
      return success(self.data);
    }
    return failure((self as Failure<T>).failure);
  }

  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success<T>(:final data) => Result.success(transform(data)),
        Failure<T>(:final failure) => Result.failure(failure),
      };
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}
