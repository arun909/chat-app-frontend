import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/register_use_case.dart';
import 'register_state.dart';

class RegisterNotifier extends StateNotifier<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterNotifier(this._registerUseCase) : super(const RegisterInitial());

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    state = const RegisterLoading();
    try {
      final user = await _registerUseCase.execute(
        username: username,
        email: email,
        password: password,
      );
      state = RegisterSuccess(user);
    } catch (e) {
      state = RegisterError(e.toString());
    }
  }
}
