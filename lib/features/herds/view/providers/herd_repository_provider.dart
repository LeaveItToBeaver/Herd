import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/herd_repository.dart';

/// Basic repository provider for herd operations
final herdRepositoryProvider = Provider<HerdRepository>((ref) {
  return HerdRepository(FirebaseFirestore.instance);
});
