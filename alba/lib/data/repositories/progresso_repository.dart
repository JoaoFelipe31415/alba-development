import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> obterProgresso(String userId) async {
    try {
      DocumentSnapshot doc = await _db
          .collection('progresso')
          .doc(userId)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Erro ao buscar progresso: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> obterMonitoramentoPorData(
    String userId,
    DateTime dataInicio,
    DateTime dataFim,
  ) async {
    try {
      Timestamp timestampInicio = Timestamp.fromDate(dataInicio);
      Timestamp timestampFim = Timestamp.fromDate(dataFim);

      QuerySnapshot snapshot = await _db
          .collection('monitoramento_diario')
          .where('userId', isEqualTo: userId)
          .where('data', isGreaterThanOrEqualTo: timestampInicio)
          .where('data', isLessThanOrEqualTo: timestampFim)
          .orderBy('data', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Erro ao buscar monitoramento por período: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obterTarefasConcluidas(
    String userId,
  ) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Tarefas')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'concluida')
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Erro ao buscar tarefas concluídas: $e");
      return [];
    }
  }
}
