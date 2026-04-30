import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

import '../controller/client_user_controller.dart';

// --- DUMMY MODELS ---
class SearchVideo {
  final String creator;
  final String title;
  final String image;
  final String likes;
  final String views;
  final String downloads;
  SearchVideo({
    required this.creator,
    required this.title,
    required this.image,
    required this.likes,
    required this.views,
    required this.downloads,
  });
}

class TrendingCreator {
  final String name;
  final String image;
  final bool isExclusive;
  TrendingCreator({
    required this.name,
    required this.image,
    this.isExclusive = false,
  });
}

// --- SEARCH WIDGET ---
class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends StateMVC<SearchWidget> {
  final Color brandGreen = const Color(0xFF00D285);
  final Color brandRed = const Color(0xFFFF4B2B);

  late ClientUserController _con;

  _SearchWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  bool videoOpen = false;
  bool creatorOpen = false;
  bool channelOpen = false;
  bool playlistOpen = false;

  // MOCK DATA BASED ON YOUR SCREENSHOTS
  final List<SearchVideo> popularVideos = [
    SearchVideo(
      creator: "TechMasterPro",
      title: "Complete Web Development",
      image: "https://invalid-url.com/1",
      likes: "9",
      views: "1.8k",
      downloads: "9",
    ),
    SearchVideo(
      creator: "Sarah Mitchell",
      title: "Advanced Photography",
      image: "https://invalid-url.com/2",
      likes: "7",
      views: "3.2k",
      downloads: "4",
    ),
    SearchVideo(
      creator: "James Cooper",
      title: "Marketing Masterclass ep 1",
      image: "https://invalid-url.com/3",
      likes: "4",
      views: "659",
      downloads: "4",
    ),
    SearchVideo(
      creator: "James Cooper",
      title: "Marketing Masterclass ep 2",
      image: "https://invalid-url.com/4",
      likes: "2",
      views: "923",
      downloads: "0",
    ),
  ];

  final List<TrendingCreator> trendingCreators = [
    TrendingCreator(
      name: "TechMasterPro",
      image: "https://invalid-url.com/5",
      isExclusive: true,
    ),
    TrendingCreator(name: "Sarah Mitchell", image: "https://invalid-url.com/6"),
    TrendingCreator(name: "James Cooper", image: "https://invalid-url.com/7"),
    TrendingCreator(name: "Elizabeth", image: "https://invalid-url.com/8"),
  ];

  // Robust image helper to prevent UI breakage from bad URLs
  Widget _buildNetworkImage(
    String url, {
    double height = 80,
    double width = 80,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: 1 == 1
          ? CachedNetworkImage(
              imageUrl: url,
              httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},

              fit: BoxFit.cover,
              width: width,
              height: height,
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
              errorBuilder: (context, error, stackTrace) => Container(
                width: width,
                height: height,
                color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200,
                child: Icon(
                  Icons.image_outlined,
                  color: isDark ? Colors.white12 : Colors.grey.shade400,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: true,
        elevation: 0,
        centerTitle: true,
        title: Image.asset(
          isDark ? "assets/images/logo-light.png" : "assets/images/logo.png",
          fit: BoxFit.contain,
          height: 50,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(isDark),

            if (_con.searchResult != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Video result${_con.searchResult?.videos.length ?? 0})",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        setState(() {
                          videoOpen = !videoOpen;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          !videoOpen
                              ? Icons.keyboard_arrow_down_outlined
                              : Icons.keyboard_arrow_up_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (videoOpen) ...[
                if (_con.searchResult?.videos.isNotEmpty == true) ...[
                  _buildPopularList(isDark),
                ] else
                  TeseEmptyWidget(),
              ],
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Channel result${_con.searchResult?.channels.length ?? 0})",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        setState(() {
                          channelOpen = !channelOpen;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          !channelOpen
                              ? Icons.keyboard_arrow_down_outlined
                              : Icons.keyboard_arrow_up_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (channelOpen) ...[
                if (_con.searchResult?.channels.isNotEmpty == true) ...[
                  _buildChannelList(isDark),
                ] else
                  TeseEmptyWidget(),
              ],
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Playlists result${_con.searchResult?.playlists.length ?? 0})",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        setState(() {
                          playlistOpen = !playlistOpen;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          !playlistOpen
                              ? Icons.keyboard_arrow_down_outlined
                              : Icons.keyboard_arrow_up_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (playlistOpen) ...[
                if (_con.searchResult?.playlists.isNotEmpty == true) ...[
                  _buildPlaylistList(isDark),
                ] else
                  TeseEmptyWidget(),
              ],

              // Center(
              //   child: TextButton(
              //     onPressed: () {},
              //     child: Text(
              //       "Show More",
              //       style: TextStyle(
              //         color: brandGreen,
              //         fontWeight: FontWeight.bold,
              //         fontSize: 16,
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ceators result(${_con.searchResult?.users.length ?? 0})",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        setState(() {
                          creatorOpen = !creatorOpen;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          !creatorOpen
                              ? Icons.keyboard_arrow_down_outlined
                              : Icons.keyboard_arrow_up_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (creatorOpen) ...[
                if ((_con.searchResult?.users.isNotEmpty == true))
                  _buildTrendingList(isDark)
                else
                  TeseEmptyWidget(),
              ],
              const SizedBox(height: 100),
            ], // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B22) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: TextFormField(
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              _con.search({'search': value});
            }
          },

          decoration: InputDecoration(
            hintText: "Search",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            suffixIcon: Icon(Icons.mic, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _con.searchResult?.videos.length ?? 0,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final video = _con.searchResult!.videos[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/Player',
              arguments: {'video': video},
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                _buildNetworkImage(video.thumbnailUrl ?? ""),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   video.creator,
                      //   style: const TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 12,
                      //   ),
                      // ),
                      Text(
                        video.title ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _iconStat(
                            Icons.favorite_border,
                            (video.likeCount ?? 0).toString(),
                          ),
                          _iconStat(
                            Icons.visibility_outlined,
                            (video.viewCount ?? 0).toString(),
                          ),
                          // _iconStat(
                          //   Icons.download_outlined,
                          //   (video.downloadCount ?? 0).toString(),
                          // ),
                        ],
                      ),
                      if (video.accessType == 'paid') ...[
                        SizedBox(height: 8),
                        Text(
                          "${video.currency ?? 'USD'} ${(video.price ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors
                                .white, // Note: This might be invisible on light theme now
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/Player',
                          arguments: {'video': video},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(90, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          // if (video.hasAccess == true)
                          //   Icon(Icons.lock_open, color: Colors.white)
                          // else
                          //   Icon(Icons.lock, color: Colors.yellow),
                          Text("Play"),
                          Icon(Icons.chevron_right, size: 14),
                        ],
                      ),
                    ),
                    // const Text(
                    //   "20 sec Pre Listen",
                    //   style: TextStyle(color: Colors.grey, fontSize: 10),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChannelList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _con.searchResult?.channels.length ?? 0,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final video = _con.searchResult!.channels[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/CreatorChannelView',
              arguments: video,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                _buildNetworkImage(video.logoUrl ?? ""),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   video.creator,
                      //   style: const TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 12,
                      //   ),
                      // ),
                      Text(
                        video.name ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _iconStat(
                            Icons.favorite_border,
                            (video.playlistCount ?? 0).toString(),
                          ),
                          _iconStat(
                            Icons.visibility_outlined,
                            (video.videoCount ?? 0).toString(),
                          ),
                          // _iconStat(
                          //   Icons.download_outlined,
                          //   (video.downloadCount ?? 0).toString(),
                          // ),
                        ],
                      ),

                      if (video.subscriptionEnabled == true) ...[
                        SizedBox(height: 8),
                        Text(
                          "${video.subscriptionCurrency ?? 'USD'} ${(video.subscriptionPrice ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors
                                .white, // Note: This might be invisible on light theme now
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/CreatorChannelView',
                          arguments: video,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(90, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text("Open"),
                          Icon(Icons.chevron_right, size: 14),
                        ],
                      ),
                    ),
                    // const Text(
                    //   "20 sec Pre Listen",
                    //   style: TextStyle(color: Colors.grey, fontSize: 10),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaylistList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _con.searchResult?.playlists.length ?? 0,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final video = _con.searchResult!.playlists[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/PlaylistVideos',
              arguments: {'playlist': video},
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                _buildNetworkImage(video.thumbnailUrl ?? ""),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   video.creator,
                      //   style: const TextStyle(
                      //     color: Colors.grey,
                      //     fontSize: 12,
                      //   ),
                      // ),
                      Text(
                        video.title ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _iconStat(
                            Icons.video_camera_back,
                            (video.videoCount ?? 0).toString(),
                          ),
                          // _iconStat(
                          //   Icons.visibility_outlined,
                          //   (video.videoCount ?? 0).toString(),
                          // ),
                          // _iconStat(
                          //   Icons.download_outlined,
                          //   (video.downloadCount ?? 0).toString(),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/PlaylistVideos',
                          arguments: {
                            'playlist': video,
                            'channel': _con.channel,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(90, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text("Open"),
                          Icon(Icons.chevron_right, size: 14),
                        ],
                      ),
                    ),
                    // const Text(
                    //   "20 sec Pre Listen",
                    //   style: TextStyle(color: Colors.grey, fontSize: 10),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconStat(IconData icon, String val) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(val, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildTrendingList(bool isDark) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: _con.searchResult?.users.length,
        itemBuilder: (context, index) {
          final creator = _con.searchResult?.users[index];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/CreatorProfile',
                arguments: creator!,
              );
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                children: [
                  Stack(
                    children: [
                      _buildNetworkImage(
                        creator?.selfie ?? "",
                        width: 140,
                        height: 100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    creator?.fullname ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
