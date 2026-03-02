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
import '../../domain/usecases/update_profile_use_case.dart';
import '../notifier/profile_notifier.dart';
import '../notifier/profile_state.dart';
import '../../domain/entities/user_entity.dart';

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

final registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  final useCase = ref.watch(registerUseCaseProvider);
  return RegisterNotifier(useCase);
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final useCase = ref.watch(loginUseCaseProvider);
  return LoginNotifier(useCase);
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final useCase = ref.watch(updateProfileUseCaseProvider);
  final loginNotifier = ref.watch(loginNotifierProvider.notifier);
  return ProfileNotifier(useCase, loginNotifier);
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  final loginState = ref.watch(loginNotifierProvider);
  if (loginState is LoginSuccess) {
    return loginState.user;
  }
  return null;
});
