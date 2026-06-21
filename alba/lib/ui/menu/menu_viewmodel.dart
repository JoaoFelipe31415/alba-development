import 'dart:async';
import 'dart:convert';
import 'package:alba/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MenuViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;
  final ImagePicker _picker = ImagePicker();

  StreamSubscription<DocumentSnapshot>? _perfilSubscription;
  String? _idDocumentoAtual;

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
    'phone': '',
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
  final emailController = TextEditingController();

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

    try {
      isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('Users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      DocumentReference docRef;

      if (querySnapshot.docs.isNotEmpty) {
        final docEncontrado = querySnapshot.docs.first;
        _idDocumentoAtual = docEncontrado.id;
        docRef = _firestore.collection('Users').doc(_idDocumentoAtual);
      } else {
        String identificador = usuarioLogado.phoneNumber ?? uid;
        identificador = identificador.replaceAll(RegExp(r'\D'), '');
        if (identificador.isEmpty) identificador = uid;

        _idDocumentoAtual = identificador;
        docRef = _firestore.collection('Users').doc(_idDocumentoAtual);

        await docRef.set({
          'uid': uid,
          'email': _emailNormalizado(usuarioLogado.email),
          'emailLower': _emailNormalizado(usuarioLogado.email),
          'nome': usuarioLogado.displayName ?? '',
          'phone': usuarioLogado.phoneNumber ?? '',
          'curso': '',
          'universidade': '',
          'periodo': '',
          'ramoNegocio': 'Alimentos',
          'fotoUrl': '',
          'data_cadastro': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      _perfilSubscription = docRef.snapshots().listen(
        (docSnapshot) {
          if (!docSnapshot.exists) return;
          final Map<String, dynamic> data =
              docSnapshot.data() as Map<String, dynamic>? ?? {};

          perfil = {
            'uid': data['uid'] ?? uid,
            'nome': data['nome'] ?? '',
            'email': data['email'] ?? '',
            'phone': data['phone'] ?? data['telefone'] ?? _idDocumentoAtual,
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

          isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          errorMessage = 'Erro ao carregar perfil: $e';
          isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      errorMessage = 'Erro ao localizar perfil: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selecionarFotoPerfil() async {
    try {
      final XFile? imagemSelecionada = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 400,
      );

      if (imagemSelecionada == null) return;

      await fazerUploadFotoPerfil(imagemSelecionada);
    } catch (e) {
      errorMessage = 'Erro ao selecionar foto de perfil: $e';
      notifyListeners();
    }
  }

  Future<void> fazerUploadFotoPerfil(XFile imagemSelecionada) async {
    if (_idDocumentoAtual == null || _idDocumentoAtual!.isEmpty) {
      errorMessage = 'Erro: Identificador do usuário não localizado.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final bytes = await imagemSelecionada.readAsBytes();
      final base64Image = base64Encode(bytes);
      final fotoStringFinal = "data:image/jpeg;base64,$base64Image";

      fotoUrl = fotoStringFinal;
      perfil['fotoUrl'] = fotoStringFinal;

      await _firestore.collection('Users').doc(_idDocumentoAtual).set({
        'fotoUrl': fotoStringFinal,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      errorMessage = 'Erro ao processar e salvar a foto: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> salvarPerfil(String senhaAtual) async {
    final usuarioLogado = _authRepository.currentUser;

    if (_idDocumentoAtual == null || usuarioLogado == null) {
      errorMessage = 'Erro: Usuário não autenticado.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final novoEmail = _emailNormalizado(emailController.text);
      final emailAntigo = _emailNormalizado(perfil['email']);

      if (novoEmail != emailAntigo) {
        if (senhaAtual.trim().isEmpty) {
          throw Exception(
            'A senha atual é obrigatória para alterar o e-mail de login.',
          );
        }

        AuthCredential credential = EmailAuthProvider.credential(
          email: emailAntigo,
          password: senhaAtual,
        );

        await usuarioLogado.reauthenticateWithCredential(credential);

        await usuarioLogado.verifyBeforeUpdateEmail(novoEmail);
      }

      final dadosParaSalvar = {
        'nome': nameController.text.trim(),
        'email': novoEmail,
        'emailLower': novoEmail,
        'curso': cursoController.text.trim(),
        'universidade': uniController.text.trim(),
        'periodo': periodoController.text.trim(),
        'ramoNegocio': perfil['ramoNegocio'] ?? 'Alimentos',
        'fotoUrl': perfil['fotoUrl'] ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('Users')
          .doc(_idDocumentoAtual)
          .set(dadosParaSalvar, SetOptions(merge: true));

      isEditing = false;
      return true;
    } catch (e) {
      if (e.toString().contains('wrong-password')) {
        errorMessage = 'A senha atual informada está incorreta.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'O formato do novo e-mail é inválido.';
      } else {
        errorMessage = 'Erro ao atualizar: $e';
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> activarAssinaturaTeste() async {
    if (_idDocumentoAtual == null) return;

    isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(_idDocumentoAtual).set({
        'assinatura': {
          'statusAssinatura': 'Plano ativo',
          'valorPlano': 'R\$ 39,90',
          'dataRenovacao': '20/06/2026',
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
    if (_idDocumentoAtual == null) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(_idDocumentoAtual).set({
        'assinatura': {
          'statusAssinatura': 'Plano cancelado',
          'valorPlano': assinatura?['valorPlano'] ?? 'R\$ 39,90',
          'dataRenovacao': assinatura?['dataRenovacao'] ?? '',
          'dataCancelamento': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('feedbacks_cancelamento').add({
        'userId': perfil['uid'] ?? '',
        'phone': perfil['phone'] ?? _idDocumentoAtual,
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
    if (_idDocumentoAtual == null) return false;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('Users').doc(_idDocumentoAtual).set({
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

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await _perfilSubscription?.cancel();
      await _authRepository.logout();
    } catch (e) {
      errorMessage = 'Erro ao sair da conta: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get telefoneFormatado {
    final tel = perfil['phone']?.toString() ?? '';
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
    emailController.text = perfil['email'] ?? '';
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
    emailController.dispose();
    super.dispose();
  }
}
