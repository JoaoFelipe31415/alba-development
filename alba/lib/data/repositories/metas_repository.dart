import 'package:alba/domain/dto/meta_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MetasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<String> criarMeta(MetaDto meta) async {
    try {
      meta.userId = _userId;
      meta.dataCriacao = DateTime.now();

      final docRef = await _firestore.collection('Metas').add(meta.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Não foi possível criar a meta. Tente novamente.');
    }
  }

  Future<List<MetaDto>> obterMetas() async {
    try {
      final querySnapshot = await _firestore
          .collection('Metas')
          .where('userId', isEqualTo: _userId)
          .orderBy('dataCriacao', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MetaDto.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Não foi possível carregar as metas. Tente novamente.');
    }
  }

  Stream<List<MetaDto>> obterMetasStream() {
    try {
      return _firestore
          .collection('Metas')
          .where('userId', isEqualTo: _userId)
          .orderBy('dataCriacao', descending: true)
          .snapshots()
          .map(
            (querySnapshot) => querySnapshot.docs
                .map((doc) => MetaDto.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      throw Exception(
        'Não foi possível carregar as metas em tempo real. Tente novamente.',
      );
    }
  }

  Future<MetaDto?> obterMetaPorId(String id) async {
    try {
      final doc = await _firestore.collection('Metas').doc(id).get();
      if (doc.exists) {
        return MetaDto.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Não foi possível carregar a meta. Tente novamente.');
    }
  }

  Future<void> atualizarMeta(MetaDto meta) async {
    try {
      if (meta.id == null) {
        throw Exception('ID da meta é obrigatório para atualizar');
      }

      final updateData = {
        'tituloMeta': meta.tituloMeta,
        'descricao': meta.descricao ?? '',
        'prazo': meta.prazo,
        'tag': meta.tag,
      };

      await _firestore.collection('Metas').doc(meta.id).update(updateData);
    } catch (e) {
      throw Exception('Não foi possível atualizar a meta. Tente novamente.');
    }
  }

  Future<void> excluirMeta(String id) async {
    try {
      // 1. Deleta o documento da meta
      await _firestore.collection('Metas').doc(id).delete();

      // 2. Busca as tarefas vinculadas a esta meta para desvincular
      // Importante: 'Tarefas' com 'T' maiúsculo e filtrar por 'userId' para permissões
      final tarefas = await _firestore
          .collection('Tarefas')
          .where('userId', isEqualTo: _userId)
          .where('metaId', isEqualTo: id)
          .get();

      // 3. Usa batch para atualizar todas as tarefas de uma vez
      if (tarefas.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var tarefa in tarefas.docs) {
          batch.update(tarefa.reference, {'metaId': null});
        }
        await batch.commit();
      }
    } catch (e) {
      print('Erro ao excluir meta: $e');
      throw Exception('Não foi possível excluir a meta. Tente novamente.');
    }
  }

  Future<List<MetaDto>> buscarMetasPorTitulo(String titulo) async {
    try {
      final querySnapshot = await _firestore
          .collection('Metas')
          .where('userId', isEqualTo: _userId)
          .get();

      final metas = querySnapshot.docs
          .map((doc) => MetaDto.fromMap(doc.data(), doc.id))
          .toList();

      return metas
          .where(
            (meta) =>
                meta.tituloMeta.toLowerCase().contains(titulo.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Não foi possível buscar as metas. Tente novamente.');
    }
  }

  Stream<List<MetaDto>> buscarMetasStream(String titulo) {
    try {
      return _firestore
          .collection('Metas')
          .where('userId', isEqualTo: _userId)
          .orderBy('dataCriacao', descending: true)
          .snapshots()
          .map((querySnapshot) {
            final metas = querySnapshot.docs
                .map((doc) => MetaDto.fromMap(doc.data(), doc.id))
                .toList();

            // Filtro local para título (case-insensitive)
            if (titulo.isEmpty) {
              return metas;
            }
            return metas
                .where(
                  (meta) => meta.tituloMeta.toLowerCase().contains(
                    titulo.toLowerCase(),
                  ),
                )
                .toList();
          });
    } catch (e) {
      throw Exception(
        'Não foi possível buscar as metas em tempo real. Tente novamente.',
      );
    }
  }
}
