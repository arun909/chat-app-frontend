import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_use_case.dart';
import 'login_state.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginNotifier(this._loginUseCase) : super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    state = const LoginLoading();
    try {
      final user = await _loginUseCase.execute(email: email, password: password);
      state = LoginSuccess(user);
    } catch (e) {
      state = LoginError(e.toString());
    }
  }
}