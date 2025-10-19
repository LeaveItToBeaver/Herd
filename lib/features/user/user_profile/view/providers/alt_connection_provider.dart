import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'alt_connection_provider.g.dart';

/// Provider to get the count of a user's alt connections
@riverpod
Future<int> altConnectionCount(Ref ref, String userId) async {
  // Use collection group query to count the connections
  final snapshot = await FirebaseFirestore.instance
      .collection('altConnections')
      .doc(userId)
      .collection('userConnections')
      .count()
      .get();

  return snapshot.count ?? 0;
}
