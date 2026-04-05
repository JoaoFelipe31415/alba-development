import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TarefasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _collection = 'Tarefas';

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<String> criarTarefa(TarefaDto tarefa) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      tarefa.userId = _userId;
      tarefa.dataCriacao = DateTime.now();
      tarefa.status = 'pendente';

      final docRef = _firestore.collection(_collection).doc();
      tarefa.id = docRef.id;

      await docRef.set(tarefa.toMap());

      return docRef.id;
    } on FirebaseException catch (e) {
      print('ERRO FIREBASE criarTarefa: code=${e.code}, message=${e.message}');
      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }
      throw Exception('Não foi possível salvar. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL criarTarefa: $e');
      rethrow;
    }
  }

  Future<List<TarefaDto>> obterTarefas() async {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _userId)
          .orderBy('dataCriacao', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TarefaDto.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      print('ERRO FIREBASE obterTarefas: code=${e.code}, message=${e.message}');
      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }
      throw Exception('Não foi possível carregar as tarefas. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL obterTarefas: $e');
      rethrow;
    }
  }

  Stream<List<TarefaDto>> obterTarefasStream() {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _userId)
          .orderBy('dataCriacao', descending: true)
          .snapshots()
          .map(
            (querySnapshot) => querySnapshot.docs
                .map((doc) => TarefaDto.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      print('ERRO GERAL obterTarefasStream: $e');
      throw Exception(
        'Não foi possível carregar as tarefas em tempo real. Tente novamente.',
      );
    }
  }

  Future<TarefaDto?> obterTarefaPorId(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (doc.exists) {
        return TarefaDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }

      return null;
    } on FirebaseException catch (e) {
      print(
        'ERRO FIREBASE obterTarefaPorId: code=${e.code}, message=${e.message}',
      );
      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }
      throw Exception('Não foi possível carregar a tarefa. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL obterTarefaPorId: $e');
      rethrow;
    }
  }

  Future<void> atualizarTarefa(TarefaDto tarefa) async {
    try {
      if (tarefa.id == null || tarefa.id!.isEmpty) {
        throw Exception('ID da tarefa é obrigatório para atualizar');
      }

      final updateData = {
        'tituloTarefa': tarefa.tituloTarefa,
        'diasRealizacao': tarefa.diasRealizacao,
        'horario': tarefa.horario,
        'metaId': tarefa.metaId,
        'tituloMeta': tarefa.tituloMeta,
        'tag': tarefa.tag,
        'status': tarefa.status,
      };

      await _firestore
          .collection(_collection)
          .doc(tarefa.id)
          .update(updateData);
    } on FirebaseException catch (e) {
      print(
        'ERRO FIREBASE atualizarTarefa: code=${e.code}, message=${e.message}',
      );
      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }
      throw Exception('Não foi possível salvar. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL atualizarTarefa: $e');
      rethrow;
    }
  }

  Future<void> excluirTarefa(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      print(
        'ERRO FIREBASE excluirTarefa: code=${e.code}, message=${e.message}',
      );
      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }
      throw Exception('Não foi possível excluir. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL excluirTarefa: $e');
      rethrow;
    }
  }

  Future<List<TarefaDto>> buscarTarefasPorTitulo(String titulo) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _userId)
          .get();

      final tarefas = querySnapshot.docs
          .map((doc) => TarefaDto.fromMap(doc.data(), doc.id))
          .toList();

      if (titulo.isEmpty) {
        return tarefas;
      }

      return tarefas
          .where(
            (tarefa) => tarefa.tituloTarefa.toLowerCase().contains(
              titulo.toLowerCase(),
            ),
          )
          .toList();
    } on FirebaseException catch (e) {
      print(
        'ERRO FIREBASE buscarTarefasPorTitulo: code=${e.code}, message=${e.message}',
      );
      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }
      throw Exception('Não foi possível buscar as tarefas. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL buscarTarefasPorTitulo: $e');
      rethrow;
    }
  }

  Stream<List<TarefaDto>> buscarTarefasStream(String titulo) {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _userId)
          .orderBy('dataCriacao', descending: true)
          .snapshots()
          .map((querySnapshot) {
            final tarefas = querySnapshot.docs
                .map((doc) => TarefaDto.fromMap(doc.data(), doc.id))
                .toList();

            if (titulo.isEmpty) {
              return tarefas;
            }

            return tarefas
                .where(
                  (tarefa) => tarefa.tituloTarefa.toLowerCase().contains(
                    titulo.toLowerCase(),
                  ),
                )
                .toList();
          });
    } catch (e) {
      print('ERRO GERAL buscarTarefasStream: $e');
      throw Exception(
        'Não foi possível buscar as tarefas em tempo real. Tente novamente.',
      );
    }
  }
}
