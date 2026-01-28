import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    // TODO: implement initState
    super.initState();

    _con.listenForDashboard();
    _con.listenForDashboardVideos();
    _con.listenForDashboardCategories();
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
                  onTap: () {
                    _con.scaffoldKey.currentState?.openDrawer();
                  },

                  child: Icon(Icons.menu),
                )
              : null,
          centerTitle: true,
          title: Image.asset(
            isDark ? "assets/images/logo-light.png" : "assets/images/logo.png",
            fit: BoxFit.contain,
            height: 50,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () {
                UtilsHelper.ensureAuth(
                  context,
                  action: "to view account notifications",
                  onAuthenticated: () {
                    Navigator.pushNamed(context, '/Notifications');
                  },
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedHero(),
              _buildSectionHeader(
                context,
                "Browse by Category",
                true,
                '/CategoryExplorer',
              ),
              _buildCategoryList(isDark),
              _buildSectionHeader(
                context,
                "Creators",
                true,
                '/CreatorExplorer',
              ),
              _buildCreatorList(isDark),

              if (_con.videos.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  "Featured videos",
                  false,
                  '/CreatorExplorer',
                ),

                _builVideoList(isDark, _con.videos),
              ],

              if (_con.the_categories.isNotEmpty) ...[],

              ..._con.the_categories.map(
                (e) => Column(
                  children: [
                    _buildSectionHeader(
                      context,
                      "${e.name}",
                      false,
                      '/CreatorExplorer',
                    ),

                    _builVideoList(isDark, e.videos ?? []),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Padding for the FAB notch
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedHero() {
    return 1 == 1
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                CachedNetworkImage(
                  height: 220,
                  imageUrl:
                      "${_con.dashboardModel?.video?.video?.thumbnailUrl}",
                  // 1. THE CONTAINER (DecorationImage logic lives here)
                  imageBuilder: (context, imageProvider) => Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 2. THE SHIMMER (Shown while loading)
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  // 3. THE ERROR (Grey background as requested)
                  errorWidget: (context, url, error) => Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),

                Container(
                  height: 220,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: brandGreen,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars, color: Colors.orange, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "FEATURED",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // const Text(
                      //   "✨ EXCLUSIVE MASTERCLASS",
                      //   style: TextStyle(
                      //     color: Colors.orange,
                      //     fontSize: 11,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      Text(
                        "${_con.dashboardModel?.video?.video?.title ?? "Tese Video"}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow),
                            Text(" Watch Now"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container(
            margin: const EdgeInsets.all(20),
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              image: DecorationImage(
                image: NetworkImage(
                  _con.dashboardModel?.video?.video?.thumbnailUrl ?? "",
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: _con.dashboardModel?.video == null
                ? SizedBox(height: 0, width: 0)
                : Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: brandGreen,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars, color: Colors.orange, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "FEATURED",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "✨ EXCLUSIVE MASTERCLASS",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${_con.dashboardModel?.video?.video?.title ?? "Tese Video"}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow),
                              Text(" Watch Now"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
  }

  // 2. SECTION HEADERS
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool showViewAll,
    String routeName,
  ) {
    return InkWell(
      onTap: () {
        if (showViewAll) {
          Navigator.pushNamed(context, routeName);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            if (showViewAll)
              Text(
                "View All",
                style: TextStyle(
                  color: brandGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 3. CATEGORY LIST
  Widget _buildCategoryList(bool isDark) {
    return SizedBox(
      height: 185,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: _con.dashboardModel?.categories?.length ?? 0,
        itemBuilder: (context, index) {
          final cat = _con.dashboardModel!.categories![index];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/Cat', arguments: cat);
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: 1 == 1
                            ? CachedNetworkImage(
                                imageUrl: cat.image ?? "",
                                fit: BoxFit.cover,
                                height: 150,
                                width: 150,
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
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white24,
                                  ),
                                ),
                              )
                            : Image.network(
                                cat.image ?? "",
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,

                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null)
                                        return child; // Image finished loading

                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        period: const Duration(
                                          milliseconds: 1500,
                                        ),
                                        child: Container(
                                          width: 150,
                                          height: 150,
                                          color: Colors.white,
                                        ),
                                      );
                                    },

                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 160,
                                      height: 140,
                                      color: isDark
                                          ? const Color(0xFF1C1C1E)
                                          : Colors.grey.shade200,
                                      child: Icon(
                                        Icons.broken_image,
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.grey.shade400,
                                        size: 40,
                                      ),
                                    ),
                              ),
                      ),
                      // Positioned(
                      //   top: 10,
                      //   left: 10,
                      //   child: CircleAvatar(
                      //     radius: 18,
                      //     backgroundColor: Colors.black.withOpacity(0.3),
                      //     child: Text(
                      //       cat.icon,
                      //       style: const TextStyle(fontSize: 16),
                      //     ),
                      //   ),
                      // ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${cat.videoCount}+ videos",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.name ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. CREATOR LIST
  Widget _buildCreatorList(bool isDark) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: _con.dashboardModel?.creators?.length ?? 0,
        itemBuilder: (context, index) {
          final creator = _con.dashboardModel!.creators![index].user;
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/CreatorProfile',
                arguments: creator!,
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: 1 == 1
                            ? CachedNetworkImage(
                                imageUrl: creator?.selfie ?? "",
                                fit: BoxFit.cover,
                                height: 140,
                                width: 160,
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
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white24,
                                  ),
                                ),
                              )
                            : Image.network(
                                creator?.selfie ?? "",
                                height: 140,
                                width: 160,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null)
                                        return child; // Image finished loading

                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        period: const Duration(
                                          milliseconds: 1500,
                                        ),
                                        child: Container(
                                          width: 160,
                                          height: 140,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 160,
                                      height: 140,
                                      color: isDark
                                          ? const Color(0xFF1C1C1E)
                                          : Colors.grey.shade200,
                                      child: Icon(
                                        Icons.person,
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.grey.shade400,
                                        size: 40,
                                      ),
                                    ),
                              ),
                      ),
                      if (1 == 2)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: brandGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.workspace_premium,
                                  color: Colors.orange,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "EXCLUSIVE",
                                  style: TextStyle(
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
                  const SizedBox(height: 8),
                  Text(
                    creator?.fullname ?? "Content creator",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Creator",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _builVideoList(bool isDark, List videos) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          Video creator = videos[index];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/Player',
                arguments: {'video': creator},
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: 1 == 1
                            ? CachedNetworkImage(
                                imageUrl: creator.thumbnailUrl ?? "",
                                fit: BoxFit.cover,
                                height: 140,
                                width: 160,
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
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white24,
                                  ),
                                ),
                              )
                            : Image.network(
                                creator.thumbnailUrl ?? "",
                                height: 140,
                                width: 160,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null)
                                        return child; // Image finished loading

                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        period: const Duration(
                                          milliseconds: 1500,
                                        ),
                                        child: Container(
                                          width: 160,
                                          height: 140,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 160,
                                      height: 140,
                                      color: isDark
                                          ? const Color(0xFF1C1C1E)
                                          : Colors.grey.shade200,
                                      child: Icon(
                                        Icons.play_arrow_outlined,
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.grey.shade400,
                                        size: 40,
                                      ),
                                    ),
                              ),
                      ),
                      if (creator.accessType == 'paid')
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: brandGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.workspace_premium,
                                  color: Colors.orange,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${creator.currency ?? "USD"} ${(creator.price ?? 0.00).toStringAsFixed(2)}",
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
                  const SizedBox(height: 8),
                  Text(
                    creator?.title ?? "Tese content",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    UtilsHelper.formatLongDuration(
                      creator.durationSeconds ?? 0,
                    ),
                    style: TextStyle(color: Colors.grey, fontSize: 11),
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
