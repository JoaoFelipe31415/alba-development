import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Busca o documento de progresso do usuário logado
  Future<Map<String, dynamic>?> obterProgresso(String userId) async {
    try {
      // Aqui estamos buscando na coleção 'progresso' um documento com o ID do usuário
      DocumentSnapshot doc = await _db.collection('progresso').doc(userId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null; // Se não existir, o DTO usará os dados de "mock" (brownies, etc)
    } catch (e) {
      print("Erro ao buscar progresso: $e");
      return null;
    }
  }


Future<List<Map<String, dynamic>>> obterSentimentosDaSemana(String userId) async {
    try {
      // Faz a busca filtrando pelo seu UID e ordenando pela data mais recente
      QuerySnapshot snapshot = await _db
          .collection('monitoramento_diario')
          .where('userId', isEqualTo: userId)
          .orderBy('data', descending: true)
          .limit(7) // Garante que pegamos apenas os últimos 7 dias
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Erro ao buscar sentimentos: $e");
      return []; // Retorna lista vazia para a ViewModel usar os círculos brancos
    }
  }

  Future<List<Map<String, dynamic>>> obterTarefasConcluidas(String userId) async {
    try {
      // Faz a busca na coleção 'tarefas' filtrando pelo usuário e pelo status
      QuerySnapshot snapshot = await _db
          .collection('Tarefas')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'concluida')
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Erro ao buscar tarefas concluídas: $e");
      return []; // Retorna lista vazia para a ViewModel não quebrar
    }
  }
  
}

