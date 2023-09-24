// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/repo.dart';

final controllerProvider = Provider((ref) {
  final repo = ref.read(repoProvider);
  return Controller(repo: repo, ref: ref);
});

class Controller {
  final Repo repo;
  final ProviderRef ref;
  Controller({
    required this.repo,
    required this.ref,
  });

  Stream<QuerySnapshot<Object>> waiterList(String? restroId) {
    return repo.waitersList(restroId!);
  }

  Stream<QuerySnapshot<Object>> restroList(String? restroId) {
    return repo.restroList(restroId);
  }

  
}
