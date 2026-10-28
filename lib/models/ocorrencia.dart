import 'package:cloud_firestore/cloud_firestore.dart';

class Ocorrencia {
  final String id;
  final String titulo;
  final String local;
  final String descricao;
  final String autorId;
  final String autorNome;
  final bool resolvido;
  final DateTime? criadoEm;

  const Ocorrencia({
    required this.id,
    required this.titulo,
    required this.local,
    required this.descricao,
    required this.autorId,
    required this.autorNome,
    required this.resolvido,
    required this.criadoEm,
  });

  factory Ocorrencia.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final dados = doc.data() ?? {};

    return Ocorrencia(
      id: doc.id,
      titulo: dados['titulo'] as String? ?? '',
      local: dados['local'] as String? ?? '',
      descricao: dados['descricao'] as String? ?? '',
      autorId: dados['autorId'] as String? ?? '',
      autorNome: dados['autorNome'] as String? ?? 'Anônimo',
      resolvido: dados['resolvido'] as bool? ?? false,
      criadoEm: (dados['criadoEm'] as Timestamp?)?.toDate(),
    );
  }
}