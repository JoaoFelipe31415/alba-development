import 'package:alba/domain/entities/recorrencia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TarefaDto {
  String? id;
  String tituloTarefa;
  List<String> diasRealizacao;
  String? horario;
  String? horarioInicio;
  String? horarioFim;
  DateTime? dataInicial;
  String? metaId;
  String? tituloMeta;
  String? tag;
  String status;
  String userId;
  DateTime dataCriacao;
  DateTime? dataConclusao;
  TipoRecorrencia tipoRecorrencia;
  ConfiguracaoRecorrencia? configuracaoRecorrencia;

  TarefaDto({
    this.id,
    required this.tituloTarefa,
    required this.diasRealizacao,
    this.horario,
    this.horarioInicio,
    this.horarioFim,
    this.dataInicial,
    this.metaId,
    this.tituloMeta,
    this.tag,
    required this.status,
    required this.userId,
    required this.dataCriacao,
    this.dataConclusao,
    this.tipoRecorrencia = TipoRecorrencia.naoRepete,
    this.configuracaoRecorrencia,
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

  void setHorarioInicio(String? value) {
    horarioInicio = value;
  }

  void setHorarioFim(String? value) {
    horarioFim = value;
  }

  void setDataInicial(DateTime? value) {
    dataInicial = value;
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

  void setTipoRecorrencia(TipoRecorrencia value) {
    tipoRecorrencia = value;
  }

  void setConfiguracaoRecorrencia(ConfiguracaoRecorrencia? value) {
    configuracaoRecorrencia = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'tituloTarefa': tituloTarefa,
      'diasRealizacao': diasRealizacao,
      'horario': horario,
      'horarioInicio': horarioInicio,
      'horarioFim': horarioFim,
      'dataInicial': dataInicial != null
          ? Timestamp.fromDate(dataInicial!)
          : null,
      'metaId': metaId,
      'tituloMeta': tituloMeta,
      'tag': tag,
      'status': status,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'dataConclusao': dataConclusao != null
          ? Timestamp.fromDate(dataConclusao!)
          : null,
      'tipoRecorrencia': tipoRecorrencia.value,
      'configuracaoRecorrencia': configuracaoRecorrencia?.toMap(),
    };
  }

  factory TarefaDto.fromMap(Map<String, dynamic> data, String id) {
    String _tratarString(dynamic valor) {
      if (valor == null) return '';
      if (valor is String) return valor;
      try {
        return valor.id;
      } catch (e) {
        return valor.toString();
      }
    }

    // Função de segurança adicionada aqui para evitar o crash
    DateTime? _converterTimestamp(dynamic campo) {
      if (campo == null) return null;
      if (campo is Timestamp) return campo.toDate();
      return null;
    }

    return TarefaDto(
      id: data['id'] ?? id,
      tituloTarefa: data['tituloTarefa'] ?? '',
      diasRealizacao: List<String>.from(data['diasRealizacao'] ?? []),
      horario: data['horario'],
      horarioInicio: data['horarioInicio'],
      horarioFim: data['horarioFim'],
      dataInicial: _converterTimestamp(data['dataInicial']), // Alterado
      metaId: _tratarString(data['metaId']),
      tituloMeta: data['tituloMeta'],
      tag: data['tag'],
      status: data['status'] ?? 'pendente',
      userId: _tratarString(data['userId']),
      dataCriacao:
          _converterTimestamp(data['dataCriacao']) ??
          DateTime.now(), // Alterado
      dataConclusao: _converterTimestamp(data['dataConclusao']), // Alterado
      tipoRecorrencia: TipoRecorrencia.fromString(
        data['tipoRecorrencia'] ?? '',
      ),
      configuracaoRecorrencia: ConfiguracaoRecorrencia.fromMap(
        data['configuracaoRecorrencia'] as Map<String, dynamic>?,
      ),
    );
  }
}
