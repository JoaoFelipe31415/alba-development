import 'package:alba/data/services/recorrencia_service.dart';
import 'package:alba/domain/dto/tarefa_dto.dart';
import 'package:alba/domain/entities/recorrencia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alba/data/services/conexao_service.dart';

class TarefasRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConexaoService _conexaoService = ConexaoService();

  static const String _collection = 'Tarefas';

  String get _userId => _auth.currentUser?.uid ?? '';

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

      tarefa.userId = _userId;
      tarefa.dataCriacao = DateTime.now();
      tarefa.status = 'pendente';

      final docRef = _firestore.collection(_collection).doc();
      tarefa.id = docRef.id;

      await docRef.set(tarefa.toMap());

      if (tarefa.tipoRecorrencia != TipoRecorrencia.naoRepete &&
          tarefa.dataInicial != null) {
        await _criarTarefasRecorrentes(tarefa);
      }

      return docRef.id;
    } on FirebaseException catch (e) {
      print('ERRO FIREBASE criarTarefa: code=${e.code}, message=${e.message}');
      throw Exception('Não foi possível salvar. Tente novamente.');
    } catch (e) {
      print('ERRO GERAL criarTarefa: $e');
      rethrow;
    }
  }

  Future<void> _criarTarefasRecorrentes(TarefaDto tarefaOriginal) async {
    try {
      List<DateTime> ocorrencias = [];

      // ✨ SE FOR MENSAL: Faz o cálculo perfeito somando os meses um a um!
      if (tarefaOriginal.tipoRecorrencia == TipoRecorrencia.mensal) {
        DateTime dataAux = tarefaOriginal.dataInicial!;
        // Adiciona a primeira (mês atual)
        ocorrencias.add(dataAux);

        // Gera as próximas 11 ocorrências para os próximos meses
        for (int i = 1; i < 12; i++) {
          // Avança exatamente 1 mês mantendo o mesmo dia
          dataAux = DateTime(dataAux.year, dataAux.month + 1, dataAux.day);
          ocorrencias.add(dataAux);
        }
      } else {
        // ✨ PARA OS OUTROS TIPOS (Semanal, Diário, Personalizado): Usa o serviço original
        ocorrencias = RecorrenciaService.gerarProximasOcorrencias(
          dataInicial: tarefaOriginal.dataInicial!,
          tipo: tarefaOriginal.tipoRecorrencia,
          configuracao: tarefaOriginal.configuracaoRecorrencia,
          quantidade: 12,
        );
      }

      // Salva as repetições no Firebase (começa do índice 1 porque a primeira já foi salva no criarTarefa)
      for (int i = 1; i < ocorrencias.length; i++) {
        final tarefaRecorrente = TarefaDto(
          tituloTarefa: tarefaOriginal.tituloTarefa,
          diasRealizacao: tarefaOriginal.diasRealizacao,
          horario: tarefaOriginal.horario,
          horarioInicio: tarefaOriginal.horarioInicio,
          horarioFim: tarefaOriginal.horarioFim,
          dataInicial:
              ocorrencias[i], // ✨ Agora a data virá perfeita de mês em mês!
          metaId: tarefaOriginal.metaId,
          tituloMeta: tarefaOriginal.tituloMeta,
          tag: tarefaOriginal.tag,
          status: 'pendente',
          userId: _userId,
          dataCriacao: DateTime.now(),
          tipoRecorrencia: TipoRecorrencia.naoRepete,
          configuracaoRecorrencia: null,
        );

        final docRef = _firestore.collection(_collection).doc();
        tarefaRecorrente.id = docRef.id;
        await docRef.set(tarefaRecorrente.toMap());
      }
    } catch (e) {
      print('AVISO: Erro ao criar tarefas recorrentes: $e');
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

      final updateData = {
        'userId': _userId,
        'tituloTarefa': tarefa.tituloTarefa,
        'diasRealizacao': tarefa.diasRealizacao,
        'horario': tarefa.horario,
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

  Stream<List<TarefaDto>> buscarTarefasStream(
    String titulo, {
    String? mes,
    int? dia,
  }) {
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

            final mesesMap = {
              'Janeiro': 1,
              'Fevereiro': 2,
              'Março': 3,
              'Abril': 4,
              'Maio': 5,
              'Junho': 6,
              'Julho': 7,
              'Agosto': 8,
              'Setembro': 9,
              'Outubro': 10,
              'Novembro': 11,
              'Dezembro': 12,
            };

            return tarefas.where((tarefa) {
              final bateTitulo =
                  titulo.isEmpty ||
                  tarefa.tituloTarefa.toLowerCase().contains(
                    titulo.toLowerCase(),
                  );

              var bateMes = true;
              if (mes != null && mesesMap.containsKey(mes)) {
                bateMes =
                    (tarefa.dataInicial ?? tarefa.dataCriacao).month ==
                    mesesMap[mes];
              }

              var bateDia = true;
              if (dia != null) {
                bateDia = (tarefa.dataInicial ?? tarefa.dataCriacao).day == dia;
              }

              return bateTitulo && bateMes && bateDia;
            }).toList();
          });
    } catch (e) {
      print('ERRO GERAL buscarTarefasStream: $e');
      throw Exception('Não foi possível buscar as tarefas.');
    }
  }

  Future<void> atualizarStatus(String id, String novoStatus) async {
    await _firestore.collection(_collection).doc(id).update({
      'status': novoStatus,
      'dataConclusao': novoStatus == 'concluida'
          ? FieldValue.serverTimestamp()
          : null,
    });
  }

  Future<List<TarefaDto>> obterTarefasConcluidas(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'concluida')
          .get();

      return querySnapshot.docs
          .map((doc) => TarefaDto.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar concluídas: $e');
      return [];
    }
  }
}
