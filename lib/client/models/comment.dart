import 'package:cloud_firestore/cloud_firestore.dart';

class VideoComment {
  final String userId;
  final String username;
  final String comment;
  final DateTime time;

  VideoComment({
    required this.userId,
    required this.username,
    required this.comment,
    required this.time,
  });

  // Convert to Map to send to Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'comment': comment,
      'time': FieldValue.serverTimestamp(), // Use server time for accuracy
    };
  }
}
