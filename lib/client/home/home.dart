import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/home/tese_drawer.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/theme/app_theme.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class ClientHomeWidget extends StatefulWidget {
  const ClientHomeWidget({super.key});

  @override
  StateMVC<ClientHomeWidget> createState() => _ClientHomeWidgetState();
}

class _ClientHomeWidgetState extends StateMVC<ClientHomeWidget> {
  late ClientUserController _con;

  _ClientHomeWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForDashboard();
    _con.listenForDashboardVideos();
    _con.listenForTrendingCreators();
    _con.listenForDashboardCategories();
    _con.listenForVideoDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        drawer: currentuser.value.user?.userType?.toLowerCase() == 'creator'
            ? TeseDrawer()
            : null,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading:
              currentuser.value.user?.id != null &&
                  currentuser.value.user?.userType?.toLowerCase() == 'creator'
              ? InkWell(
                  onTap: () => _con.scaffoldKey.currentState?.openDrawer(),
                  child: const Icon(Icons.menu),
                )
              : null,
          centerTitle: true,
          title: Image.asset(
            isDark ? "assets/images/logo-light.png" : "assets/images/logo.png",
            fit: BoxFit.contain,
            height: 46,
          ),
          actions: [
            IconButton(
              icon: Icon(
                LucideIcons.search,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () => Navigator.pushNamed(context, '/Search'),
            ),
            IconButton(
              icon: Icon(
                LucideIcons.bell,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () {
                UtilsHelper.ensureAuth(
                  context,
                  action: "to view account notifications",
                  onAuthenticated: () =>
                      Navigator.pushNamed(context, '/Notifications'),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_con.dashboardModel?.video != null) _buildFeaturedHero(),

              _buildSectionHeader(
                context,
                "Browse by Category",
                showViewAll: true,
                routeName: '/CategoryExplorer',
              ),
              SizedBox(height: 8),
              _buildCategoryList(isDark),

              if ((_con.homeDashboard?.recentVideos.isNotEmpty ?? false)) ...[
                _buildSectionHeader(
                  context,
                  "Recent Videos",
                  showViewAll: false,
                  routeName: '/CreatorExplorer',
                ),
                const SizedBox(height: 8),
                _buildVideoList(isDark, _con.homeDashboard!.recentVideos),
              ],

              if ((_con.homeDashboard?.popularCreators.isNotEmpty ??
                  false)) ...[
                _buildSectionHeader(
                  context,
                  "Popular Creators",
                  showViewAll: true,
                  routeName: '/CreatorExplorer',
                ),
                const SizedBox(height: 8),
                _buildPopularCreatorList(
                  isDark,
                  _con.homeDashboard!.popularCreators,
                ),
              ],

              if ((_con.homeDashboard?.trendingVideos.isNotEmpty ?? false)) ...[
                _buildSectionHeader(
                  context,
                  "Trending Videos",
                  showViewAll: false,
                  routeName: '/CreatorExplorer',
                ),
                const SizedBox(height: 8),
                _buildVideoList(isDark, _con.homeDashboard!.trendingVideos),
              ],

              if ((_con.homeDashboard?.featuredChannels.isNotEmpty ??
                  false)) ...[
                _buildSectionHeader(
                  context,
                  "Featured Channels",
                  showViewAll: false,
                  routeName: '/CreatorExplorer',
                ),
                const SizedBox(height: 8),
                _buildFeaturedChannelList(
                  isDark,
                  _con.homeDashboard!.featuredChannels,
                ),
              ],

              if ((_con.dashboardModel?.creators?.length ?? 0) > 0) ...[
                _buildSectionHeader(
                  context,
                  "Featured Creators",
                  showViewAll: true,
                  routeName: '/CreatorExplorer',
                ),
                SizedBox(height: 8),
                _buildCreatorList(isDark),
              ],

              if (_con.videos.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  "Featured Videos",
                  showViewAll: false,
                  routeName: '/CreatorExplorer',
                ),
                SizedBox(height: 8),
                _buildVideoList(isDark, _con.videos),
              ],

              ..._con.the_categories.map(
                (e) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      e.name ?? '',
                      showViewAll: false,
                      routeName: '/CreatorExplorer',
                    ),
                    SizedBox(height: 8),
                    _buildVideoList(isDark, e.videos ?? []),
                  ],
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  // ─── FEATURED HERO ────────────────────────────────────────────────────────

  Widget _buildFeaturedHero() {
    const double heroHeight = 240.0;
    const double radius = 16.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // Thumbnail
            CachedNetworkImage(
              height: heroHeight,
              width: double.infinity,
              httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},
              imageUrl: "${_con.dashboardModel?.video?.video?.thumbnailUrl}",
              fit: BoxFit.cover,
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[600]!,
                child: Container(height: heroHeight, color: Colors.white),
              ),
              errorWidget: (context, url, error) => Container(
                height: heroHeight,
                color: Colors.grey[900],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),

            // Gradient overlay
            Container(
              height: heroHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),

            // Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // FEATURED badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: brandGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, color: Colors.orange, size: 13),
                        SizedBox(width: 4),
                        Text(
                          "FEATURED",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _con.dashboardModel?.video?.video?.title ?? "Tese Video",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/Player',
                        arguments: {
                          'video': _con.dashboardModel!.video!.video!,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      "Watch Now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SECTION HEADER ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required bool showViewAll,
    required String routeName,
  }) {
    return InkWell(
      onTap: showViewAll ? () => Navigator.pushNamed(context, routeName) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            if (showViewAll)
              Text(
                "See all",
                style: TextStyle(
                  color: brandGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── CATEGORY LIST ────────────────────────────────────────────────────────

  Widget _buildCategoryList(bool isDark) {
    return SizedBox(
      height: 215,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: _con.dashboardModel?.categories?.length ?? 0,
        itemBuilder: (context, index) {
          final cat = _con.dashboardModel!.categories![index];
          final Color cardColor = Color(
            int.parse(cat.color?.replaceAll('#', '0xFF') ?? '0xFFFF3B30'),
          );

          return InkWell(
            onTap: () => Navigator.pushNamed(context, '/Cat', arguments: cat),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 155,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card
                  Container(
                    height: 155,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Top shade
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Central artwork
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: _buildNetworkImage(cat.image ?? ""),
                              ),
                            ),
                          ),
                        ),

                        // Icon chip (top-left)
                        // Positioned(
                        //   top: 8,
                        //   left: 8,
                        //   child: Container(
                        //     padding: const EdgeInsets.all(5),
                        //     decoration: BoxDecoration(
                        //       color: cardColor,
                        //       borderRadius: BorderRadius.circular(8),
                        //     ),
                        //     child: _buildNetworkImage(
                        //       cat.icon ?? "",
                        //       width: 18,
                        //       height: 18,
                        //     ),
                        //   ),
                        // ),

                        // Video count (bottom-right)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${cat.videoCount}+ videos",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Text(
                      cat.name ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
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

  // ─── CREATOR LIST ─────────────────────────────────────────────────────────

  Widget _buildCreatorList(bool isDark) {
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: _con.dashboardModel?.creators?.length ?? 0,
        itemBuilder: (context, index) {
          final creator = _con.dashboardModel!.creators![index].user;
          return InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              '/CreatorProfile',
              arguments: creator!,
            ),
            borderRadius: BorderRadius.circular(75),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: creator?.selfie ?? "",
                      httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},
                      fit: BoxFit.cover,
                      height: 150,
                      width: 150,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[700]!,
                        child: Container(
                          height: 150,
                          width: 150,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.person,
                          color: Colors.white24,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    creator?.fullname ?? "Content Creator",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "Creator",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── VIDEO LIST ───────────────────────────────────────────────────────────

  Widget _buildVideoList(bool isDark, List videos) {
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final Video video = videos[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              '/Player',
              arguments: {'video': video},
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: video.thumbnailUrl ?? "",
                          fit: BoxFit.cover,
                          httpHeaders: {
                            'Cookie': cloudFrontCookieNotifier.value,
                          },
                          height: 130,
                          width: 160,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[700]!,
                            child: Container(
                              height: 130,
                              width: 160,
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 130,
                            width: 160,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.play_circle_outline,
                              color: Colors.white24,
                              size: 36,
                            ),
                          ),
                        ),
                      ),

                      // Price badge (paid content)
                      if (video.accessType == 'paid')
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: brandGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.workspace_premium,
                                  color: Colors.orange,
                                  size: 11,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  "${video.currency ?? "USD"} ${(video.price ?? 0.0).toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  // Title
                  Text(
                    video.title ?? "Tese content",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 3),

                  // Duration + views
                  Row(
                    children: [
                      Text(
                        UtilsHelper.formatLongDuration(
                          video.durationSeconds ?? 0,
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      const Text(
                        " · ",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Flexible(
                        child: Text(
                          "${video.viewCount ?? 0} views",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── POPULAR CREATOR LIST ─────────────────────────────────────────────────

  Widget _buildPopularCreatorList(bool isDark, List<User> creators) {
    return SizedBox(
      height: 205,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: creators.length,
        itemBuilder: (context, index) {
          final creator = creators[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              '/CreatorProfile',
              arguments: creator,
            ),
            borderRadius: BorderRadius.circular(75),
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: creator.selfie ?? "",
                      httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},
                      fit: BoxFit.cover,
                      height: 150,
                      width: 150,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[700]!,
                        child: Container(
                          height: 150,
                          width: 150,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.person,
                          color: Colors.white24,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    creator.fullname ?? "Content Creator",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if ((creator.totalViews ?? 0) > 0)
                    Text(
                      "${creator.totalViews} views",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── FEATURED CHANNEL LIST ────────────────────────────────────────────────

  Widget _buildFeaturedChannelList(
    bool isDark,
    List<Channel> channels,
  ) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final ch = channels[index];
          return InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              '/CreatorChannelView',
              arguments: ch,
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: ch.coverImageUrl ?? ch.logoUrl ?? "",
                      httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},
                      fit: BoxFit.cover,
                      height: 120,
                      width: 160,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[700]!,
                        child: Container(
                          height: 120,
                          width: 160,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        width: 160,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.tv,
                          color: Colors.white24,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    ch.name ?? "Channel",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((ch.videoCount ?? 0) > 0)
                    Text(
                      "${ch.videoCount} videos",
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

  // ─── SHARED IMAGE HELPER ──────────────────────────────────────────────────

  Widget _buildNetworkImage(String url, {double? width, double? height}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},
      width: width,
      height: height,
      placeholder: (context, url) => Container(
        color: Colors.grey[850],
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Color(0xFF00D285),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[800],
        child: const Icon(Icons.broken_image, color: Colors.white24, size: 20),
      ),
    );
  }
}
