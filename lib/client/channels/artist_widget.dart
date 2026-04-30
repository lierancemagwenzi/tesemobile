import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/live_button.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/src/content-creator/events/widgets/creator_events.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../../src/models/UserModel.dart';

class ArtistChannelStyleScreen extends StatefulWidget {
  final User artist; // Your Artist Model
  const ArtistChannelStyleScreen({super.key, required this.artist});

  @override
  StateMVC<ArtistChannelStyleScreen> createState() =>
      _ArtistChannelStyleScreenState();
}

class _ArtistChannelStyleScreenState extends StateMVC<ArtistChannelStyleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Color teseGreen = const Color(0xFF00D285);
  late AnimationController _shimmerController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _con.listenForCreatorChannels(widget.artist.id ?? 0);
    _con.listenForArtistVideos(widget.artist.id ?? 0);
    _con.listenForCreatorPlaylists(widget.artist.id ?? 0);
    _con.checkCreatorFollow(widget.artist.id!);
    _shimmerController = AnimationController.unbounded(vsync: this);
  }

  late ClientUserController _con;

  _ArtistChannelStyleScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : Colors.white;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: bgColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. TOP APP BAR (Search/More)
              SliverAppBar(
                backgroundColor: bgColor,
                pinned: true,
                elevation: 0,
                actions: [
                  // IconButton(icon: const Icon(Icons.cast), onPressed: () {}),
                  // IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  // IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
                ],
              ),

              // 2. ARTIST BRANDING SECTION
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Banner Image (Netflix/YouTube style 16:9)
                    _buildArtistBanner(widget.artist.banner),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          // Large Artist Avatar
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: teseGreen,
                            child: CircleAvatar(
                              radius: 43,
                              backgroundImage: CachedNetworkImageProvider(
                                widget.artist.selfie ?? "",
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Artist Name & Stats
                          Text(
                            "${widget.artist.name ?? "Artist Name"} ${widget.artist.lastname ?? ""}",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "@${widget.artist.username} • ${widget.artist.followerCount} followers",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ViewLiveEventsButton(
                            artist: widget.artist,
                            isLiveNow:
                                true, // You can get this from your controller's event list
                          ),

                          // The Primary "Follow/Subscribe" Action
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                UtilsHelper.ensureAuth(
                                  context,
                                  action: "to follow the creator",
                                  onAuthenticated: () async {
                                    if (_con.isFollowingCreator == true) {
                                      final bool? resu = await _con
                                          .unFollowCreator({
                                            "creator_id": widget.artist.id,
                                          });
                                      _con.checkCreatorFollow(
                                        widget.artist.id ?? 0,
                                      );
                                      if (resu == true) {
                                        CustomMessageHandler().showSuccessSnakeBar(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          "Unfollowed",
                                        );
                                      } else {
                                        CustomMessageHandler().showErrorSnakeBar(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          "Something went wrong",
                                        );
                                      }
                                    } else {
                                      final bool? resu = await _con
                                          .followCreator({
                                            "creator_id": widget.artist.id,
                                          });
                                      _con.checkCreatorFollow(
                                        widget.artist.id ?? 0,
                                      );
                                      if (resu == true) {
                                        CustomMessageHandler().showSuccessSnakeBar(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          "followed",
                                        );
                                      } else {
                                        CustomMessageHandler().showErrorSnakeBar(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          "Something went wrong",
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                                foregroundColor: isDark
                                    ? Colors.black
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                _con.isFollowingCreator == true
                                    ? "Unfollow Creator"
                                    : "Follow Creator",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. STICKY TABS
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: teseGreen,
                    labelColor: isDark ? Colors.white : Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: "CHANNELS"),
                      Tab(text: "VIDEOS"),
                      Tab(text: "PLAYLISTS"),
                    ],
                  ),
                  bgColor,
                ),
              ),
            ];
          },
          // 4. TAB CONTENT
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildChannelsList(isDark), // Grid of their linked channels
              _buildLatestVideosList(
                isDark,
              ), // List of all videos across channels
              _buildPlaylistGrid(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildArtistBanner(String? url) {
    return AspectRatio(
      aspectRatio: 16 / 5,
      child: _buildNetworkImage(url ?? ""),
    );
  }

  Widget _buildChannelsGrid(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 4, // Replace with dynamic channel list
      itemBuilder: (context, index) {
        return Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
            ),
            const SizedBox(height: 10),
            const Text(
              "Official Vlogs",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "150k subscribers",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNetworkImage(
    String url, {
    double? width,
    double? height,
    double radius = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: 1 == 1
          ? CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,

              fit: BoxFit.cover,
              // 1. Placeholder shown while downloading
              placeholder: (context, url) => Container(
                color: Colors.grey[900], // Matches Tese Navy
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              // 2. Error widget shown if the link is broken
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white24),
              ),
            )
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _ShimmerBox(
                  width: width,
                  height: height,
                  controller: _shimmerController,
                );
              },

              errorBuilder: (context, error, stackTrace) => Container(
                width: width,
                height: height,
                color: Colors.grey[50],
              ),
            ),
    );
  }

  Widget _buildChannelsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _con.channels.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/CreatorChannelView',
              arguments: _con.channels[index],
            );
          },

          leading: _buildNetworkImage(
            _con.channels[index].logoUrl ?? "",
            height: 40,
            width: 40,
          ),
          title: Text(
            _con.channels[index].name ?? "",
            maxLines: 2,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${_con.channels[index].playlistCount} playlists • ${_con.channels[index].videoCount} videos",
          ),
          trailing: const Icon(Icons.more_vert, size: 20),
        );
      },
    );
  }

  Widget _buildPlaylistGrid(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _con.playlists.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/PlaylistVideos',
              arguments: {
                'playlist': _con.playlists[index],
                'channel': _con.channel,
              },
            );
          },

          leading: _buildNetworkImage(
            _con.playlists[index].thumbnailUrl ?? "",
            height: 40,
            width: 40,
          ),
          title: Text(
            _con.playlists[index].title ?? "",
            maxLines: 2,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            " ${_con.playlists[index].videoCount} ${_con.playlists[index].isAudio == true ? 'tracks' : 'Videos'}",
          ),
          trailing: Icon(
            _con.playlists[index].isAudio == true
                ? Icons.audiotrack
                : Icons.video_camera_back,
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildLatestVideosList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _con.videos.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/Player',
              arguments: {'video': _con.videos[index], 'channel': _con.channel},
            );
          },

          leading: _buildNetworkImage(
            _con.videos[index].thumbnailUrl ?? "",
            height: 40,
            width: 40,
          ),
          title: Text(
            _con.videos[index].title ?? "",
            maxLines: 2,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${_con.videos[index].likeCount} likes • ${_con.videos[index].viewCount} views",
          ),
          trailing: const Icon(Icons.more_vert, size: 20),
        );
      },
    );
  }

  Widget _buildArtistBio(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Biography",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "No bio available.",
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse your sticky header delegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);
  final TabBar _tabBar;
  final Color backgroundColor;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(context, shrinkOffset, overlapsContent) =>
      Container(color: backgroundColor, child: _tabBar);
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final AnimationController controller;

  const _ShimmerBox({this.width, this.height, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.white10, Colors.white24, Colors.white10]
                  : [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1.0 + controller.value, -0.3),
              end: Alignment(1.0 + controller.value, 0.3),
            ),
          ),
        );
      },
    );
  }
}
