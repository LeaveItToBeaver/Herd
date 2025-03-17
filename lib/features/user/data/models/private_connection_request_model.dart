// lib/features/user/data/models/private_connection_request.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class PrivateConnectionRequest {
  final String requesterId;
  final String? requesterName;
  final String? requesterUsername;
  final String? requesterProfileImageURL;
  final DateTime? timestamp;
  final String status; // "pending", "accepted", "rejected"

  PrivateConnectionRequest({
    required this.requesterId,
    this.requesterName,
    this.requesterUsername,
    this.requesterProfileImageURL,
    this.timestamp,
    required this.status,
  });

  factory PrivateConnectionRequest.fromMap(Map<String, dynamic> map) {
    return PrivateConnectionRequest(
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