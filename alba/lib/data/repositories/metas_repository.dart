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
      if (a.dataCriacao == null && b.dataCriacao == null) return 0;
      if (a.dataCriacao == null) return 1;
      if (b.dataCriacao == null) return -1;
      return b.dataCriacao!.compareTo(a.dataCriacao!);
    });

    return metas;
  }

  Future<String> _obterTelefoneDoUsuario() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Usuário não autenticado');

    try {
  
      final todosUsuarios = await _firestore.collection('Users').get();
      
      print('🔎 [DEBUG TOTAL] Quantidade de documentos em Users: ${todosUsuarios.docs.length}');
      
      for (var doc in todosUsuarios.docs) {
        print('🆔 ID do Documento no Banco: "${doc.id}"');
        print('📄 Campos internos do documento: ${doc.data()}');
      }

      // Busca oficial por UID
      final userQuery = await _firestore
          .collection('Users')
          .where('uid', isEqualTo: currentUser.uid.trim())
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final telefoneAchado = userQuery.docs.first.id;
        print('✅ [DEBUG ALBA] Telefone encontrado com sucesso: $telefoneAchado');
        return telefoneAchado;
      }

      final emailLimpo = currentUser.email?.toLowerCase().trim();
      final userQueryEmail = await _firestore
          .collection('Users')
          .where('email', isEqualTo: emailLimpo)
          .limit(1)
          .get();

      if (userQueryEmail.docs.isNotEmpty) {
        return userQueryEmail.docs.first.id;
      }

      return ""; 
    } catch (e) {
      print('Erro crítico ao escanear coleção Users: $e');
      return "";
    }
  }

  Future<List<String>> _obterTodosIdentificadores() async {
    List<String> ids = [_userId];
    try {
      final telefone = await _obterTelefoneDoUsuario();
      
      if (telefone.isNotEmpty) {
       
        if (!ids.contains(telefone)) {
          ids.add(telefone);
        }
        
        final telefoneComIgual = '=$telefone';
        if (!ids.contains(telefoneComIgual)) {
          ids.add(telefoneComIgual);
        }
      }
    } catch (e) {
      print('Aviso ao obter telefone: $e');
    }
    return ids;
  }

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
      final idsValidos = await _obterTodosIdentificadores();
      final querySnapshot = await _firestore
          .collection('Metas')
          .where('userId', whereIn: idsValidos)
          .get();

      return _converterSnapshotParaMetas(querySnapshot);
    } catch (e) {
      throw Exception('Não foi possível carregar as metas. Tente novamente.');
    }
  }

  // O STREAM COM OS PRINTS DE DIAGNÓSTICO
  Stream<List<MetaDto>> obterMetasStream() async* {
    try {
      // 1. Vai buscar a lista com o UID e o Telefone
      final idsValidos = await _obterTodosIdentificadores();
      
      // 🚨 PRINT 1: Vamos ver se ele achou o seu telefone com o "="
      print('🚨 [DEBUG ALBA] IDs que o app vai buscar: $idsValidos'); 

      yield* _firestore
          .collection('Metas')
          .where('userId', whereIn: idsValidos) 
          .snapshots()
          .map((querySnapshot) {
            
            // 🚨 PRINT 2: Vamos ver quantas metas o banco devolveu
            print('🚨 [DEBUG ALBA] O Firebase retornou ${querySnapshot.docs.length} metas no total!');
            
            return _converterSnapshotParaMetas(querySnapshot);
          });
    } catch (e) {
      // 🚨 PRINT 3: Se der erro, ele vai avisar qual é
      print('🚨 [DEBUG ALBA] ERRO FATAL: $e');
      throw Exception('Não foi possível carregar as metas em tempo real. Tente novamente.');
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
      await _firestore.collection('Metas').doc(id).delete();

      final tarefas = await _firestore
          .collection('Tarefas')
          .where('metaId', isEqualTo: id)
          .get();

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
      final idsValidos = await _obterTodosIdentificadores();
      final querySnapshot = await _firestore
          .collection('Metas')
          .where('userId', whereIn: idsValidos)
          .get();

      final metas = _converterSnapshotParaMetas(querySnapshot);

      return metas
          .where((meta) => meta.tituloMeta.toLowerCase().contains(titulo.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Não foi possível buscar as metas. Tente novamente.');
    }
  }

  Stream<List<MetaDto>> buscarMetasStream(String titulo) async* {
    try {
      final idsValidos = await _obterTodosIdentificadores();
      
      yield* _firestore
          .collection('Metas')
          .where('userId', whereIn: idsValidos)
          .snapshots()
          .map((querySnapshot) {
            final metas = _converterSnapshotParaMetas(querySnapshot);

            if (titulo.isEmpty) return metas;
            
            return metas
                .where((meta) => meta.tituloMeta.toLowerCase().contains(titulo.toLowerCase()))
                .toList();
          });
    } catch (e) {
      throw Exception('Não foi possível buscar as metas em tempo real. Tente novamente.');
    }
  }
}
