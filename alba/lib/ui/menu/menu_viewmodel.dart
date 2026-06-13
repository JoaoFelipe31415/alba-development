import 'package:flutter/material.dart';

class MenuViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  bool isEditing = false;

  // Mock de dados iniciais baseado no Jira (O Romário vai substituir pela busca do Firebase)
  Map<String, dynamic> perfil = {
    'nome': 'Lets',
    'email': 'lets@ufrpe.br',
    'telefone': '(81) 99999-9999',
    'curso': 'Sistemas de Informação',
    'universidade': 'UFRPE',
    'periodo': '7º Período',
  };

  Map<String, dynamic>? assinatura = {
    'statusAssinatura': 'Plano ativo',
    'valorPlano': 'R\$ 39,90',
    'dataRenovacao': '20/06/2026',
  };

  // Controladores para o fluxo de edição de perfil
  final nameController = TextEditingController();
  final cursoController = TextEditingController();
  final uniController = TextEditingController();
  final periodoController = TextEditingController();

  void initControllers() {
    nameController.text = perfil['nome'] ?? '';
    cursoController.text = perfil['curso'] ?? '';
    uniController.text = perfil['universidade'] ?? '';
    periodoController.text = perfil['periodo'] ?? '';
  }

  Future<void> carregarDadosUsuario() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Romário vai injetar a chamada do Repositório aqui
      await Future.delayed(const Duration(milliseconds: 800)); // Simulação
      initControllers();
    } catch (e) {
      errorMessage = "Não foi possível carregar suas informações.";
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
      await Future.delayed(const Duration(milliseconds: 500));

      perfil['nome'] = nameController.text;
      perfil['curso'] = cursoController.text;
      perfil['universidade'] = uniController.text;
      perfil['periodo'] = periodoController.text;

      isEditing = false;
    } catch (e) {
      errorMessage = "Não foi possível salvar as alterações.";
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
    super.dispose();
  }
}
