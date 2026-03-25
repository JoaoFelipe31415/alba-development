import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterViewmodel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthRepository _authRepository;

  RegisterViewmodel(this._authRepository);

  void register(CredentialsRegisterDto dto) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
        email: dto.email,
        password: dto.password,
      );
      if (result.user != null) {
        await _authRepository.saveUserOnFirestore(result.user!.uid, dto);
      }
    } catch (e) {
      print(e);
    }
  }
}
