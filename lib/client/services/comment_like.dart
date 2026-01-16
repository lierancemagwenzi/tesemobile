import 'package:cloud_firestore/cloud_firestore.dart';

class CommentLikeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> toggleCommentLike(
    int videoId,
    String commentId,
    int userId,
  ) async {
    // Reference to the specific comment
    DocumentReference commentRef = _db
        .collection('videos')
        .doc(videoId.toString())
        .collection('comments')
        .doc(commentId);

    // Reference to the specific user's like within that comment
    DocumentReference likeRef = commentRef.collection('likes').doc(userId.toString());

    DocumentSnapshot likeDoc = await likeRef.get();
    WriteBatch batch = _db.batch();

    if (likeDoc.exists) {
      // UNLIKE
      batch.delete(likeRef);
      batch.update(commentRef, {'likes_count': FieldValue.increment(-1)});
    } else {
      // LIKE
      batch.set(likeRef, {'timestamp': FieldValue.serverTimestamp()});
      batch.update(commentRef, {
        'likes_count': FieldValue.increment(1),
      }, );
    }

    await batch.commit();
  }
}
