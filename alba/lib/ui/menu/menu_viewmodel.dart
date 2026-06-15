import 'dart:async';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MenuViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;
  StreamSubscription<DocumentSnapshot>? _perfilSubscription;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  MenuViewModel(this._authRepository, {FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    escutarDadosUsuario();
  }

  bool isLoading = false;
  String? errorMessage;
  bool isEditing = false;
  File? imagemArquivoAndroid;
  String? fotoUrl;

  Map<String, dynamic> perfil = {
    'nome': '',
    'email': '',
    'telefone': '',
    'curso': '',
    'universidade': '',
    'periodo': '',
    'ramoNegocio': 'Alimentos',
  };

  Map<String, dynamic>? assinatura;

  final nameController = TextEditingController();
  final cursoController = TextEditingController();
  final uniController = TextEditingController();
  final periodoController = TextEditingController();
  final phoneController = TextEditingController();

  String? _obterCelularIdDiretoDoAuth() {
    final usuarioLogado = _authRepository.currentUser;
    if (usuarioLogado == null) return null;

    if (usuarioLogado.phoneNumber != null &&
        usuarioLogado.phoneNumber!.isNotEmpty) {
      String puro = usuarioLogado.phoneNumber!.replaceAll('+', '').trim();
      return puro.startsWith('55') ? puro : '55$puro';
    }
    return null;
  }

  Future<void> selecionarFotoPerfil() async {
    try {
      final XFile? imagemSelecionada = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 400,
      );

      if (imagemSelecionada != null) {
        imagemArquivoAndroid = File(imagemSelecionada.path);
        notifyListeners();
        await fazerUploadFotoAndroid();
      }
    } catch (e) {
      errorMessage = 'Erro ao acessar a galeria do Android: $e';
      notifyListeners();
    }
  }

  Future<void> fazerUploadFotoAndroid() async {
    final String celularId = perfil['telefone'] ?? '';
    if (celularId.isEmpty || imagemArquivoAndroid == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final ref = _storage.ref().child('perfil_fotos').child('$celularId.jpg');

      final snapshot = await ref.putFile(imagemArquivoAndroid!);

      final urlDownload = await snapshot.ref.getDownloadURL();

      fotoUrl = urlDownload;
      perfil['fotoUrl'] = urlDownload;

      await _firestore.collection('Users').doc(celularId).set({
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

  Future<void> escutarDadosUsuario() async {
    final usuarioLogado = _authRepository.currentUser;
    if (usuarioLogado == null) {
      print("[AVISO] Nenhum usuário logado no Firebase Auth.");
      return;
    }

    _perfilSubscription?.cancel();

    String? celularId = _obterCelularIdDiretoDoAuth();

    if (celularId == null) {
      try {
        final querySnapshot = await _firestore
            .collection('Users')
            .where('uid', isEqualTo: usuarioLogado.uid)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          celularId = querySnapshot.docs.first.id;
        } else if (usuarioLogado.email != null) {
          final queryEmail = await _firestore
              .collection('Users')
              .where('email', isEqualTo: usuarioLogado.email)
              .limit(1)
              .get();

          if (queryEmail.docs.isNotEmpty) {
            celularId = queryEmail.docs.first.id;
          }
        }
      } catch (e) {
        print("Erro ao localizar ID do documento do usuário: $e");
      }
    }

    _perfilSubscription = _firestore
        .collection('Users')
        .doc(celularId)
        .snapshots()
        .listen(
          (docSnapshot) {
            if (docSnapshot.exists) {
              final data = docSnapshot.data() ?? {};

              perfil = {
                'nome': data['nome'] ?? '',
                'email': data['email'] ?? (usuarioLogado.email ?? ''),
                'telefone': docSnapshot.id,
                'phone': data['phone'] ?? docSnapshot.id,
                'uid': data['uid'] ?? usuarioLogado.uid,
                'curso': data['curso'] ?? '',
                'universidade': data['universidade'] ?? '',
                'periodo': data['periodo'] ?? '',
                'ramoNegocio': data['ramoNegocio'] ?? 'Alimentos',
              };

              if (data['assinatura'] != null && data['assinatura'] is Map) {
                assinatura = Map<String, dynamic>.from(data['assinatura']);
              } else {
                assinatura = null;
              }

              if (!isEditing) {
                initControllers();
              }

              notifyListeners();
            }
          },
          onError: (e) {
            errorMessage = 'Erro no Stream de perfil: $e';
            notifyListeners();
          },
        );
  }

  Future<void> activarAssinaturaTeste() async {
    final String celularId = perfil['telefone'] ?? '';
    if (celularId.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(celularId).set({
        'assinatura': {
          'statusAssinatura': 'Plano ativo',
          'valorPlano': 'R\$ 39,90',
          'dataRenovacao': '15/07/2026',
          'createdAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Erro ao ativar assinatura de teste: $e");
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

  Future<void> salvarPerfil() async {
    final String celularId = perfil['telefone'] ?? '';

    if (celularId.isEmpty) {
      errorMessage = 'Erro: Identificador do perfil não encontrado.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final dadosParaAcrescentar = {
        'nome': nameController.text.trim(),
        'email': perfil['email'],
        'curso': cursoController.text.trim(),
        'universidade': uniController.text.trim(),
        'periodo': periodoController.text.trim(),
        'ramoNegocio': perfil['ramoNegocio'] ?? 'Alimentos',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('Users')
          .doc(celularId)
          .set(dadosParaAcrescentar, SetOptions(merge: true));

      isEditing = false;
    } catch (e) {
      errorMessage = 'Não foi possível salvar as alterações: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelarAssinatura(String motivo, String feedback) async {
    final String celularId = perfil['telefone'] ?? '';

    if (celularId.isEmpty) {
      errorMessage = 'Erro de autenticação: Identificador do perfil inválido.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(celularId).set({
        'assinatura': {
          'statusAssinatura': 'Plano cancelado',
          'valorPlano': assinatura?['valorPlano'] ?? 'R\$ 39,90',
          'dataRenovacao': assinatura?['dataRenovacao'] ?? '',
          'dataCancelamento': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('feedbacks_cancelamento').add({
        'userId': celularId,
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
    final String celularId = perfil['telefone'] ?? '';

    if (celularId.isEmpty) {
      errorMessage = 'Erro: Identificador do perfil não encontrado.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(celularId).set({
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
