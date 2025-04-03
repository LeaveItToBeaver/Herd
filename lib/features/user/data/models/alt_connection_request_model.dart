// lib/features/user/data/models/alt_connection_request.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AltConnectionRequest {
  final String requesterId;
  final String? requesterName;
  final String? requesterUsername;
  final String? requesterProfileImageURL;
  final DateTime? timestamp;
  final String status; // "pending", "accepted", "rejected"

  AltConnectionRequest({
    required this.requesterId,
    this.requesterName,
    this.requesterUsername,
    this.requesterProfileImageURL,
    this.timestamp,
    required this.status,
  });

  factory AltConnectionRequest.fromMap(Map<String, dynamic> map) {
    return AltConnectionRequest(
      requesterId: map['requesterId'] ?? '',
      requesterName: map['requesterName'],
      requesterUsername: map['requesterUsername'],
      requesterProfileImageURL: map['requesterProfileImageURL'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterUsername': requesterUsername,
      'requesterProfileImageURL': requesterProfileImageURL,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
      'status': status,
    };
  }
}