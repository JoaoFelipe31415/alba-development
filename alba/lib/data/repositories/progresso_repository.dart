import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _colecaoMonitoramento = 'monitoramento_diario';
  static const String _colecaoProgresso = 'progresso';
  static const String _colecaoTarefas = 'Tarefas';

  Future<Map<String, dynamic>?> obterProgresso(String userId) async {
    try {
      DocumentSnapshot doc = await _db
          .collection(_colecaoProgresso)
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Erro em obterProgresso: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> obterMonitoramentoPorData(
    String userId,
    DateTime dataInicio,
    DateTime dataFim,
  ) async {
    try {
      final timestampInicio = Timestamp.fromDate(dataInicio);
      final timestampFim = Timestamp.fromDate(dataFim);

      String idLimpo = userId.replaceAll(RegExp(r'[^0-9]'), '');
      String idTexto = idLimpo;
      int? idNumero = int.tryParse(idLimpo);

      QuerySnapshot snapshot = await _db
          .collection(_colecaoMonitoramento)
          .where('data', isGreaterThanOrEqualTo: timestampInicio)
          .where('data', isLessThanOrEqualTo: timestampFim)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((dados) {
            final dbUserId = dados['userId'];

            bool bateComTexto =
                dbUserId.toString() == idTexto || dbUserId.toString() == userId;
            bool bateComNumero = idNumero != null && dbUserId == idNumero;

            return bateComTexto || bateComNumero;
          })
          .toList();
    } catch (e) {
      print("Erro em obterMonitoramentoPorData: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obterTarefasConcluidas(
    String idUsuario,
  ) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_colecaoTarefas)
          .where('userId', isEqualTo: idUsuario)
          .where('status', isEqualTo: 'concluida')
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Erro em obterTarefasConcluidas: $e");
      return [];
    }
  }
}
