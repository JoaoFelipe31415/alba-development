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

  static String _tratarStringObrigatoria(dynamic valor) {
    if (valor == null) return '';

    if (valor is String) {
      return valor.trim();
    }

    try {
      return valor.id.toString().trim();
    } catch (_) {
      return valor.toString().trim();
    }
  }

  static String? _tratarStringOpcional(dynamic valor) {
    if (valor == null) return null;

    if (valor is String) {
      final texto = valor.trim();
      return texto.isEmpty ? null : texto;
    }

    try {
      final texto = valor.id.toString().trim();
      return texto.isEmpty ? null : texto;
    } catch (_) {
      final texto = valor.toString().trim();
      return texto.isEmpty ? null : texto;
    }
  }

  static DateTime? _converterTimestamp(dynamic campo) {
    if (campo == null) return null;

    if (campo is Timestamp) {
      return campo.toDate();
    }

    return null;
  }

  static List<String> _converterListaString(dynamic valor) {
    if (valor == null) return [];

    if (valor is! List) return [];

    return valor
        .map((item) => item.toString().trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toMap() {
    // Campo novo é a fonte principal.
    final inicio = _tratarStringOpcional(horarioInicio) ??
        _tratarStringOpcional(horario);

    final fim = _tratarStringOpcional(horarioFim);

    return {
      'id': id,
      'userId': userId,
      'tituloTarefa': tituloTarefa,
      'diasRealizacao': diasRealizacao,

      // Campo antigo mantido por compatibilidade com telas antigas.
      'horario': inicio,

      // Campos novos corretos.
      'horarioInicio': inicio,
      'horarioFim': fim,

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
    final horarioLegado = _tratarStringOpcional(data['horario']);

    final horarioInicio =
        _tratarStringOpcional(data['horarioInicio']) ?? horarioLegado;

    final horarioFim = _tratarStringOpcional(data['horarioFim']);

    final configRaw = data['configuracaoRecorrencia'];

    final Map<String, dynamic>? configMap = configRaw is Map
        ? Map<String, dynamic>.from(configRaw)
        : null;

    return TarefaDto(
      id: _tratarStringOpcional(data['id']) ?? id,
      tituloTarefa: _tratarStringOpcional(data['tituloTarefa']) ?? '',
      diasRealizacao: _converterListaString(data['diasRealizacao']),

      // Mantém compatibilidade com tarefas antigas.
      horario: horarioInicio,
      horarioInicio: horarioInicio,
      horarioFim: horarioFim,

      dataInicial: _converterTimestamp(data['dataInicial']),
      metaId: _tratarStringOpcional(data['metaId']),
      tituloMeta: _tratarStringOpcional(data['tituloMeta']),
      tag: _tratarStringOpcional(data['tag']),
      status: _tratarStringOpcional(data['status']) ?? 'pendente',
      userId: _tratarStringObrigatoria(data['userId']),
      dataCriacao: _converterTimestamp(data['dataCriacao']) ?? DateTime.now(),
      dataConclusao: _converterTimestamp(data['dataConclusao']),
      tipoRecorrencia: TipoRecorrencia.fromString(
        data['tipoRecorrencia']?.toString(),
      ),
      configuracaoRecorrencia: ConfiguracaoRecorrencia.fromMap(configMap),
    );
  }
}