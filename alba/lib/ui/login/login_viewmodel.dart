import 'package:alba/data/repositories/auth_repository.dart';
import 'package:alba/domain/dto/credentials_login_dto.dart';
import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:flutter/material.dart';

class LoginViewmodel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewmodel(this._authRepository);

  bool get isLoggedIn => _authRepository.isLoggedIn;

  Future<void> login(CredentialsLoginDto dto) async {
    try {
      await _authRepository.login(dto);
      notifyListeners();
    } catch (e) {
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await _authRepository.loginWithGoogle();
      notifyListeners();
      if (isLoggedIn) {
        await _authRepository.saveUserOnFirestore(
          _authRepository.currentUser!.uid,
          CredentialsRegisterDto(
            email: _authRepository.currentUser!.email!,
            password: '',
            confirmPassword: '',
          ),
        );
      }
    } catch (e) {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      print(e);
    }
  }
}
