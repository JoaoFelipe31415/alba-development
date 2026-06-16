import 'dart:async';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MenuViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<DocumentSnapshot>? _perfilSubscription;

  MenuViewModel(this._authRepository, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    escutarDadosUsuario();
  }

  bool isLoading = false;
  String? errorMessage;
  bool isEditing = false;
  String? fotoUrl;

  Map<String, dynamic> perfil = {
    'uid': '',
    'nome': '',
    'email': '',
    'telefone': '',
    'curso': '',
    'universidade': '',
    'periodo': '',
    'ramoNegocio': 'Alimentos',
    'fotoUrl': '',
  };

  Map<String, dynamic>? assinatura;

  final nameController = TextEditingController();
  final cursoController = TextEditingController();
  final uniController = TextEditingController();
  final periodoController = TextEditingController();
  final phoneController = TextEditingController();

  String _emailNormalizado(String? email) {
    return (email ?? '').trim().toLowerCase();
  }

  Future<void> escutarDadosUsuario() async {
    final usuarioLogado = _authRepository.currentUser;

    if (usuarioLogado == null) {
      errorMessage = 'Nenhum usuário autenticado.';
      notifyListeners();
      return;
    }

    _perfilSubscription?.cancel();

    final uid = usuarioLogado.uid;
    final email = _emailNormalizado(usuarioLogado.email);

    final docRef = _firestore.collection('Users').doc(uid);

    try {
      final docAtual = await docRef.get();

      if (!docAtual.exists) {
        await docRef.set({
          'uid': uid,
          'email': email,
          'emailLower': email,
          'nome': usuarioLogado.displayName ?? '',
          'telefone': usuarioLogado.phoneNumber ?? '',
          'curso': '',
          'universidade': '',
          'periodo': '',
          'ramoNegocio': 'Alimentos',
          'fotoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      _perfilSubscription = docRef.snapshots().listen(
        (docSnapshot) {
          if (!docSnapshot.exists) return;

          final data = docSnapshot.data() ?? {};

          perfil = {
            'uid': data['uid'] ?? uid,
            'nome': data['nome'] ?? '',
            'email': data['email'] ?? email,
            'telefone': data['telefone'] ?? '',
            'phone': data['phone'] ?? data['telefone'] ?? '',
            'curso': data['curso'] ?? '',
            'universidade': data['universidade'] ?? '',
            'periodo': data['periodo'] ?? '',
            'ramoNegocio': data['ramoNegocio'] ?? 'Alimentos',
            'fotoUrl': data['fotoUrl'] ?? '',
          };

          fotoUrl = data['fotoUrl'] ?? '';

          if (data['assinatura'] != null && data['assinatura'] is Map) {
            assinatura = Map<String, dynamic>.from(data['assinatura']);
          } else {
            assinatura = null;
          }

          if (!isEditing) {
            initControllers();
          }

          notifyListeners();
        },
        onError: (e) {
          errorMessage = 'Erro ao carregar perfil: $e';
          notifyListeners();
        },
      );
    } catch (e) {
      errorMessage = 'Erro ao localizar ou criar perfil: $e';
      notifyListeners();
    }
  }

  Future<void> selecionarFotoPerfil() async {
    final usuarioLogado = _authRepository.currentUser;

    if (usuarioLogado == null) {
      errorMessage = 'Erro: usuário não autenticado.';
      notifyListeners();
      return;
    }

    try {
      final XFile? imagemSelecionada = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 600,
      );

      if (imagemSelecionada == null) return;

      await fazerUploadFotoPerfil(imagemSelecionada);
    } catch (e) {
      errorMessage = 'Erro ao selecionar foto de perfil: $e';
      notifyListeners();
    }
  }

  Future<void> fazerUploadFotoPerfil(XFile imagemSelecionada) async {
    final usuarioLogado = _authRepository.currentUser;

    if (usuarioLogado == null) {
      errorMessage = 'Erro: usuário não autenticado.';
      notifyListeners();
      return;
    }

    final uid = usuarioLogado.uid;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final bytes = await imagemSelecionada.readAsBytes();

      final ref = _storage.ref().child('perfil_fotos').child('$uid.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uid': uid,
        },
      );

      final uploadTask = await ref.putData(bytes, metadata);
      final urlDownload = await uploadTask.ref.getDownloadURL();

      fotoUrl = urlDownload;
      perfil['fotoUrl'] = urlDownload;

      await _firestore.collection('Users').doc(uid).set({
        'uid': uid,
        'fotoUrl': urlDownload,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      errorMessage = 'Erro ao salvar a foto no Firebase: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> salvarPerfil() async {
    final usuarioLogado = _authRepository.currentUser;

    if (usuarioLogado == null) {
      errorMessage = 'Erro: usuário autenticado não encontrado.';
      notifyListeners();
      return;
    }

    final uid = usuarioLogado.uid;
    final email = _emailNormalizado(usuarioLogado.email);

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final dadosParaSalvar = {
        'uid': uid,
        'nome': nameController.text.trim(),
        'email': email,
        'emailLower': email,
        'telefone': phoneController.text.trim(),
        'curso': cursoController.text.trim(),
        'universidade': uniController.text.trim(),
        'periodo': periodoController.text.trim(),
        'ramoNegocio': perfil['ramoNegocio'] ?? 'Alimentos',
        'fotoUrl': perfil['fotoUrl'] ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('Users')
          .doc(uid)
          .set(dadosParaSalvar, SetOptions(merge: true));

      isEditing = false;
    } catch (e) {
      errorMessage = 'Não foi possível salvar as alterações: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> activarAssinaturaTeste() async {
    final usuarioLogado = _authRepository.currentUser;

    if (usuarioLogado == null) {
      errorMessage = 'Erro: usuário autenticado não encontrado.';
      notifyListeners();
      return;
    }

    final uid = usuarioLogado.uid;

    isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(uid).set({
        'assinatura': {
          'statusAssinatura': 'Plano ativo',
          'valorPlano': 'R\$ 39,90',
          'dataRenovacao': '15/07/2026',
          'createdAt': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      errorMessage = 'Erro ao ativar assinatura de teste: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelarAssinatura(String motivo, String feedback) async {
    final usuarioLogado = _authRepository.currentUser;

    if (usuarioLogado == null) {
      errorMessage = 'Erro de autenticação: usuário inválido.';
      notifyListeners();
      return false;
    }

    final uid = usuarioLogado.uid;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(uid).set({
        'assinatura': {
          'statusAssinatura': 'Plano cancelado',
          'valorPlano': assinatura?['valorPlano'] ?? 'R\$ 39,90',
          'dataRenovacao': assinatura?['dataRenovacao'] ?? '',
          'dataCancelamento': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('feedbacks_cancelamento').add({
        'userId': uid,
        'email': perfil['email'] ?? '',
        'motivo': motivo,
        'feedbackAdicional': feedback,
        'data': FieldValue.serverTimestamp(),
      });

      assinatura = null;
      return true;
    } catch (e) {
      errorMessage = 'Não foi possível processar o cancelamento: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reativarAssinatura() async {
    final usuarioLogado = _authRepository.currentUser;

    if (usuarioLogado == null) {
      errorMessage = 'Erro: usuário autenticado não encontrado.';
      notifyListeners();
      return false;
    }

    final uid = usuarioLogado.uid;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(uid).set({
        'assinatura': {
          'statusAssinatura': 'Plano ativo',
          'valorPlano': 'R\$ 39,90',
          'dataRenovacao': '20/06/2026',
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      errorMessage = 'Não foi possível reativar a assinatura: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get telefoneFormatado {
    final tel = perfil['telefone']?.toString() ?? '';

    final apenasNumeros = tel.replaceAll(RegExp(r'\D'), '');

    if (apenasNumeros.length == 13) {
      final ddd = apenasNumeros.substring(2, 4);
      final parte1 = apenasNumeros.substring(4, 9);
      final parte2 = apenasNumeros.substring(9, 13);
      return '+55 ($ddd) $parte1-$parte2';
    }

    if (apenasNumeros.length == 11) {
      final ddd = apenasNumeros.substring(0, 2);
      final parte1 = apenasNumeros.substring(2, 7);
      final parte2 = apenasNumeros.substring(7, 11);
      return '+55 ($ddd) $parte1-$parte2';
    }

    return tel;
  }

  void initControllers() {
    nameController.text = perfil['nome'] ?? '';
    cursoController.text = perfil['curso'] ?? '';
    uniController.text = perfil['universidade'] ?? '';
    periodoController.text = perfil['periodo'] ?? '';
    phoneController.text = perfil['telefone'] ?? '';
  }

  void alternarEdicao() {
    if (!isEditing) {
      initControllers();
    }

    isEditing = !isEditing;
    notifyListeners();
  }

  @override
  void dispose() {
    _perfilSubscription?.cancel();
    nameController.dispose();
    cursoController.dispose();
    uniController.dispose();
    periodoController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}