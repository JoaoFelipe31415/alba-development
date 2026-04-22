import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Retorna o ID do usuário logado no Firebase
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream para monitorar se o usuário deslogou ou logou
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Método simples de login para o Pitch
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password,
    );
  }

  Future<void> logout() async => await _auth.signOut();
}