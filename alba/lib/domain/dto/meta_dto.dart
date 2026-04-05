class MetaDto {
  String? id;
  String tituloMeta;
  String? descricao;
  DateTime prazo;
  String tag; // 'negocio' ou 'faculdade'
  String userId;
  DateTime dataCriacao;

  MetaDto({
    this.id,
    required this.tituloMeta,
    this.descricao,
    required this.prazo,
    required this.tag,
    required this.userId,
    required this.dataCriacao,
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

  // Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'tituloMeta': tituloMeta,
      'descricao': descricao ?? '',
      'prazo': prazo,
      'tag': tag,
      'userId': userId,
      'dataCriacao': dataCriacao,
    };
  }

  // Converter do documento Firestore para objeto
  factory MetaDto.fromMap(Map<String, dynamic> data, String id) {
    return MetaDto(
      id: id,
      tituloMeta: data['tituloMeta'] ?? '',
      descricao: data['descricao'],
      prazo: (data['prazo'] as dynamic).toDate() ?? DateTime.now(),
      tag: data['tag'] ?? 'faculdade',
      userId: data['userId'] ?? '',
      dataCriacao: (data['dataCriacao'] as dynamic).toDate() ?? DateTime.now(),
    );
  }
}
