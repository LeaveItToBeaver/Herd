import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Provider to get the count of a user's alt connections
final altConnectionCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  // Use collection group query to count the connections
  final snapshot = await FirebaseFirestore.instance
      .collection('altConnections')
      .doc(userId)
      .collection('userConnections')
      .count()
      .get();

  return snapshot.count ?? 0;
});