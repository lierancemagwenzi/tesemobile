import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TeseLiveCommentsOverlay extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> currentUser;

  const TeseLiveCommentsOverlay({
    super.key,
    required this.eventId,
    required this.currentUser,
  });

  @override
  State<TeseLiveCommentsOverlay> createState() =>
      _TeseLiveCommentsOverlayState();
}

class _TeseLiveCommentsOverlayState extends State<TeseLiveCommentsOverlay> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;
  bool _userIsScrolling = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // AUTO-SCROLL LOGIC
  void _scrollToBottom() {
    if (_userIsScrolling) return; // Don't snap if user is reading old comments

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || _isSending) return;

    // 1. Clear the UI immediately for a "snappy" feel
    final String text = _commentController.text.trim();
    final Map<String, dynamic> user = widget.currentUser;
    _commentController.clear();

    setState(() {
      _isSending = true;
      _userIsScrolling = false; // Ensure we snap to the new comment
    });

    try {
      // 2. REMOVE THE 'await' and the '.timeout'
      // By not awaiting, we trigger the write and move to the next line immediately.
      FirebaseFirestore.instance
          .collection('live-events')
          .doc(widget.eventId)
          .collection('comments')
          .add({
            'userName': user['name'] ?? 'Guest',
            'userImage': user['image'] ?? '',
            'userId': user['id'],
            'comment': text,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 3. Reset the spinner immediately
      // The comment will stay on screen because of the StreamBuilder's local cache.
      if (mounted) {
        setState(() => _isSending = false);
      }
    } catch (e) {
      debugPrint("Local cache error: $e");
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          // 1. COMMENTS LIST (Faded top)
          Expanded(
            child: ShaderMask(
              shaderCallback: (Rect rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black, Colors.black],
                  stops: [0.0, 0.2, 1.0], // Fades top 20%
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollStartNotification)
                    _userIsScrolling = true;
                  if (_scrollController.position.atEdge &&
                      _scrollController.position.pixels != 0) {
                    _userIsScrolling = false; // Resume auto-scroll at bottom
                  }
                  return false;
                },
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('live-events')
                      .doc(widget.eventId)
                      .collection('comments')
                      .orderBy('createdAt', descending: false)
                      .limitToLast(50) // Performance optimization
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();

                    final docs = snapshot.data!.docs;
                    _scrollToBottom();

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return 1 == 1
                            ? _buildCommentItem(
                                data['userName'],
                                data['comment'],
                              )
                            : _buildCommentRow(data);
                      },
                    );
                  },
                ),
              ),
            ),
          ),

          // 2. INPUT FIELD (Glassmorphism)
          // _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String user, String msg, {bool isTip = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,

          child: ClipRRect(
            
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: isTip ? Colors.red.withOpacity(0.3) : Colors.black26,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "$user  ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            // TextSpan(
                            //   text: msg,
                            //   style: const TextStyle(
                            //     fontSize: 13,
                            //     color: Colors.white70,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: msg,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentRow(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white10,
                backgroundImage:
                    data['userImage'] != null && data['userImage'].isNotEmpty
                    ? NetworkImage(data['userImage'])
                    : null,
                child: data['userImage'] == null || data['userImage'].isEmpty
                    ? const Icon(
                        LucideIcons.user,
                        size: 12,
                        color: Colors.white24,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${data['userName']}  ",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Color(0xFF00D285), // Tese Green
                          ),
                        ),
                        // TextSpan(
                        //   text: data['comment'] ?? '',
                        //   style: const TextStyle(
                        //     fontSize: 13,
                        //     color: Colors.white,
                        //     height: 1.3,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            data['comment'] ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Say something...",
                  hintStyle: TextStyle(color: Colors.white54),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _submitComment(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _submitComment,
            child: CircleAvatar(
              radius: 23,
              backgroundColor: const Color(0xFF00D285),
              child: _isSending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(LucideIcons.send, color: Colors.black, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
