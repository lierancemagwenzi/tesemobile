import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart'; // For Haptic Feedback

class LiveLikeButton extends StatelessWidget {
  final String eventId;
  final String userId;

  const LiveLikeButton({
    super.key,
    required this.eventId,
    required this.userId,
  });
  String _formatLikes(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
    } else {
      return count.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String cleanEventId = eventId.toString();
    final String cleanUserId = userId.toString();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. THE HEART BUTTON (User Status)
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .collection('likes')
              .doc(userId)
              .snapshots(),
          builder: (context, snapshot) {
            final bool hasLiked = snapshot.hasData && snapshot.data!.exists;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact(); // Makes the tap feel "real"
                _toggleLike(hasLiked);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                    color: hasLiked ? Colors.transparent : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: AnimatedScale(
                  scale: hasLiked ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.bounceOut,
                  child: Icon(
                    LucideIcons.heart,
                    size: 28,
                    color: hasLiked ? Colors.red : Colors.white,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 4),

        // 2. THE LIKE COUNT (Global Status)
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text(
                "0",
                style: TextStyle(color: Colors.white, fontSize: 12),
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final int count = data['likesCount'] ?? 0;

            return Text(
              _formatLikes(count),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper to format 1000 as 1k, etc.
  String _formatCount(int count) {
    if (count >= 1000) return "${(count / 1000).toStringAsFixed(1)}k";
    return count.toString();
  }

  Future<void> _toggleLike(bool currentlyLiked) async {
    final docRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('likes')
        .doc(userId);

    final eventRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId);

    WriteBatch batch = FirebaseFirestore.instance.batch();

    if (currentlyLiked) {
      batch.delete(docRef);
      // Use set with merge to be safe
      batch.set(eventRef, {
        'likesCount': FieldValue.increment(-1),
      }, SetOptions(merge: true));
    } else {
      batch.set(docRef, {
        'uid': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      // FIX: Changed .update to .set with merge: true
      batch.set(eventRef, {
        'likesCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
    }

    await batch
        .commit()
        .then((_) {
          print("Firestore Update Successful");
        })
        .catchError((error) {
          print("Firestore Update FAILED: $error");
        });
  }
}
