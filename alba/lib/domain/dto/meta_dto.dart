import 'package:cloud_firestore/cloud_firestore.dart';

class MetaDto {
  String? id;
  String tituloMeta;
  String? descricao;
  DateTime prazo;
  String tag; // 'negocio' ou 'faculdade'
  String userId;
  DateTime dataCriacao;

  bool concluida;
  DateTime? dataConclusao;

  MetaDto({
    this.id,
    required this.tituloMeta,
    this.descricao,
    required this.prazo,
    required this.tag,
    required this.userId,
    required this.dataCriacao,
    this.concluida = false,
    this.dataConclusao,
  });

  void setTitulo(String value) {
    tituloMeta = value;
  }

  void setDescricao(String value) {
    descricao = value;
  }

  void setPrazo(DateTime value) {
    prazo = value;
  }

  void setTag(String value) {
    tag = value;
  }

  void setConcluida(bool value) {
    concluida = value;
    dataConclusao = value ? DateTime.now() : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'tituloMeta': tituloMeta,
      'descricao': descricao ?? '',
      'prazo': prazo,
      'tag': tag,
      'userId': userId,
      'dataCriacao': dataCriacao,
      'concluida': concluida,
      'dataConclusao': dataConclusao,
    };
  }

  factory MetaDto.fromMap(Map<String, dynamic> data, String id) {
    return MetaDto(
      id: id,
      tituloMeta: data['tituloMeta']?.toString() ?? '',
      descricao: data['descricao']?.toString(),
      prazo: _parseDate(data['prazo']) ?? DateTime.now(),
      tag: data['tag']?.toString() ?? 'faculdade',
      userId: data['userId']?.toString() ?? '',
      dataCriacao: _parseDate(data['dataCriacao']) ?? DateTime.now(),
      concluida: data['concluida'] == true,
      dataConclusao: _parseDate(data['dataConclusao']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
