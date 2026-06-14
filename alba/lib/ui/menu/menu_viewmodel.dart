import 'package:alba/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FirebaseFirestore _firestore;

  MenuViewModel(
    this._authRepository, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  bool isLoading = false;
  String? errorMessage;
  bool isEditing = false;

  Map<String, dynamic> perfil = {
    'nome': 'Name',
    'email': '',
    'telefone': '',
    'curso': 'Sistemas de Informação',
    'universidade': 'UFRPE',
    'periodo': '4º Período',
    'ramoNegocio': 'Alimentos',
  };

  Map<String, dynamic>? assinatura = {
    'statusAssinatura': 'Plano ativo',
    'valorPlano': 'R\$ 39,90',
    'dataRenovacao': '20/06/2026',
  };

  final nameController = TextEditingController();
  final cursoController = TextEditingController();
  final uniController = TextEditingController();
  final periodoController = TextEditingController();
  final phoneController = TextEditingController();

  void initControllers() {
    nameController.text = perfil['nome'] ?? '';
    cursoController.text = perfil['curso'] ?? '';
    uniController.text = perfil['universidade'] ?? '';
    periodoController.text = perfil['periodo'] ?? '';
    phoneController.text = perfil['telefone'] ?? '';
  }

  Future<void> carregarDadosUsuario() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final usuarioLogado = _authRepository.currentUser;

      if (usuarioLogado == null) {
        throw Exception('Usuário não autenticado.');
      }

      final uid = usuarioLogado.uid;
      final docRef = _firestore.collection('users').doc(uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        await docRef.set({
          'nome': usuarioLogado.displayName ?? 'Name',
          'email': usuarioLogado.email ?? '',
          'telefone': usuarioLogado.phoneNumber ?? '',
          'curso': 'Sistemas de Informação',
          'universidade': 'UFRPE',
          'periodo': '4º Período',
          'ramoNegocio': 'Alimentos',
          'assinatura': {
            'statusAssinatura': 'Plano ativo',
            'valorPlano': 'R\$ 39,90',
            'dataRenovacao': '20/06/2026',
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      final updatedDoc = await docRef.get();
      final data = updatedDoc.data() ?? {};

      perfil = {
        'nome': data['nome'] ?? 'Name',
        'email': data['email'] ?? usuarioLogado.email ?? '',
        'telefone': data['telefone'] ?? usuarioLogado.phoneNumber ?? '',
        'curso': data['curso'] ?? 'Sistemas de Informação',
        'universidade': data['universidade'] ?? 'UFRPE',
        'periodo': data['periodo'] ?? '4º Período',
        'ramoNegocio': data['ramoNegocio'] ?? 'Alimentos',
      };

      if (data['assinatura'] != null) {
        assinatura = Map<String, dynamic>.from(data['assinatura']);
      } else {
        assinatura = {
          'statusAssinatura': 'Plano ativo',
          'valorPlano': 'R\$ 39,90',
          'dataRenovacao': '20/06/2026',
        };
      }

      initControllers();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        errorMessage =
            'Sem permissão para acessar o perfil. Verifique as regras do Firestore.';
      } else {
        errorMessage = 'Erro do Firebase ao carregar perfil: ${e.message}';
      }
    } catch (e) {
      errorMessage = 'Erro ao carregar dados do perfil: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void alternarEdicao() {
    if (!isEditing) {
      initControllers();
    }

    isEditing = !isEditing;
    notifyListeners();
  }

  Future<void> salvarPerfil() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final usuarioLogado = _authRepository.currentUser;

      if (usuarioLogado == null) {
        throw Exception('Usuário não autenticado.');
      }

      final uid = usuarioLogado.uid;

      final dadosAtualizados = {
        'nome': nameController.text.trim(),
        'email': usuarioLogado.email ?? perfil['email'] ?? '',
        'curso': cursoController.text.trim(),
        'universidade': uniController.text.trim(),
        'periodo': periodoController.text.trim(),
        'telefone': phoneController.text.trim(),
        'ramoNegocio': perfil['ramoNegocio'] ?? '',
      };

      await _firestore.collection('users').doc(uid).set({
        ...dadosAtualizados,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      perfil = {
        ...perfil,
        ...dadosAtualizados,
      };

      isEditing = false;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        errorMessage =
            'Sem permissão para salvar o perfil. Verifique as regras do Firestore.';
      } else {
        errorMessage = 'Erro do Firebase ao salvar perfil: ${e.message}';
      }
    } catch (e) {
      errorMessage = 'Não foi possível salvar as alterações: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelarAssinatura(String motivo, String feedback) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final usuarioLogado = _authRepository.currentUser;

      if (usuarioLogado == null) {
        throw Exception('Usuário não autenticado.');
      }

      final uid = usuarioLogado.uid;

      await _firestore.collection('users').doc(uid).set({
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
        'email': usuarioLogado.email ?? '',
        'motivo': motivo,
        'feedbackAdicional': feedback,
        'data': FieldValue.serverTimestamp(),
      });

      assinatura = null;

      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        errorMessage =
            'Sem permissão para cancelar assinatura. Verifique as regras do Firestore.';
      } else {
        errorMessage =
            'Erro do Firebase ao processar cancelamento: ${e.message}';
      }

      return false;
    } catch (e) {
      errorMessage = 'Não foi possível processar o cancelamento: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    cursoController.dispose();
    uniController.dispose();
    periodoController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}