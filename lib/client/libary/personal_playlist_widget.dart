import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/libary/tese_empty_state.dart';
import 'package:smacredit/client/models/personal_playlist.dart';
import 'package:smacredit/client/models/media_response.dart'; // Your Video Model
import 'package:smacredit/main.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart'; // For teseAudioHandler access

class PersonalPlaylistItemsScreen extends StatefulWidget {
  final PersonalPlaylist personalPlaylist;

  const PersonalPlaylistItemsScreen({
    super.key,
    required this.personalPlaylist,
  });

  @override
  StateMVC<PersonalPlaylistItemsScreen> createState() =>
      _PersonalPlaylistItemsScreenState();
}

class _PersonalPlaylistItemsScreenState
    extends StateMVC<PersonalPlaylistItemsScreen> {
  late ClientUserController _con;

  _PersonalPlaylistItemsScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    // Assuming your controller has a method to fetch items for a personal playlist
    _con.listenForPersonalPlaylistVideos(widget.personalPlaylist.id);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // 1. DYNAMIC GRADIENT HEADER
          _buildSliverHeader(isDark, bgColor, textColor),

          // 2. ACTION CONTROLS (Download, Shuffle, Play)
          _buildActionControls(isDark),

          // 3. ADD SONGS BUTTON
          // SliverToBoxAdapter(child: _buildAddSongsButton(isDark, textColor)),

          // 4. THE TRACK LIST
          if (_con.videos.isEmpty)
            SliverToBoxAdapter(
              child: TeseEmptyState(
                title: "Your playlist is empty",
                message:
                    "Start adding your favorite African tracks to build your collection.",
                icon: LucideIcons.music,
                buttonText: "Find Songs",
                onAction: () {
                  Navigator.pushNamed(context, '/Dashboard');
                },
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final Video video = _con.videos[index];
                return _buildTrackItem(index, video, isDark, textColor);
              }, childCount: _con.videos.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(bool isDark, Color bgColor, Color textColor) {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      elevation: 0,
      backgroundColor: bgColor,
      leading: IconButton(
        icon: Icon(LucideIcons.chevronLeft, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2E3B8B), // Subtle deep blue gradient
                bgColor,
              ],
            ),
          ),
          padding: const EdgeInsets.only(left: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.personalPlaylist.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${_con.videos.length} songs",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionControls(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            const Icon(
              LucideIcons.arrowDownCircle,
              color: Colors.grey,
              size: 28,
            ),
            const Spacer(),
            Icon(LucideIcons.shuffle, color: const Color(0xFF00D285), size: 24),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                if (_con.videos.isNotEmpty) {
                  teseAudioHandler.stop();
                  teseAudioHandler.setVideo(_con.videos[0], _con.videos);
                  Navigator.pushReplacementNamed(context, '/TeseAudoPlayer');
                  // teseAudioHandler.startTesePlaylist(
                  //   _con.videos,
                  //   initialIndex: 0,
                  // );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF00D285),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSongsButton(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(LucideIcons.plus, color: textColor, size: 24),
          ),
          const SizedBox(width: 15),
          Text(
            "Add songs",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(int index, Video video, bool isDark, Color textColor) {
    return ListTile(
      onTap: () {
        teseAudioHandler.stop();
        teseAudioHandler.setVideo(_con.videos[index], _con.videos);
        Navigator.pushReplacementNamed(context, '/TeseAudoPlayer');

        // teseAudioHandler.startTesePlaylist(_con.videos, initialIndex: index);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          video.thumbnailUrl ?? "",
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) =>
              Container(color: Colors.grey, width: 50, height: 50),
        ),
      ),
      title: Text(
        video.title ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              "E",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              video.description ?? "Artist Name",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
      trailing: Icon(LucideIcons.moreHorizontal, color: Colors.grey, size: 20),
    );
  }
}
