import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterViewmodel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void register(CredentialsRegisterDto dto) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
        email: dto.email,
        password: dto.password,
      );
    } catch (e) {
      print(e);
    }
  }
}
