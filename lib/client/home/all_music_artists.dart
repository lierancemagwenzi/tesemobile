import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/src/models/UserModel.dart';
// Import your User model, ArtistSearchResponse, and ClientUserController

class AllArtistsView extends StatefulWidget {
  const AllArtistsView({super.key});

  @override
  _AllArtistsViewState createState() => _AllArtistsViewState();
}

class _AllArtistsViewState extends StateMVC<AllArtistsView> {
  late ClientUserController _con;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isFetchingMore = false;

  _AllArtistsViewState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    // Initial data fetch
    _con.listenForArtists(page: 1, limit: 15);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pagination = _con.artistSearchResponse?.pagination;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_isFetchingMore &&
          pagination != null &&
          _currentPage < pagination.totalPages) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isFetchingMore = true);
    _currentPage++;

    await _con.listenForArtists(page: _currentPage, limit: 15);

    if (mounted) {
      setState(() => _isFetchingMore = false);
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
    final Color backgroundColor = isDark
        ? Colors.black
        : const Color(0xFFF8F9FA);
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. STYLIZED HEADER
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: 56,
                bottom: 16,
              ),
              title: Text(
                "All Artists",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF00D285).withOpacity(0.15),
                      backgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. ARTIST LIST
          _buildArtistSliverList(isDark),

          // 3. BOTTOM LOADING INDICATOR
          if (_isFetchingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF00D285),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildArtistSliverList(bool isDark) {
    final artists = _con.artists;

    if (_con.loading && artists.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D285)),
        ),
      );
    }

    if (artists.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text("No artists found", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final artist = artists[index];
        return _buildArtistTile(artist, isDark);
      }, childCount: artists.length),
    );
  }

  Widget _buildArtistTile(User artist, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () {
          Navigator.pushNamed(context, '/CreatorProfile', arguments: artist);
        },
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00D285).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: CachedNetworkImage(
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
        ),
        title: Text(
          artist.name ?? 'Featured Artist',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: const Text(
          "Artist • Discover on Tese",
          style: TextStyle(color: Colors.grey, fontSize: 12),
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
