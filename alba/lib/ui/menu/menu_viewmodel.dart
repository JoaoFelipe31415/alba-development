import 'package:alba/data/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  MenuViewModel(this._authRepository);

  bool isLoading = false;
  String? errorMessage;
  bool isEditing = false;

  // Mapa de perfil iniciado com dados locais, mas o e-mail será dinâmico
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

      if (usuarioLogado != null) {
        perfil['email'] = usuarioLogado.email ?? '';

        if (usuarioLogado.phoneNumber != null &&
            usuarioLogado.phoneNumber!.isNotEmpty) {
          perfil['telefone'] = usuarioLogado.phoneNumber;
        } else {
          perfil['telefone'] =
              '(81) 99999-9999'; // ✨ Garante que aparece algo no Chrome
        }
      }

      initControllers();
    } catch (e) {
      errorMessage = "Erro ao carregar dados do perfil.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //   try {
  //     // ✨ BUSCA O E-MAIL DO BANCO:
  //     // Acessa o getter do repositório (ex: currentUser, user, ou similar de acordo com a implementação do Romário)
  //     final usuarioLogado = _authRepository
  //         .currentUser; // Altere para a propriedade correta do seu AuthRepository se necessário

  //     if (usuarioLogado != null) {
  //       // Se o objeto de usuário do seu pacote tiver .email, usamos ele
  //       perfil['email'] = usuarioLogado.email ?? 'usuario@alba.com';
  //     } else {
  //       perfil['email'] = 'usuario@alba.com';
  //     }

  //     // O Romário conectará o repositório de banco de dados (Firestore) para o resto aqui depois
  //     await Future.delayed(const Duration(milliseconds: 200));
  //     initControllers();
  //   } catch (e) {
  //     errorMessage = "Não foi possível carregar suas informações.";
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

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
      await Future.delayed(const Duration(milliseconds: 300));
      perfil['nome'] = nameController.text;
      perfil['curso'] = cursoController.text;
      perfil['universidade'] = uniController.text;
      perfil['periodo'] = periodoController.text;
      perfil['telefone'] = phoneController.text;
      isEditing = false;
    } catch (e) {
      errorMessage = "Não foi possível salvar as alterações.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🛑 CANCELAMENTO DE ASSINATURA (Estruturado para o Romário plugar o Back)
  Future<bool> cancelarAssinatura(String motivo, String feedback) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final usuarioLogado = _authRepository.currentUser;

      if (usuarioLogado != null) {
        final uid = usuarioLogado.uid;

        /* TODO (Romário): Código de conexão com o banco aqui:
          
          // 1. Atualiza o status do usuário no Firestore para cancelado
          await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
            'statusAssinatura': 'cancelado',
            'dataCancelamento': DateTime.now().toIso8601String(),
          });

          // 2. Registra o feedback em uma coleção de métricas para o time de negócios
          await FirebaseFirestore.instance.collection('feedbacks_cancelamento').add({
            'userId': uid,
            'motivo': motivo,
            'feedbackAdicional': feedback,
            'data': DateTime.now().toIso8601String(),
          });
        */

        // Simulando a resposta do servidor/banco de dados
        await Future.delayed(const Duration(seconds: 1));

        // Atualiza o estado da assinatura localmente para a UI sumir com o plano ativo
        assinatura = null;
        return true; // Sucesso
      }
      throw Exception("Usuário não autenticado.");
    } catch (e) {
      errorMessage = "Não foi possível processar o cancelamento: $e";
      return false; // Falhou
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
