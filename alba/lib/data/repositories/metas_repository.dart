import 'package:alba/domain/dto/meta_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MetasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  List<MetaDto> _converterSnapshotParaMetas(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
  ) {
    final metas = <MetaDto>[];

    for (final doc in querySnapshot.docs) {
      try {
        final meta = MetaDto.fromMap(doc.data(), doc.id);
        metas.add(meta);
      } catch (e) {
        print('Documento de meta inválido ignorado: ${doc.id} - $e');
      }
    }

    metas.sort((a, b) {
      return b.dataCriacao.compareTo(a.dataCriacao);
    });

    return metas;
  }

  Future<String> _obterTelefoneDoUsuario() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      final userQuery = await _firestore
          .collection('Users')
          .where('uid', isEqualTo: currentUser.uid.trim())
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        return userQuery.docs.first.id;
      }

      final emailLimpo = currentUser.email?.toLowerCase().trim();

      if (emailLimpo == null || emailLimpo.isEmpty) {
        return '';
      }

      final userQueryEmail = await _firestore
          .collection('Users')
          .where('email', isEqualTo: emailLimpo)
          .limit(1)
          .get();

      if (userQueryEmail.docs.isNotEmpty) {
        return userQueryEmail.docs.first.id;
      }

      return '';
    } catch (e) {
      print('Erro ao obter telefone do usuário: $e');
      return '';
    }
  }

  Future<List<dynamic>> _obterTodosIdentificadores() async {
    final ids = <dynamic>[];

    if (_userId.isNotEmpty) {
      ids.add(_userId);
    }

    try {
      final telefone = await _obterTelefoneDoUsuario();

      if (telefone.isNotEmpty && !ids.contains(telefone)) {
        ids.add(int.parse(telefone));
      }

      final telefoneComIgual = '=$telefone';

      if (telefone.isNotEmpty && !ids.contains(telefoneComIgual)) {
        ids.add(telefoneComIgual);
      }
    } catch (e) {
      print('Aviso ao obter identificadores do usuário: $e');
    }

    return ids;
  }

  Future<String> criarMeta(MetaDto meta) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado');
      }

      meta.userId = _userId;
      meta.dataCriacao = DateTime.now();
      meta.concluida = false;
      meta.dataConclusao = null;

      final docRef = await _firestore.collection('Metas').add(meta.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Não foi possível criar a meta. Tente novamente.');
    }
  }

  Future<List<MetaDto>> obterMetas() async {
    try {
      final idsValidos = await _obterTodosIdentificadores();

      if (idsValidos.isEmpty) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('Metas')
          .where('userId', whereIn: idsValidos)
          .get();

      return _converterSnapshotParaMetas(querySnapshot);
    } catch (e) {
      throw Exception('Não foi possível carregar as metas. Tente novamente.');
    }
  }

  Stream<List<MetaDto>> obterMetasStream() async* {
    try {
      final idsValidos = await _obterTodosIdentificadores();

      if (idsValidos.isEmpty) {
        yield [];
        return;
      }

      yield* _firestore
          .collection('Metas')
          .where('userId', whereIn: idsValidos)
          .snapshots()
          .map((querySnapshot) {
            return _converterSnapshotParaMetas(querySnapshot);
          });
    } catch (e) {
      print('Erro ao carregar metas em tempo real: $e');
      throw Exception(
        'Não foi possível carregar as metas em tempo real. Tente novamente.',
      );
    }
  }

  Future<MetaDto?> obterMetaPorId(String id) async {
    try {
      final doc = await _firestore.collection('Metas').doc(id).get();

      if (doc.exists && doc.data() != null) {
        return MetaDto.fromMap(doc.data()!, doc.id);
      }

      return null;
    } catch (e) {
      throw Exception('Não foi possível carregar a meta. Tente novamente.');
    }
  }

  Future<void> atualizarMeta(MetaDto meta) async {
    try {
      if (meta.id == null || meta.id!.isEmpty) {
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

  Future<void> atualizarConclusaoMeta({
    required String metaId,
    required bool concluida,
  }) async {
    try {
      if (metaId.isEmpty) {
        throw Exception('ID da meta é obrigatório para atualizar conclusão');
      }

      await _firestore.collection('Metas').doc(metaId).update({
        'concluida': concluida,
        'dataConclusao': concluida ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      print('Erro ao atualizar conclusão da meta: $e');
      throw Exception(
        'Não foi possível atualizar o status da meta. Tente novamente.',
      );
    }
  }

  Future<void> excluirMeta(String id) async {
    try {
      await _firestore.collection('Metas').doc(id).delete();

      final tarefas = await _firestore
          .collection('Tarefas')
          .where('metaId', isEqualTo: id)
          .get();

      if (tarefas.docs.isNotEmpty) {
        final batch = _firestore.batch();

        for (final tarefa in tarefas.docs) {
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
      final idsValidos = await _obterTodosIdentificadores();

      if (idsValidos.isEmpty) {
        return [];
      }

      final querySnapshot = await _firestore
          .collection('Metas')
          .where('userId', whereIn: idsValidos)
          .get();

      final metas = _converterSnapshotParaMetas(querySnapshot);
      final termoBusca = titulo.toLowerCase().trim();

      if (termoBusca.isEmpty) {
        return metas;
      }

      return metas.where((meta) {
        return meta.tituloMeta.toLowerCase().contains(termoBusca);
      }).toList();
    } catch (e) {
      throw Exception('Não foi possível buscar as metas. Tente novamente.');
    }
  }

  Stream<List<MetaDto>> buscarMetasStream(String titulo) async* {
    try {
      final idsValidos = await _obterTodosIdentificadores();

      if (idsValidos.isEmpty) {
        yield [];
        return;
      }

      yield* _firestore
          .collection('Metas')
          .where('userId', whereIn: idsValidos)
          .snapshots()
          .map((querySnapshot) {
            final metas = _converterSnapshotParaMetas(querySnapshot);
            final termoBusca = titulo.toLowerCase().trim();

            if (termoBusca.isEmpty) {
              return metas;
            }

            return metas.where((meta) {
              return meta.tituloMeta.toLowerCase().contains(termoBusca);
            }).toList();
          });
    } catch (e) {
      throw Exception(
        'Não foi possível buscar as metas em tempo real. Tente novamente.',
      );
    }
  }
}
