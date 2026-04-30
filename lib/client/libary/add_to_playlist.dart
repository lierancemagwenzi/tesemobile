import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/models/personal_playlist.dart';
import 'package:intl/intl.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';

class AddToPlaylistSheet extends StatefulWidget {
  final Video video; // The video/song we want to add

  const AddToPlaylistSheet({super.key, required this.video});

  // STATIC HELPER: Call this from anywhere in the app
  static void show(BuildContext context, Video video) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddToPlaylistSheet(video: video),
    );
  }

  @override
  StateMVC<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends StateMVC<AddToPlaylistSheet> {
  late ClientUserController _con;

  _AddToPlaylistSheetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    // Load the user's personal playlists immediately
    _con.listenForPersonalPlaylists(0);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // 70% of screen
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // 1. HANDLE BAR
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 2. HEADER
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Add to Playlist",
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),

          // 3. CREATE NEW OPTION
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF00D285),
              child: Icon(LucideIcons.plus, color: Colors.white),
            ),
            title: Text(
              "New Playlist",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              final String? title = await _showCreatePlaylistDialog(context);
              if (title != null && title.isNotEmpty) {
                await _con.createPlaylist({"title": title});
                _con.listenForPersonalPlaylists(0); // Refresh
              }
            },
          ),
          const Divider(height: 1, indent: 70),

          // 4. THE LIST OF PLAYLISTS
          Expanded(
            child: _con.personal_playlists.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00D285)),
                  )
                : ListView.builder(
                    itemCount: _con.personal_playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = _con.personal_playlists[index];
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.library,
                            color: Color(0xFF00D285),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          playlist.title,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "${playlist.itemCount} items",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () async {
                          // ADD LOGIC
                          bool? success = await _con.addToPlaylistPlaylist({
                            "playlist_id": playlist.id,
                            "video_id": widget.video.id,
                          });

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success == true
                                      ? "Added to ${playlist.title}"
                                      : "Already in playlist",
                                ),
                                backgroundColor: success == true
                                    ? const Color(0xFF00D285)
                                    : Colors.amber[800],
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showCreatePlaylistDialog(BuildContext context) async {
    final TextEditingController _titleController = TextEditingController();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                LucideIcons.plusCircle,
                color: const Color(0xFF00D285),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                "New Playlist",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: _titleController,
            autofocus: true,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Enter playlist title",
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00D285), width: 2),
              ),
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _titleController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D285),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Create",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
