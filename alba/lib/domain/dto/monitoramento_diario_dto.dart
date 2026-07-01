import 'package:cloud_firestore/cloud_firestore.dart';

class MonitoramentoDiarioDto {
  final String? id;
  final String userId;
  final DateTime data;
  final String sentimento;
  final String descanso;
  final String gargalo;

  MonitoramentoDiarioDto({
    this.id,
    required this.userId,
    required this.data,
    required this.sentimento,
    required this.descanso,
    required this.gargalo,
  });

  factory MonitoramentoDiarioDto.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return MonitoramentoDiarioDto(
      id: documentId,
      userId: map['userId'] ?? '',
      data: map['data'] != null
          ? (map['data'] as Timestamp).toDate()
          : DateTime.now(),
      sentimento: map['sentimento']?.toString() ?? '',
      descanso: map['descanso']?.toString() ?? '',
      gargalo: map['gargalo']?.toString() ?? '',
    );
  }
}
