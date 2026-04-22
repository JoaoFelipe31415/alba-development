import 'package:cloud_firestore/cloud_firestore.dart';

class TarefaDto {
  String? id;
  String tituloTarefa;
  List<String> diasRealizacao;
  String? horario;
  String? metaId;
  String? tituloMeta;
  String? tag; // 👈 NOVO
  String status;
  String userId;
  DateTime dataCriacao;

  TarefaDto({
    this.id,
    required this.tituloTarefa,
    required this.diasRealizacao,
    this.horario,
    this.metaId,
    this.tituloMeta,
    this.tag, // 👈 NOVO
    required this.status,
    required this.userId,
    required this.dataCriacao,
  });

  void setId(String value) {
    id = value;
  }

  void setTituloTarefa(String value) {
    tituloTarefa = value;
  }

  void setDiasRealizacao(List<String> value) {
    diasRealizacao = value;
  }

  void setHorario(String? value) {
    horario = value;
  }

  void setMetaId(String? value) {
    metaId = value;
  }

  void setTituloMeta(String? value) {
    tituloMeta = value;
  }

  void setTag(String? value) {
    tag = value;
  }

  void setStatus(String value) {
    status = value;
  }

  void setUserId(String value) {
    userId = value;
  }

  void setDataCriacao(DateTime value) {
    dataCriacao = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'tituloTarefa': tituloTarefa,
      'diasRealizacao': diasRealizacao,
      'horario': horario,
      'metaId': metaId,
      'tituloMeta': tituloMeta,
      'tag': tag, // 👈 NOVO
      'status': status,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
    };
  }

  factory TarefaDto.fromMap(Map<String, dynamic> data, String id) {
    String _tratarString(dynamic valor) {
      if (valor == null) return '';
      if (valor is String) return valor;
      // Se for um DocumentReference (o causador do erro), pegamos o ID dele
      try {
        return valor.id; 
      } catch (e) {
        return valor.toString();
      }
    }

    return TarefaDto(
      id: data['id'] ?? id,
      tituloTarefa: data['tituloTarefa'] ?? '',
      diasRealizacao: List<String>.from(data['diasRealizacao'] ?? []),
      horario: data['horario'],
      metaId: _tratarString(data['metaId']), // 👈 Ajustado
      tituloMeta: data['tituloMeta'],
      tag: data['tag'],
      status: data['status'] ?? 'pendente',
      userId: _tratarString(data['userId']), // 👈 Ajustado
      dataCriacao: data['dataCriacao'] != null 
          ? (data['dataCriacao'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
} 
    
//     return TarefaDto(
//       id: data['id'] ?? id,
//       tituloTarefa: data['tituloTarefa'] ?? '',
//       diasRealizacao: List<String>.from(data['diasRealizacao'] ?? []),
//       horario: data['horario'],
//       metaId: data['metaId'],
//       tituloMeta: data['tituloMeta'],
//       tag: data['tag'], // 👈 NOVO
//       status: data['status'] ?? 'pendente',
//       userId: data['userId'] ?? '',
//       dataCriacao: (data['dataCriacao'] as dynamic).toDate() ?? DateTime.now(),
//     );
//   }
// }
