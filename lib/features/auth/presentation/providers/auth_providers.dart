import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../notifier/login_notifier.dart';
import '../notifier/login_state.dart';
import '../notifier/register_notifier.dart';
import '../notifier/register_state.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSource(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final registerNotifierProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  final useCase = ref.watch(registerUseCaseProvider);
  return RegisterNotifier(useCase);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final loginNotifierProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final useCase = ref.watch(loginUseCaseProvider);
  return LoginNotifier(useCase);
});
