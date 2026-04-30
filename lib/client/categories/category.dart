import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/models/dashboard_model.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class CategoryWidget extends StatefulWidget {
  final Category category;
  const CategoryWidget({super.key, required this.category});

  @override
  StateMVC<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends StateMVC<CategoryWidget> {
  final Color teseRed = const Color(0xFFFF3B30);
  final Color teseGreen = const Color(0xFF00D285);
  String _searchQuery = "";

  late ClientUserController _con;

  _CategoryWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForCategory(widget.category.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        key: _con.scaffoldKey,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },

            child: Icon(Icons.arrow_back_ios_new, color: textColor),
          ),
          title: Text(
            '${widget.category.name} Creators',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: _con.creators.isEmpty
            ? TeseEmptyWidget()
            : Column(
                children: [
                  // 1. ADAPTIVE SEARCH BOX
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: TextField(
                      style: TextStyle(color: textColor),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search ${widget.category.name} creators...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.white10 : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // 2. CREATORS LIST
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _con.creators.length,
                      itemBuilder: (context, index) => _buildCreatorCard(
                        cardColor: cardColor,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        isDark: isDark,
                        user: _con.creators[index],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCreatorCard({
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
    required User user,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BANNER & OVERLAPPING AVATAR
          SizedBox(
            height: 180,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildNetworkImage(
                  user.selfie ?? "",
                  height: 140,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  isDark: isDark,
                ),
                Positioned(
                  bottom: -15,
                  left: 20,
                  child: _buildOverlappingAvatar(
                    cardColor,
                    isDark,
                    user.selfie ?? "",
                  ),
                ),
              ],
            ),
          ),

          // CONTENT SECTION
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullname,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  user.email ?? "",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  user.description ?? 'Tese content creator',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // STATS ROW
                Row(
                  children: [
                    _StatLabel(
                      icon: Icons.people_outline,
                      text: UtilsHelper.formatNumber(user.followerCount ?? 0),
                      color: subTextColor,
                    ),
                    const SizedBox(width: 15),
                    _StatLabel(
                      icon: Icons.videocam_outlined,
                      text:
                          '${UtilsHelper.formatNumber(user.videoCount ?? 0)} videos',
                      color: subTextColor,
                    ),
                    const SizedBox(width: 15),
                    _StatLabel(
                      icon: Icons.play_circle_outline,
                      text:
                          '${UtilsHelper.formatNumber(user.channelCount ?? 0)} channels',
                      color: subTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // GRADIENT ACTION BUTTON
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [teseRed, teseGreen],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/CreatorProfile',
                        arguments: user,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'View profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlappingAvatar(Color cardColor, bool isDark, String s) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
          child: _buildNetworkImage(
            s,
            height: 90,
            width: 90,
            isCircle: true,
            isDark: isDark,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 4, bottom: 4),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 12,
            backgroundColor: teseGreen,
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImage(
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
}

class _StatLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _StatLabel({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
