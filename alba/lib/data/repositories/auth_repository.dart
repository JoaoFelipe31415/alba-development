import 'package:alba/domain/dto/credentials_login_dto.dart';
import 'package:alba/domain/dto/credentials_register_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoggedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;

  Future<void> login(CredentialsLoginDto dto) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: dto.email,
        password: dto.password,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> register(CredentialsRegisterDto dto) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: dto.email,
        password: dto.password,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      var teste = _auth.currentUser;
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveUserOnFirestore(
    String uid,
    CredentialsRegisterDto dto,
  ) async {
    try {
      var data = {
        'uid': uid,
        'email': dto.email,
        'data_cadastro': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('Users').doc(uid).set(data);
    } catch (e) {
      rethrow;
    }
  }
}
