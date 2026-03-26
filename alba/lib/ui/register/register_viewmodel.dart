import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterViewmodel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthRepository _authRepository;

  RegisterViewmodel(this._authRepository);

  RegisterState _state = RegisterStateIdle();
  RegisterState get state => _state;

  void register(CredentialsRegisterDto dto) async {
    try {
      _state = RegisterStateLoading();
      notifyListeners();
      var result = await _auth.createUserWithEmailAndPassword(
        email: dto.email,
        password: dto.password,
      );
      if (result.user != null) {
        await _authRepository.saveUserOnFirestore(result.user!.uid, dto);
      }
      _state = RegisterStateSuccess();
      notifyListeners();
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            _state = RegisterStateError('Email já cadastrado');
            break;
          case 'weak-password':
            _state = RegisterStateError('Senha fraca');
            break;
          default:
            _state = RegisterStateError("Erro ao cadastrar usuário");
        }
      } else {
        _state = RegisterStateError("Erro ao cadastrar usuário");
      }
      notifyListeners();
    }
  }
}

sealed class RegisterState {}

class RegisterStateIdle extends RegisterState {}

class RegisterStateLoading extends RegisterState {}

class RegisterStateSuccess extends RegisterState {}

class RegisterStateError extends RegisterState {
  final String message;
  RegisterStateError(this.message);
}
