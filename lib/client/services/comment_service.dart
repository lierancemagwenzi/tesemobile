import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> postComment1(
    int videoId,
    int userId,
    String username,
    String text,
  ) async {
    try {
      await _db
          .collection('videos')
          .doc(videoId.toString()) // Grouping by Video ID
          .collection('comments')
          .add({
            'user_id': userId,
            'username': username,
            'comment': text,
            'time': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print("Error posting comment: $e");
    }
  }

  Future<void> postComment(
    int videoId,
    int userId,
    String username,
    String text, {
    String? parentCommentId, // Add this
  }) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        print("Error: You are not signed into Firebase yet!");
        // You need to call FirebaseAuth.instance.signInWithCustomToken(yourToken);
      } else {
        print("firebase is signed in");
      }
      await _db
          .collection('videos')
          .doc(videoId.toString())
          .collection('comments')
          .add({
            'user_id': userId.toString(),
            'username': username,
            'comment': text,
            'time': FieldValue.serverTimestamp(),
            'parent_id':
                parentCommentId ?? "--", // If empty, it's a top-level comment
          });
    } catch (e) {
      print(e);
    }
  }
}
