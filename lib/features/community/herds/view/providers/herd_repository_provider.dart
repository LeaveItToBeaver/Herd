import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/herd_repository.dart';

part 'herd_repository_provider.g.dart';

/// Basic repository provider for herd operations
@Riverpod(keepAlive: true)
HerdRepository herdRepository(Ref ref) {
  return HerdRepository(FirebaseFirestore.instance);
}
