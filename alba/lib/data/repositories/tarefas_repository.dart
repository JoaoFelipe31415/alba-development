import 'package:alba/data/services/conexao_service.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TarefasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConexaoService _conexaoService = ConexaoService();

  static const String _collection = 'Tarefas';

  String get _userId => _auth.currentUser?.uid ?? '';

  String? _normalizarString(String? value) {
    final texto = value?.trim();

    if (texto == null || texto.isEmpty) {
      return null;
    }

    return texto;
  }

  String? _horarioInicioCompatibilidade(TarefaDto tarefa) {
    return _normalizarString(tarefa.horarioInicio) ??
        _normalizarString(tarefa.horario);
  }

  String? _horarioFimCompatibilidade(TarefaDto tarefa) {
    return _normalizarString(tarefa.horarioFim);
  }

  void _padronizarAntesDeSalvar(TarefaDto tarefa) {
    final inicio = _horarioInicioCompatibilidade(tarefa);
    final fim = _horarioFimCompatibilidade(tarefa);

    // Campo antigo mantido por compatibilidade.
    tarefa.horario = inicio;

    // Campos novos.
    tarefa.horarioInicio = inicio;
    tarefa.horarioFim = fim;

    tarefa.userId = _userId;

    if (tarefa.status.trim().isEmpty) {
      tarefa.status = 'pendente';
    }
  }

  List<TarefaDto> _converterSnapshotParaTarefas(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
  ) {
    final tarefas = <TarefaDto>[];

    for (final doc in querySnapshot.docs) {
      try {
        final tarefa = TarefaDto.fromMap(doc.data(), doc.id);

        final pertenceAoUsuario = tarefa.userId == _userId;
        final tituloValido = tarefa.tituloTarefa.trim().isNotEmpty;

        if (pertenceAoUsuario && tituloValido) {
          tarefas.add(tarefa);
        }
      } catch (e) {
        // Documento inválido vindo do Firestore/n8n não quebra a interface.
        print('Documento de tarefa inválido ignorado: ${doc.id} - $e');
      }
    }

    return tarefas;
  }

  Future<String> criarTarefa(TarefaDto tarefa) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      final temInternet = await _conexaoService.temInternet();

      if (!temInternet) {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }

      _padronizarAntesDeSalvar(tarefa);

      tarefa.dataCriacao = DateTime.now();

      final docRef = _firestore.collection(_collection).doc();
      tarefa.id = docRef.id;

      await docRef.set(tarefa.toMap());

      // IMPORTANTE:
      // Não criamos mais documentos recorrentes automaticamente.
      // A recorrência agora fica dentro do próprio documento.
      // Modelo:
      // 1 tarefa = 1 documento no Firestore.

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

      return _converterSnapshotParaTarefas(querySnapshot);
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
    if (_userId.isEmpty) {
      return Stream.error(Exception('Usuário não autenticado.'));
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: _userId)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map(_converterSnapshotParaTarefas)
        .handleError((error) {
      print('ERRO STREAM obterTarefasStream: $error');

      if (error is FirebaseException && error.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede.',
        );
      }

      throw Exception('Não foi possível atualizar suas tarefas.');
    });
  }

  Future<TarefaDto?> obterTarefaPorId(String id) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      final tarefa = TarefaDto.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

      if (tarefa.userId != _userId) {
        throw Exception('Acesso negado a esta tarefa.');
      }

      return tarefa;
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
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      if (tarefa.id == null || tarefa.id!.isEmpty) {
        throw Exception('ID da tarefa é obrigatório para atualizar.');
      }

      _padronizarAntesDeSalvar(tarefa);

      final updateData = {
        'userId': _userId,
        'tituloTarefa': tarefa.tituloTarefa,
        'diasRealizacao': tarefa.diasRealizacao,

        // Campo antigo mantido por compatibilidade.
        'horario': tarefa.horarioInicio,

        // Campos novos.
        'horarioInicio': tarefa.horarioInicio,
        'horarioFim': tarefa.horarioFim,

        'dataInicial': tarefa.dataInicial != null
            ? Timestamp.fromDate(tarefa.dataInicial!)
            : null,
        'metaId': tarefa.metaId,
        'tituloMeta': tarefa.tituloMeta,
        'tag': tarefa.tag,
        'status': tarefa.status,
        'tipoRecorrencia': tarefa.tipoRecorrencia.value,
        'configuracaoRecorrencia': tarefa.configuracaoRecorrencia?.toMap(),
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
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

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
          .orderBy('dataCriacao', descending: true)
          .get();

      final tarefas = _converterSnapshotParaTarefas(querySnapshot);

      final termo = titulo.trim().toLowerCase();

      if (termo.isEmpty) {
        return tarefas;
      }

      return tarefas.where((tarefa) {
        return tarefa.tituloTarefa.toLowerCase().contains(termo);
      }).toList();
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

  Stream<List<TarefaDto>> buscarTarefasStream(
    String titulo, {
    String? mes,
    int? dia,
  }) {
    if (_userId.isEmpty) {
      return Stream.error(Exception('Usuário não autenticado.'));
    }

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: _userId)
        .orderBy('dataCriacao', descending: true)
        .snapshots()
        .map((querySnapshot) {
      final tarefas = _converterSnapshotParaTarefas(querySnapshot);

      final termo = titulo.trim().toLowerCase();

      if (termo.isEmpty) {
        return tarefas;
      }

      return tarefas.where((tarefa) {
        return tarefa.tituloTarefa.toLowerCase().contains(termo);
      }).toList();
    }).handleError((error) {
      print('ERRO STREAM buscarTarefasStream: $error');

      if (error is FirebaseException && error.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede.',
        );
      }

      throw Exception('Não foi possível atualizar suas tarefas.');
    });
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      await _firestore.collection(_collection).doc(id).update({
        'status': novoStatus,
        'dataConclusao': novoStatus == 'concluida'
            ? FieldValue.serverTimestamp()
            : null,
      });
    } on FirebaseException catch (e) {
      print(
        'ERRO FIREBASE atualizarStatus: code=${e.code}, message=${e.message}',
      );

      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }

      throw Exception('Não foi possível atualizar a tarefa.');
    } catch (e) {
      print('ERRO GERAL atualizarStatus: $e');
      rethrow;
    }
  }

  Future<List<TarefaDto>> obterTarefasConcluidas(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'concluida')
          .get();

      final tarefas = <TarefaDto>[];

      for (final doc in querySnapshot.docs) {
        try {
          tarefas.add(TarefaDto.fromMap(doc.data(), doc.id));
        } catch (e) {
          print('Documento concluído inválido ignorado: ${doc.id} - $e');
        }
      }

      return tarefas;
    } catch (e) {
      print('Erro ao buscar concluídas: $e');
      return [];
    }
  }
}