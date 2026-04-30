import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/models/dashboard_model.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';

import '../../src/models/UserModel.dart';

class GenreDetailWidget extends StatelessWidget {
  final Category genre;
  final bool isDark;

  const GenreDetailWidget({
    super.key,
    required this.genre,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDark
        ? Colors.black
        : const Color(0xFFF8F9FA);
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color teseGreen = const Color(0xFF00D285);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: backgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: textColor,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    genre.name ?? 'Genre',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient background using Tese colors
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              teseGreen.withOpacity(0.4),
                              backgroundColor,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: teseGreen,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: teseGreen,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: "ARTISTS"),
                      Tab(text: "ALBUMS"),
                    ],
                  ),
                  backgroundColor,
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              GenreArtistsTab(genre: genre),
              GenreAlbumsTab(genre: genre),
            ],
          ),
        ),
      ),
    );
  }
}

// Import your User model, Category model, and ClientUserController

class GenreArtistsTab extends StatefulWidget {
  final Category genre;

  const GenreArtistsTab({super.key, required this.genre});

  @override
  StateMVC<GenreArtistsTab> createState() => _GenreArtistsTabState();
}

class _GenreArtistsTabState extends StateMVC<GenreArtistsTab> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  late ClientUserController _con;

  _GenreArtistsTabState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForGenreArtists(widget.genre.id!, page: 1, limit: 10);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Trigger when 200px from the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final pagination = _con.genreArtistResponse?.pagination;

    if (_isLoadingMore ||
        pagination == null ||
        _currentPage >= (pagination.totalPages)) {
      return;
    }

    setState(() => _isLoadingMore = true);
    _currentPage++;

    await _con.listenForGenreArtists(
      widget.genre.id!,
      page: _currentPage,
      limit: 10,
    );

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final response = _con.genreArtistResponse;

    // Show loader only on the very first empty load
    if (response == null && _currentPage == 1) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D285)),
      );
    }

    // Assuming your modified GenreArtistResponse now maps to a list of Users
    // If your response still says .music, you'll need to update your model to .artists
    final artistList = response?.artists ?? [];

    if (artistList.isEmpty) {
      return const Center(
        child: Text(
          "No artists found in this genre",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: artistList.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == artistList.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final artist = artistList[index];
        return _buildArtistTile(artist, isDark);
      },
    );
  }

  Widget _buildArtistTile(User artist, bool isDark) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(2), // Subtle border ring
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            // ignore: deprecated_member_use
            color: const Color(0xFF00D285).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: CircleAvatar(
          radius: 32,
          backgroundColor: Colors.grey[900],
          backgroundImage: NetworkImage(artist.selfie ?? ''),
        ),
      ),
      title: Text(
        artist.fullname ?? 'Unknown Artist',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
      subtitle: Row(
        children: [
          const Icon(LucideIcons.users, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            "Artist • Tese Africa",
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.pushNamed(context, '/CreatorProfile', arguments: artist);
      },
    );
  }
}

class GenreAlbumsTab extends StatefulWidget {
  final Category genre;

  const GenreAlbumsTab({super.key, required this.genre});

  @override
  StateMVC createState() => _GenreAlbumsTabState();
}

class _GenreAlbumsTabState extends StateMVC<GenreAlbumsTab> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  late ClientUserController _con;

  _GenreAlbumsTabState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    // Initial fetch for the genre's albums
    _con.listenForGenreAlbums(widget.genre.id ?? 0, page: 1, limit: 10);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final pagination = _con.genreAlbumResponse?.pagination;

    if (_isLoadingMore ||
        pagination == null ||
        _currentPage >= pagination.totalPages) {
      return;
    }

    setState(() => _isLoadingMore = true);
    _currentPage++;

    await _con.listenForGenreAlbums(
      widget.genre.id ?? 0,
      page: _currentPage,
      limit: 10,
    );

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final response = _con.genreAlbumResponse;

    if (response == null && _currentPage == 1) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D285)),
      );
    }

    final albumList = response?.albums ?? [];

    if (albumList.isEmpty) {
      return const Center(
        child: Text(
          "No albums found in this genre",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 0.72, // Space for 1:1 image + 2 lines of text
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final album = albumList[index];
              return _buildAlbumCard(album, isDark);
            }, childCount: albumList.length),
          ),
        ),

        // Loading Indicator at the bottom
        if (_isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
      ],
    );
  }

  Widget _buildAlbumCard(Playlist album, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/PlaylistVideos',
          arguments: {'playlist': album, 'channel': _con.channel},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  album.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            album.title ?? 'Untitled Album',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            album.channel?.creator?.fullname ?? 'Tese Artist',
            maxLines: 1,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
