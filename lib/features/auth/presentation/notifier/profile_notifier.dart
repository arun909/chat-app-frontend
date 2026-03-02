import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import 'profile_state.dart';
import 'login_state.dart';
import 'login_notifier.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UpdateProfileUseCase _updateProfileUseCase;
  final StateNotifier<LoginState> _loginNotifier;

  ProfileNotifier(this._updateProfileUseCase, this._loginNotifier)
      : super(const ProfileInitial());

  Future<void> updateProfile({
    required String token,
    String? username,
    String? email,
    String? password,
    File? profilePicFile,
  }) async {
    state = const ProfileLoading();
    try {
      final updatedUser = await _updateProfileUseCase.execute(
        token: token,
        username: username,
        email: email,
        password: password,
        profilePicFile: profilePicFile,
      );
      // Update the login state so all screens see the refreshed user data
      (_loginNotifier as LoginNotifier).setUser(updatedUser);
      state = ProfileSuccess(updatedUser);
    } catch (e) {
      state = ProfileError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const ProfileInitial();
}
