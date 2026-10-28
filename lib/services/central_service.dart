import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ocorrencia.dart';

class CentralService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User get _usuario {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw StateError('É necessário estar autenticado.');
    }

    return usuario;
  }

  Stream<List<Ocorrencia>> acompanhar() {
    return _db
        .collection('ocorrencias')
        .orderBy('criadoEm', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Ocorrencia.fromDoc(doc))
              .toList(),
        );
  }

  Future<void> registrar({
    required String titulo,
    required String local,
    required String descricao,
  }) async {
    final usuario = _usuario;

    await _db.collection('ocorrencias').add({
      'titulo': titulo.trim(),
      'local': local.trim(),
      'descricao': descricao.trim(),
      'autorId': usuario.uid,
      'autorNome': usuario.displayName ?? usuario.email ?? 'Anônimo',
      'resolvido': false,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> alterarStatus(
    Ocorrencia item, {
    required bool novoStatus,
  }) async {
    final usuario = _usuario;

    if (usuario.uid != item.autorId) {
      throw StateError(
        'Apenas o responsável pela ocorrência pode alterar o status.',
      );
    }

    await _db.collection('ocorrencias').doc(item.id).update({
      'resolvido': novoStatus,
    });
  }

  Future<void> enviarPista(
    String ocorrenciaId,
    String mensagem,
  ) async {
    final usuario = _usuario;
    final texto = mensagem.trim();

    if (texto.isEmpty) {
      throw ArgumentError('A pista não pode estar vazia.');
    }

    final referencia =
        _db.collection('ocorrencias').doc(ocorrenciaId);

    // Confirma que a ocorrência existe.
    final ocorrencia = await referencia.get();

    if (!ocorrencia.exists) {
      throw StateError('A ocorrência não foi encontrada.');
    }

    await referencia.collection('pistas').add({
      'mensagem': texto,
      'autorId': usuario.uid,
      'autorNome':
          usuario.displayName ?? usuario.email ?? 'Anônimo',
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pistas(
    String ocorrenciaId,
  ) {
    return _db
        .collection('ocorrencias')
        .doc(ocorrenciaId)
        .collection('pistas')
        .orderBy('criadoEm', descending: false)
        .snapshots();
  }
}