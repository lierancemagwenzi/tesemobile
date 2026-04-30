import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/libary/tese_empty_state.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

class PersonalPlaylistList extends StatefulWidget {
  const PersonalPlaylistList({super.key});

  @override
  StateMVC<PersonalPlaylistList> createState() => _PersonalPlaylistListState();
}

class _PersonalPlaylistListState extends StateMVC<PersonalPlaylistList> {
  late ClientUserController _con;

  _PersonalPlaylistListState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForPersonalPlaylists(0);
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subTextColor = isDark ? Colors.white60 : Colors.black54;
    final Color iconBackground = isDark ? Colors.white10 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. MODERN COLLAPSING APP BAR
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: isDark ? Colors.black : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Your Playlists",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              if (currentuser.value.user?.id != null)
                IconButton(
                  icon: Icon(LucideIcons.plus, color: textColor),
                  onPressed: () async {
                    final String? title = await _showCreatePlaylistDialog(
                      context,
                    );

                    if (title != null && title.trim().isNotEmpty) {
                      // 1. Call your controller to save to the database
                      // Assuming your controller has a method like this:
                      bool? success = await _con.createPlaylist({
                        "title": title,
                      });

                      if (success == true) {
                        // 2. Refresh the list
                        _con.listenForPersonalPlaylists(0);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Playlist created successfully!"),
                            backgroundColor: Color(0xFF00D285),
                          ),
                        );
                      } else {
                        CustomMessageHandler().showErrorSnakeBar(
                          context,
                          "Something went wrong",
                        );
                      }
                    }
                  },
                ),
            ],
          ),

          // 2. THE PLAYLIST LIST
          if (_con.personal_playlists.isEmpty)
            SliverToBoxAdapter(
              child: TeseEmptyState(
                title: "Your playlists are empty",
                message:
                    "Start adding your favorite audio tracks to build your collection.",
                icon: LucideIcons.music,
                buttonText: "Find Songs",
                onAction: () {
                  Navigator.pushNamed(context, '/Dashboard');
                },
              ),
            ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final playlist = _con.personal_playlists[index];

              return Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/PersonalPlaylist',
                        arguments: playlist,
                      );
                      /* Navigate to Details */
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.library,
                        color: Color(0xFF00D285),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      playlist.title ?? "Untitled Playlist",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "${playlist.itemCount ?? 0} items • ${DateFormat('MMM d, yyyy').format(playlist.createdAt)}",
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                    ),
                    trailing: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: subTextColor.withOpacity(0.4),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 92),
                    child: Divider(height: 1),
                  ),
                ],
              );
            }, childCount: _con.personal_playlists.length),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
