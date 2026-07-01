import 'dart:async';

import 'package:alba/data/services/conexao_service.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TarefasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConexaoService _conexaoService = ConexaoService();

  static const String _collection = 'Tarefas';
  static const String _usersCollection = 'Users';

  /// Deixe true até confirmar que as tarefas do WhatsApp aparecem.
  /// Depois pode trocar para false.
  static const bool _debugTarefas = true;

  String get _uidUsuario => _auth.currentUser?.uid ?? '';

  /// Mantido para tarefas manuais criadas pelo app.
  String get _userId => _uidUsuario;

  String? get _emailUsuario {
    final email = _auth.currentUser?.email?.trim();

    if (email == null || email.isEmpty) {
      return null;
    }

    return email;
  }

  String? get _telefoneAuthUsuario {
    final phone = _auth.currentUser?.phoneNumber?.trim();

    if (phone == null || phone.isEmpty) {
      return null;
    }

    return phone;
  }

  void _debugPrint(String message) {
    if (_debugTarefas) {
      print('[TAREFAS_DEBUG] $message');
    }
  }

  String _somenteDigitos(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String _normalizarIdentificador(String value) {
    return value.trim();
  }

  String? _normalizarString(String? value) {
    final texto = value?.trim();

    if (texto == null || texto.isEmpty) {
      return null;
    }

    return texto;
  }

  void _adicionarVariacoesTelefone(Set<String> ids, String? telefone) {
    final telefoneBruto = telefone?.trim();

    if (telefoneBruto == null || telefoneBruto.isEmpty) {
      return;
    }

    final telefoneSemMais = telefoneBruto.replaceFirst('+', '').trim();
    final telefoneDigitos = _somenteDigitos(telefoneBruto);

    if (telefoneBruto.isNotEmpty) {
      ids.add(telefoneBruto);
    }

    if (telefoneSemMais.isNotEmpty) {
      ids.add(telefoneSemMais);
    }

    if (telefoneDigitos.isNotEmpty) {
      ids.add(telefoneDigitos);
      ids.add('+$telefoneDigitos');

      // Compatibilidade com o formato salvo pelo n8n:
      // userId: "=5581973172656"
      ids.add('=$telefoneDigitos');
    }
  }

  void _adicionarDadosUserDoc(Set<String> ids, DocumentSnapshot doc) {
    final docId = doc.id.trim();

    if (docId.isNotEmpty) {
      ids.add(docId);
      _adicionarVariacoesTelefone(ids, docId);
    }

    final rawData = doc.data();

    if (rawData is! Map<String, dynamic>) {
      return;
    }

    final uid = rawData['uid']?.toString().trim();
    final userId = rawData['userId']?.toString().trim();
    final phone = rawData['phone']?.toString().trim();
    final telefone = rawData['telefone']?.toString().trim();
    final whatsapp = rawData['whatsapp']?.toString().trim();

    if (uid != null && uid.isNotEmpty) {
      ids.add(uid);
    }

    if (userId != null && userId.isNotEmpty) {
      ids.add(userId);
    }

    _adicionarVariacoesTelefone(ids, phone);
    _adicionarVariacoesTelefone(ids, telefone);
    _adicionarVariacoesTelefone(ids, whatsapp);
  }

  Future<void> _buscarUsuarioPorUid(Set<String> ids, String uid) async {
    if (uid.trim().isEmpty) return;

    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('uid', isEqualTo: uid)
          .limit(10)
          .get();

      _debugPrint('USERS por uid encontrados: ${query.docs.length}');

      for (final doc in query.docs) {
        _debugPrint('USER DOC POR UID: ${doc.id} => ${doc.data()}');
        _adicionarDadosUserDoc(ids, doc);
      }
    } catch (e) {
      _debugPrint('Erro ao buscar Users por uid: $e');
    }
  }

  Future<void> _buscarUsuarioPorEmail(Set<String> ids, String? email) async {
    final emailNormalizado = email?.trim();

    if (emailNormalizado == null || emailNormalizado.isEmpty) {
      return;
    }

    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: emailNormalizado)
          .limit(10)
          .get();

      _debugPrint('USERS por email encontrados: ${query.docs.length}');

      for (final doc in query.docs) {
        _debugPrint('USER DOC POR EMAIL: ${doc.id} => ${doc.data()}');
        _adicionarDadosUserDoc(ids, doc);
      }
    } catch (e) {
      _debugPrint('Erro ao buscar Users por email: $e');
    }
  }

  /// Busca todos os identificadores válidos do usuário logado.
  ///
  /// Inclui:
  /// - UID do Firebase Auth;
  /// - telefone vindo do Firebase Auth, se existir;
  /// - telefone/documento encontrado em Users pelo uid;
  /// - telefone/documento encontrado em Users pelo email.
  Future<List<String>> _obterIdentificadoresUsuario() async {
    final ids = <String>{};

    final uid = _uidUsuario.trim();
    final email = _emailUsuario;

    if (uid.isNotEmpty) {
      ids.add(uid);
    }

    _adicionarVariacoesTelefone(ids, _telefoneAuthUsuario);

    await _buscarUsuarioPorUid(ids, uid);
    await _buscarUsuarioPorEmail(ids, email);

    final lista = ids
        .map(_normalizarIdentificador)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    // Firestore whereIn aceita até 30 valores. Aqui normalmente teremos poucos.
    if (lista.length > 30) {
      return lista.take(30).toList();
    }

    return lista;
  }

  bool _pertenceAoUsuarioComIds(String userIdTarefa, List<String> idsUsuario) {
    final valor = _normalizarIdentificador(userIdTarefa);

    if (valor.isEmpty) {
      return false;
    }

    return idsUsuario.contains(valor);
  }

  void _debugAuthEIds(String origem, List<String> idsUsuario) {
    _debugPrint('==============================');
    _debugPrint('ORIGEM: $origem');
    _debugPrint('AUTH UID: ${_auth.currentUser?.uid}');
    _debugPrint('AUTH EMAIL: ${_auth.currentUser?.email}');
    _debugPrint('AUTH PHONE: ${_auth.currentUser?.phoneNumber}');
    _debugPrint('IDS CONSULTA: $idsUsuario');
    _debugPrint('==============================');
  }

  void _debugSnapshot(
    String origem,
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
  ) {
    _debugPrint(
      '[$origem] DOCS RECEBIDOS DO FIRESTORE: ${querySnapshot.docs.length}',
    );

    for (final doc in querySnapshot.docs) {
      final data = doc.data();

      _debugPrint(
        '[$origem] DOC ${doc.id} | '
        'userId=${data['userId']} | '
        'tituloTarefa=${data['tituloTarefa']} | '
        'dataInicial=${data['dataInicial']} | '
        'dataCriacao=${data['dataCriacao']} | '
        'tipoRecorrencia=${data['tipoRecorrencia']} | '
        'diasRealizacao=${data['diasRealizacao']} | '
        'status=${data['status']}',
      );
    }
  }

  void _debugTarefasConvertidas(String origem, List<TarefaDto> tarefas) {
    _debugPrint(
      '[$origem] TAREFAS ACEITAS APÓS CONVERSÃO/FILTRO: ${tarefas.length}',
    );

    for (final tarefa in tarefas) {
      _debugPrint(
        '[$origem] TAREFA OK | '
        'id=${tarefa.id} | '
        'userId=${tarefa.userId} | '
        'titulo=${tarefa.tituloTarefa} | '
        'dataInicial=${tarefa.dataInicial} | '
        'dataCriacao=${tarefa.dataCriacao} | '
        'tipo=${tarefa.tipoRecorrencia.value} | '
        'dias=${tarefa.diasRealizacao} | '
        'status=${tarefa.status}',
      );
    }
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

    // Tarefas manuais continuam usando UID.
    tarefa.userId = _userId;

    if (tarefa.status.trim().isEmpty) {
      tarefa.status = 'pendente';
    }
  }

  List<TarefaDto> _converterSnapshotParaTarefas(
    QuerySnapshot<Map<String, dynamic>> querySnapshot, {
    required List<String> idsUsuario,
    String origem = 'desconhecida',
  }) {
    final tarefas = <TarefaDto>[];

    for (final doc in querySnapshot.docs) {
      try {
        final data = doc.data();
        final tarefa = TarefaDto.fromMap(data, doc.id);

        final pertenceAoUsuario = _pertenceAoUsuarioComIds(
          tarefa.userId,
          idsUsuario,
        );

        final tituloValido = tarefa.tituloTarefa.trim().isNotEmpty;

        _debugPrint(
          '[$origem] ANALISANDO DOC ${doc.id} | '
          'userIdFirestore=${data['userId']} | '
          'userIdDto=${tarefa.userId} | '
          'pertenceAoUsuario=$pertenceAoUsuario | '
          'tituloValido=$tituloValido',
        );

        if (pertenceAoUsuario && tituloValido) {
          tarefas.add(tarefa);
        }
      } catch (e) {
        print('Documento de tarefa inválido ignorado: ${doc.id} - $e');
      }
    }

    _debugTarefasConvertidas(origem, tarefas);

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
    const origem = 'obterTarefas';

    try {
      final idsUsuario = await _obterIdentificadoresUsuario();

      _debugAuthEIds(origem, idsUsuario);

      if (idsUsuario.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', whereIn: idsUsuario)
          .orderBy('dataCriacao', descending: true)
          .get();

      _debugSnapshot(origem, querySnapshot);

      return _converterSnapshotParaTarefas(
        querySnapshot,
        idsUsuario: idsUsuario,
        origem: origem,
      );
    } on FirebaseException catch (e) {
      print('ERRO FIREBASE obterTarefas: code=${e.code}, message=${e.message}');

      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }

      if (e.code == 'failed-precondition') {
        throw Exception(
          'É necessário criar um índice no Firestore para consultar as tarefas.',
        );
      }

      if (e.code == 'permission-denied') {
        throw Exception('Permissão negada para carregar as tarefas.');
      }

      throw Exception('Não foi possível carregar as tarefas. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL obterTarefas: $e');
      rethrow;
    }
  }

  Stream<List<TarefaDto>> obterTarefasStream() {
    const origem = 'obterTarefasStream';

    return Stream.fromFuture(_obterIdentificadoresUsuario()).asyncExpand((
      idsUsuario,
    ) {
      _debugAuthEIds(origem, idsUsuario);

      if (idsUsuario.isEmpty) {
        return Stream<List<TarefaDto>>.error(
          Exception('Usuário não autenticado.'),
        );
      }

      return _firestore
          .collection(_collection)
          .where('userId', whereIn: idsUsuario)
          .orderBy('dataCriacao', descending: true)
          .snapshots()
          .map((querySnapshot) {
            _debugSnapshot(origem, querySnapshot);

            return _converterSnapshotParaTarefas(
              querySnapshot,
              idsUsuario: idsUsuario,
              origem: origem,
            );
          })
          .handleError((error) {
            print('ERRO STREAM obterTarefasStream: $error');

            if (error is FirebaseException && error.code == 'unavailable') {
              throw Exception(
                'Sem conexão com a internet. Verifique sua rede.',
              );
            }

            if (error is FirebaseException &&
                error.code == 'failed-precondition') {
              throw Exception(
                'É necessário criar um índice no Firestore para consultar as tarefas.',
              );
            }

            if (error is FirebaseException &&
                error.code == 'permission-denied') {
              throw Exception('Permissão negada para atualizar suas tarefas.');
            }

            throw Exception('Não foi possível atualizar suas tarefas.');
          });
    });
  }

  Future<TarefaDto?> obterTarefaPorId(String id) async {
    const origem = 'obterTarefaPorId';

    try {
      final idsUsuario = await _obterIdentificadoresUsuario();

      _debugAuthEIds(origem, idsUsuario);

      if (idsUsuario.isEmpty) {
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

      final pertence = _pertenceAoUsuarioComIds(tarefa.userId, idsUsuario);

      _debugPrint(
        '[$origem] DOC ${doc.id} | userId=${tarefa.userId} | pertence=$pertence',
      );

      if (!pertence) {
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

      if (e.code == 'permission-denied') {
        throw Exception('Permissão negada para carregar a tarefa.');
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
        'horario': tarefa.horarioInicio,
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

      if (e.code == 'permission-denied') {
        throw Exception('Permissão negada para salvar a tarefa.');
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

      if (e.code == 'permission-denied') {
        throw Exception('Permissão negada para excluir a tarefa.');
      }

      throw Exception('Não foi possível excluir. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL excluirTarefa: $e');
      rethrow;
    }
  }

  Future<List<TarefaDto>> buscarTarefasPorTitulo(String titulo) async {
    const origem = 'buscarTarefasPorTitulo';

    try {
      final idsUsuario = await _obterIdentificadoresUsuario();

      _debugAuthEIds(origem, idsUsuario);

      if (idsUsuario.isEmpty) {
        throw Exception('Usuário não autenticado.');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', whereIn: idsUsuario)
          .orderBy('dataCriacao', descending: true)
          .get();

      _debugSnapshot(origem, querySnapshot);

      final tarefas = _converterSnapshotParaTarefas(
        querySnapshot,
        idsUsuario: idsUsuario,
        origem: origem,
      );

      final termo = titulo.trim().toLowerCase();

      if (termo.isEmpty) {
        return tarefas;
      }

      final filtradas = tarefas.where((tarefa) {
        return tarefa.tituloTarefa.toLowerCase().contains(termo);
      }).toList();

      _debugPrint(
        '[$origem] TAREFAS APÓS FILTRO DE BUSCA: ${filtradas.length}',
      );

      return filtradas;
    } on FirebaseException catch (e) {
      print(
        'ERRO FIREBASE buscarTarefasPorTitulo: code=${e.code}, message=${e.message}',
      );

      if (e.code == 'unavailable') {
        throw Exception(
          'Sem conexão com a internet. Verifique sua rede e tente novamente.',
        );
      }

      if (e.code == 'failed-precondition') {
        throw Exception(
          'É necessário criar um índice no Firestore para buscar as tarefas.',
        );
      }

      if (e.code == 'permission-denied') {
        throw Exception('Permissão negada para buscar as tarefas.');
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
    const origem = 'buscarTarefasStream';

    return Stream.fromFuture(_obterIdentificadoresUsuario()).asyncExpand((
      idsUsuario,
    ) {
      _debugAuthEIds(origem, idsUsuario);

      if (idsUsuario.isEmpty) {
        return Stream<List<TarefaDto>>.error(
          Exception('Usuário não autenticado.'),
        );
      }

      return _firestore
          .collection(_collection)
          .where('userId', whereIn: idsUsuario)
          .orderBy('dataCriacao', descending: true)
          .snapshots()
          .map((querySnapshot) {
            _debugSnapshot(origem, querySnapshot);

            final tarefas = _converterSnapshotParaTarefas(
              querySnapshot,
              idsUsuario: idsUsuario,
              origem: origem,
            );

            final termo = titulo.trim().toLowerCase();

            if (termo.isEmpty) {
              _debugPrint(
                '[$origem] SEM TERMO DE BUSCA. RETORNANDO ${tarefas.length} TAREFAS.',
              );
              return tarefas;
            }

            final filtradas = tarefas.where((tarefa) {
              return tarefa.tituloTarefa.toLowerCase().contains(termo);
            }).toList();

            _debugPrint(
              '[$origem] TERMO="$termo" | TAREFAS APÓS BUSCA: ${filtradas.length}',
            );

            return filtradas;
          })
          .handleError((error) {
            print('ERRO STREAM buscarTarefasStream: $error');

            if (error is FirebaseException && error.code == 'unavailable') {
              throw Exception(
                'Sem conexão com a internet. Verifique sua rede.',
              );
            }

            if (error is FirebaseException &&
                error.code == 'failed-precondition') {
              throw Exception(
                'É necessário criar um índice no Firestore para consultar as tarefas.',
              );
            }

            if (error is FirebaseException &&
                error.code == 'permission-denied') {
              throw Exception('Permissão negada para atualizar suas tarefas.');
            }

            throw Exception('Não foi possível atualizar suas tarefas.');
          });
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

      if (e.code == 'permission-denied') {
        throw Exception('Permissão negada para atualizar a tarefa.');
      }

      throw Exception('Não foi possível atualizar a tarefa.');
    } catch (e) {
      print('ERRO GERAL atualizarStatus: $e');
      rethrow;
    }
  }

  Future<List<TarefaDto>> obterTarefasConcluidas(String userId) async {
    const origem = 'obterTarefasConcluidas';

    try {
      final idsConsulta = <String>{};

      final userIdNormalizado = userId.trim();

      if (userIdNormalizado.isNotEmpty) {
        idsConsulta.add(userIdNormalizado);

        final digitos = _somenteDigitos(userIdNormalizado);

        if (digitos.isNotEmpty) {
          idsConsulta.add(digitos);
          idsConsulta.add('=$digitos');
          idsConsulta.add('+$digitos');
        }
      }

      if (idsConsulta.isEmpty) {
        return [];
      }

      _debugPrint('[$origem] IDS CONSULTA CONCLUÍDAS: $idsConsulta');

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', whereIn: idsConsulta.toList())
          .where('status', isEqualTo: 'concluida')
          .get();

      _debugSnapshot(origem, querySnapshot);

      final tarefas = <TarefaDto>[];

      for (final doc in querySnapshot.docs) {
        try {
          tarefas.add(TarefaDto.fromMap(doc.data(), doc.id));
        } catch (e) {
          print('Documento concluído inválido ignorado: ${doc.id} - $e');
        }
      }

      _debugTarefasConvertidas(origem, tarefas);

      return tarefas;
    } catch (e) {
      print('Erro ao buscar concluídas: $e');
      return [];
    }
  }
}
