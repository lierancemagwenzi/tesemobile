import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';

class TopPerformingDialog extends StatelessWidget {
  final List<Video> topVideos;
  final List<Playlist> topPlaylists;
  final List<Channel> topChannels;

  const TopPerformingDialog({
    super.key,
    required this.topVideos,
    required this.topPlaylists,
    required this.topChannels,
  });

  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Background Blur
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: primaryDark.withOpacity(0.85)),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        _buildSection(
                          "TOP VIDEOS",
                          Icons.play_circle_fill,
                          topVideos,
                          _videoItem,
                        ),
                        const SizedBox(height: 30),
                        _buildSection(
                          "TOP PLAYLISTS",
                          Icons.featured_play_list,
                          topPlaylists,
                          _playlistItem,
                        ),
                        const SizedBox(height: 30),
                        _buildSection(
                          "TOP CHANNELS",
                          Icons.stars_rounded,
                          topChannels,
                          _channelItem,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Media Leaderboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    List items,
    Widget Function(dynamic, int) itemBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: brandGreen, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (items.isEmpty)
          const Text(
            "No data available",
            style: TextStyle(color: Colors.white24),
          )
        else
          ...items
              .asMap()
              .entries
              .map((entry) => itemBuilder(entry.value, entry.key))
              .toList(),
      ],
    );
  }

  // --- ITEM WIDGETS ---

  Widget _videoItem(dynamic item, int index) {
    final video = item as Video;
    return _baseCard(
      index: index,
      title: video.title ?? "Untitled Video",
      subtitle: "${video.viewCount ?? 0} views • ${video.likeCount ?? 0} likes",
      imageUrl: video.thumbnailUrl,
      trailing:
          "${video.currency ?? '\$'}${video.price?.toStringAsFixed(2) ?? '0.00'}",
    );
  }

  Widget _playlistItem(dynamic item, int index) {
    final playlist = item as Playlist;
    return _baseCard(
      index: index,
      title: playlist.title ?? "Untitled Playlist",
      subtitle:
          "${playlist.videoCount ?? 0} videos • ${playlist.total_sales} sales",
      imageUrl: playlist.thumbnailUrl,
      trailing: "REVENUE\n\$${playlist.total_earnings}",
    );
  }

  Widget _channelItem(dynamic item, int index) {
    final channel = item as Channel;
    return _baseCard(
      index: index,
      title: channel.name ?? "Unknown Channel",
      subtitle:
          "${channel.videoCount ?? 0} videos • ${channel.playlistCount ?? 0} playlists",
      imageUrl: channel.logoUrl,
      isCircle: true,
      trailing: "LVL ${index + 1}",
    );
  }

  Widget _baseCard({
    required int index,
    required String title,
    required String subtitle,
    String? imageUrl,
    String? trailing,
    bool isCircle = false,
  }) {
    // Ranking Colors
    Color rankColor = index == 0
        ? const Color(0xFFFFD700)
        : (index == 1 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Ranking Badge
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              "#${index + 1}",
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Thumbnail
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : BorderRadius.circular(10),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.white10,
            ),
            child: imageUrl == null
                ? const Icon(Icons.image, color: Colors.white24)
                : null,
          ),
          const SizedBox(width: 15),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                trailing,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: brandGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
