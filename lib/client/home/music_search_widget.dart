import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
// Import your ClientUserController and Video model

class MusicSearchView extends StatefulWidget {
  const MusicSearchView({super.key});

  @override
  StateMVC<MusicSearchView> createState() => _MusicSearchViewState();
}

class _MusicSearchViewState extends StateMVC<MusicSearchView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchTextController = TextEditingController();
  bool _isFetchingMore = false;

  late ClientUserController _con;

  _MusicSearchViewState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pagination = _con.musicSearchResponse?.pagination;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore &&
          pagination != null &&
          pagination.currentPage < pagination.totalPages) {
        _loadNextPage();
      }
    }
  }

  Future<void> _loadNextPage() async {
    setState(() => _isFetchingMore = true);
    int nextPage = (_con.musicSearchResponse?.pagination?.currentPage ?? 1) + 1;
    await _con.searchMusic(_searchTextController.text, page: nextPage);
    if (mounted) setState(() => _isFetchingMore = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? Colors.black
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. SEARCH TEXTFIELD (Spotify Style)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchTextController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                cursorColor: const Color(0xFF00D285),
                decoration: InputDecoration(
                  hintText: "What do you want to listen to?",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _con.searchMusic(value, page: 1);
                  }
                },
              ),
            ),

            // 2. RESULTS LIST
            Expanded(child: _buildBody(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    // Show loading spinner for initial search
    if (_con.loading && _con.videos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D285)),
      );
    }

    // Show empty state
    if (_con.videos.isEmpty && _searchTextController.text.isNotEmpty) {
      return const Center(
        child: Text("No results found", style: TextStyle(color: Colors.grey)),
      );
    }

    // Show "Search something" prompt if empty
    if (_con.videos.isEmpty) {
      return const Center(
        child: Text(
          "Search for your favorite music",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _con.videos.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _con.videos.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final track = _con.videos[index];
        return _buildTrackTile(track, isDark);
      },
    );
  }

  Widget _buildTrackTile(Video track, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: 1 == 1
              ? buildNetworkImage(
                  track.thumbnailUrl ?? '',
                  width: 50,
                  height: 50,
                  isDark: isDark,
                )
              : Image.network(
                  track.thumbnailUrl ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
                ),
        ),
        title: Text(
          track.title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          track.artist?.fullname ?? 'Tese Artist',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(
          LucideIcons.moreVertical,
          color: Colors.grey,
          size: 18,
        ),
        onTap: () {
          Navigator.pushNamed(context, '/Player', arguments: {'video': track});
        },
      ),
    );
  }
}

class PlaylistSearchView extends StatefulWidget {
  const PlaylistSearchView({super.key});

  @override
  _PlaylistSearchViewState createState() => _PlaylistSearchViewState();
}

class _PlaylistSearchViewState extends StateMVC<PlaylistSearchView> {
  late ClientUserController _con;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;

  _PlaylistSearchViewState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pagination = _con.playlistSearchResponse?.pagination;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore &&
          pagination != null &&
          pagination.currentPage < pagination.totalPages) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isFetchingMore = true);

    int nextPage =
        (_con.playlistSearchResponse?.pagination?.currentPage ?? 1) + 1;
    await _con.searchMusicPlaylists(_searchController.text, page: nextPage);

    if (mounted) {
      setState(() => _isFetchingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? Colors.black
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildSearchTextField(isDark),
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildSearchTextField(bool isDark) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(fontSize: 15),
        textInputAction: TextInputAction.search,
        onSubmitted: (val) {
          if (val.isNotEmpty) {
            _con.searchMusicPlaylists(val, page: 1, limit: 10);
          }
        },
        decoration: const InputDecoration(
          hintText: "Search Playlists & Albums",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(LucideIcons.library, size: 18, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_con.loading && _con.playlists.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D285)),
      );
    }

    if (_con.playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 40,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            const SizedBox(height: 12),
            const Text(
              "Find your favorite collections",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _con.playlists.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _con.playlists.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final playlist = _con.playlists[index];
        return _buildPlaylistTile(playlist, isDark);
      },
    );
  }

  Widget _buildPlaylistTile(Playlist playlist, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/PlaylistVideos',
            arguments: {'playlist': playlist, 'channel': _con.channel},
          );
        },
        child: Row(
          children: [
            // Square Album Art
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: 1 == 1
                  ? buildNetworkImage(
                      playlist.thumbnailUrl ?? '',
                      width: 64,
                      height: 64,
                      isDark: isDark,
                    )
                  : Image.network(
                      playlist.thumbnailUrl ?? '',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        width: 64,
                        height: 64,
                        color: isDark ? Colors.white10 : Colors.black12,
                        child: const Icon(
                          LucideIcons.music,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title ?? 'Untitled',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Playlist • ${playlist.channel?.creator?.fullname ?? 'Tese Africa'}",
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class ArtistSearchView extends StatefulWidget {
  const ArtistSearchView({super.key});

  @override
  _ArtistSearchViewState createState() => _ArtistSearchViewState();
}

class _ArtistSearchViewState extends StateMVC<ArtistSearchView> {
  late ClientUserController _con;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;

  _ArtistSearchViewState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pagination = _con.artistSearchResponse?.pagination;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore &&
          pagination != null &&
          pagination.currentPage < pagination.totalPages) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isFetchingMore = true);

    int nextPage =
        (_con.artistSearchResponse?.pagination?.currentPage ?? 1) + 1;
    // Assuming you have this method in your controller similar to searchMusic
    await _con.searchMusicArtists(_searchController.text, page: nextPage);

    if (mounted) {
      setState(() => _isFetchingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark
        ? Colors.black
        : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildArtistSearchField(isDark),
        ),
      ),
      body: _buildArtistBody(isDark),
    );
  }

  Widget _buildArtistSearchField(bool isDark) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(fontSize: 15),
        textInputAction: TextInputAction.search,
        onSubmitted: (val) {
          if (val.isNotEmpty) {
            _con.searchMusicArtists(val, page: 1, limit: 10);
          }
        },
        decoration: const InputDecoration(
          hintText: "Search Artists & Podcasters",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(LucideIcons.users, size: 18, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildArtistBody(bool isDark) {
    if (_con.loading && _con.artists.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D285)),
      );
    }

    if (_con.artists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.users,
              size: 40,
              color: isDark ? Colors.white10 : Colors.black12,
            ),
            const SizedBox(height: 12),
            const Text(
              "Discover your next favorite artist",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _con.artists.length + (_isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _con.artists.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final artist = _con.artists[index];
        return _buildArtistTile(artist, isDark);
      },
    );
  }

  Widget _buildArtistTile(User artist, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/CreatorProfile', arguments: artist);
        },
        contentPadding: EdgeInsets.zero,
        leading: CachedNetworkImage(
          imageUrl: artist.selfie ?? '',
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
        title: Text(
          artist.fullname ?? 'Unknown Artist',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        subtitle: Text(
          "Artist •",
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 16,
          color: Colors.grey,
        ),
      ),
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
