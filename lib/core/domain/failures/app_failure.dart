import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

@freezed
class AppFailure with _$AppFailure {
  const factory AppFailure.server({
    @Default('Erro no servidor') String message,
  }) = ServerFailure;

  const factory AppFailure.network({
    @Default('Sem conexão com a internet') String message,
  }) = NetworkFailure;

  const factory AppFailure.auth({
    @Default('Erro de autenticação') String message,
  }) = AuthFailure;

  const factory AppFailure.cache({
    @Default('Erro no cache local') String message,
  }) = CacheFailure;

  const factory AppFailure.unknown({
    @Default('Erro desconhecido') String message,
  }) = UnknownFailure;

  const factory AppFailure.validation({
    @Default('Dados inválidos') String message,
  }) = ValidationFailure;
}
