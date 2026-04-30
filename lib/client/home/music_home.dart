import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/home/all_music_artists.dart';
import 'package:smacredit/client/home/genre_widget.dart';
import 'package:smacredit/client/home/music_search_widget.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class MusicHomeWidget extends StatefulWidget {
  const MusicHomeWidget({super.key});

  @override
  StateMVC<MusicHomeWidget> createState() => _MusicHomeWidgetState();
}

class _MusicHomeWidgetState extends StateMVC<MusicHomeWidget> {
  final Color teseRed = const Color(0xFFFF3B30);

  late ClientUserController _con;

  _MusicHomeWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForMusicDashboard();
    _con.listenForTrendingMusic();
  }

  PopupMenuItem<String> _buildSearchMenuItem(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: InkWell(
        onTap: () {
          _handleSearchNavigation(value);
        },
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearchNavigation(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => type == 'music'
            ? MusicSearchView()
            : type == 'playlists'
            ? PlaylistSearchView()
            : ArtistSearchView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? Colors.black
        : const Color(0xFFF8F9FA);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color teseGreen = const Color(0xFF00D285);
    final Color teseRed = const Color(0xFFFF3B30);

    // 1. Safety Check for Null Data
    if (_con.musicDashboardResponse == null || _con.trendingData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D285)),
      );
    }

    final discovery = _con.musicDashboardResponse!.data;
    final trending = _con.trendingData!;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // APP BAR (Spotify Style)
            SliverAppBar(
              backgroundColor: backgroundColor,
              floating: true,
              automaticallyImplyLeading: false,
              elevation: 0,
              title: Text(
                "Explore Music/Podcasts",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  // 1. The Trigger Icon
                  icon: Icon(LucideIcons.search, color: textColor),

                  // 2. Visual Styling
                  offset: const Offset(0, 50), // Moves the menu below the bar
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isDark ? const Color(0xFF282828) : Colors.white,

                  // 3. The Logic when an item is clicked
                  onSelected: (String value) {
                    switch (value) {
                      case 'music':
                        // Navigate to Search with Music filter
                        break;
                      case 'artists':
                        // Navigate to Search with Artist filter
                        break;
                      case 'playlists':
                        // Navigate to Search with Playlist/Album filter
                        break;
                    }
                  },

                  // 4. Building the Menu Items
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        _buildSearchMenuItem(
                          context,
                          value: 'music',
                          icon: LucideIcons.music,
                          title: 'Search Music/Podcasts',
                          isDark: isDark,
                        ),
                        const PopupMenuDivider(height: 1),
                        _buildSearchMenuItem(
                          context,
                          value: 'artists',
                          icon: LucideIcons.users,
                          title: 'Search Artists/Podcasters',
                          isDark: isDark,
                        ),
                        const PopupMenuDivider(height: 1),
                        _buildSearchMenuItem(
                          context,
                          value: 'playlists',
                          icon: LucideIcons.library,
                          title: 'Search Playlists/Albums',
                          isDark: isDark,
                        ),
                      ],
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. GENRES (The Top Pi
                  _buildSectionHeader("Pick Your Vibe", textColor),
                  _buildGenreList(discovery.genres, isDark),

                  // 2. TRENDING TRACKS (Large Featured Cards)
                  _buildSectionHeader("Trending Tracks", textColor),
                  _buildTrendingTracks(
                    trending.data.trendingTracks,
                    teseRed,
                    isDark,
                  ),

                  // 3. TRENDING ARTISTS (Circular Story-style)
                  _buildSectionHeader(
                    "Artists You'll Love",
                    textColor,
                    subTitlte: "Explore",
                    callback: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => AllArtistsView(),
                        ),
                      );
                    },
                  ),
                  _buildArtistCircleRow(trending.data.trendingArtists, isDark),

                  // 4. NEW ALBUMS (Latest from Discovery)
                  _buildSectionHeader("New Albums", textColor),
                  _buildAlbumScroll(discovery.albums, isDark),

                  // 5. LATEST MUSIC (Discovery -> Latest)
                  _buildSectionHeader("Freshly Added", textColor),
                  _buildLatestMusicList(discovery.latest, isDark),

                  // 6. TRENDING ALBUMS (Grid or List at bottom)
                  _buildSectionHeader("Popular Albums", textColor),
                  _buildAlbumList(trending.data.trendingAlbums, isDark),

                  const SizedBox(height: 120), // Mini Player Clearance
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildSectionHeader(
    String title,
    Color color, {
    String? subTitlte,
    VoidCallback? callback,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subTitlte != null && callback != null)
            InkWell(
              onTap: callback,

              child: Text(
                subTitlte,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Pills for Genres
  Widget _buildGenreList(List genres, bool isDark) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: genres.length,
        itemBuilder: (context, i) => InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) =>
                    GenreDetailWidget(genre: genres[i], isDark: isDark),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: Center(
              child: Text(
                genres[i].name ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Featured Trending Tracks
  Widget _buildTrendingTracks(List<Video> tracks, Color teseRed, bool isDark) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          final track = tracks[i];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/Player',
                arguments: {'video': track},
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: 1 == 1
                            ? buildNetworkImage(
                                track.thumbnailUrl ?? '',
                                height: 160,
                                width: 160,
                                isDark: isDark,
                              )
                            : Image.network(
                                track.thumbnailUrl ?? '',
                                height: 160,
                                width: 160,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: teseRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "TRENDING",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    track.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    track.artist?.fullname ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Circular Artists
  Widget _buildArtistCircleRow(List<User> artists, bool isDark) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: artists.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/CreatorProfile',
                arguments: artists[i],
              );
            },
            child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: artists[i].selfie ?? '',
                  // 1. Define the dimensions to match your radius (radius 40 = height/width 80)
                  imageBuilder: (context, imageProvider) =>
                      CircleAvatar(radius: 40, backgroundImage: imageProvider),
                  // 2. The Loading State (Spotify-style shimmer or grey circle)
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white10 : Colors.black87,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00D285),
                        ),
                      ),
                    ),
                  ),
                  // 3. The Error State
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[900],
                    ),
                    child: const Icon(LucideIcons.user, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  artists[i].name ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Vertical Album List (Popular Albums)
  Widget _buildAlbumList(List<Playlist> albums, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: albums.length,
      itemBuilder: (context, i) => ListTile(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/PlaylistVideos',
            arguments: {'playlist': albums[i], 'channel': _con.channel},
          );
        },
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: 1 == 1
              ? buildNetworkImage(
                  albums[i].thumbnailUrl ?? '',
                  width: 50,
                  height: 50,
                  isDark: isDark,
                )
              : Image.network(
                  albums[i].thumbnailUrl ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(
          albums[i].title ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          albums[i].channel?.creator?.fullname ?? '',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(LucideIcons.playCircle, size: 20),
      ),
    );
  }

  // 4. NEW ALBUMS SCROLL (Discovery -> albums)
  Widget _buildAlbumScroll(List<Playlist> albums, bool isDark) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: albums.length,
        itemBuilder: (context, i) {
          final album = albums[i];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/PlaylistVideos',
                arguments: {'playlist': albums[i], 'channel': _con.channel},
              );
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: 1 == 1
                        ? buildNetworkImage(
                            album.thumbnailUrl ?? '',
                            height: 140,
                            width: 140,
                            isDark: isDark,
                          )
                        : Image.network(
                            album.thumbnailUrl ?? '',
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                Container(color: Colors.grey[900]),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    album.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    album.channel?.creator?.fullname ?? 'Tese Artist',
                    maxLines: 1,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 5. LATEST MUSIC LIST (Discovery -> latest)
  // Styled as a high-density vertical list for quick browsing
  Widget _buildLatestMusicList(List<Video> latest, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: latest.length > 5
          ? 5
          : latest.length, // Limit to top 5 for the dashboard
      itemBuilder: (context, i) {
        final track = latest[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: 1 == 1
                    ? buildNetworkImage(
                        track.thumbnailUrl ?? '',
                        isDark: isDark,
                        width: 60,
                        height: 60,
                      )
                    : Image.network(
                        track.thumbnailUrl ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track.artist?.fullname ?? 'Featured Artist',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Play Button with Tese Green touch
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/Player',
                    arguments: {'video': track},
                  );
                },
                icon: const Icon(
                  LucideIcons.playCircle,
                  color: Color(0xFF00D285),
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget buildNetworkImage(
  String url, {
  double? height,
  double? width,
  BorderRadius? borderRadius,
  bool isCircle = false,
  required bool isDark,
}) {
  return CachedNetworkImage(
    imageUrl: url,
    httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},

    imageBuilder: (context, imageProvider) => Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
      ),
    ),
    placeholder: (context, url) => Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.grey[300]!,
      highlightColor: isDark ? Colors.white24 : Colors.grey[100]!,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
        ),
      ),
    ),
    errorWidget: (context, url, error) => Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[300],
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image,
        color: isDark ? Colors.white30 : Colors.grey,
      ),
    ),
  );
}
