import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/src/utils/xhelper.dart';

// --- DUMMY MODELS ---
class LibraryVideo {
  final String title;
  final String creator;
  final String duration;
  final String progress;
  final String date;
  final String image;
  final String? size;
  LibraryVideo({
    required this.title,
    required this.creator,
    required this.duration,
    this.progress = "",
    this.date = "",
    required this.image,
    this.size,
  });
}

class MyLibraryWidget extends StatefulWidget {
  const MyLibraryWidget({super.key});

  @override
  _MyLibraryWidgetState createState() => _MyLibraryWidgetState();
}

class _MyLibraryWidgetState extends StateMVC<MyLibraryWidget> {
  final Color brandGreen = const Color(0xFF00D285);
  String activeFilter = "All Videos";

  late ClientUserController _con;

  _MyLibraryWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForPurchasedVideos();
  }

  // Robust Network Image Helper with Error Placeholders
  Widget _buildNetworkImage(
    String url, {
    double height = 90,
    double width = 140,
    bool showPlay = true,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: width,
              height: height,
              color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200,
              child: Icon(
                Icons.videocam_outlined,
                color: isDark ? Colors.white10 : Colors.grey.shade300,
                size: 30,
              ),
            ),
          ),
          if (showPlay)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: brandGreen.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,

        title: Text("Tese Africa"),

        // title: Image.asset(
        //   isDark ? "assets/images/logo-light.pn1g" : "assets/images/logo.pn1g",
        //   fit: BoxFit.contain,
        //   height: 50,
        //   errorBuilder: (c, e, s) => const Text("Tese Africa"),
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Library",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Text(
              "Your purchased and downloaded videos",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // _buildFilterRow(isDark),
            // const SizedBox(height: 25),

            // SECTION: CONTINUE WATCHING
            // _sectionHeader(Icons.access_time, "Continue Watching"),
            // _buildContinueWatchingItem(
            //   "Complete Web Development 2024",
            //   "TechMasterPro",
            //   "12h 45m",
            //   "65%",
            //   "2 days ago",
            // ),
            // _buildContinueWatchingItem(
            //   "Advanced Photography Guide",
            //   "Sarah Mitchell",
            //   "8h 30m",
            //   "30%",
            //   "5 week ago",
            // ),
            const SizedBox(height: 25),

            // // SECTION: ALL PURCHASED VIDEOS (FEATURED)
            // const Text(
            //   "All Purchased Videos",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 15),
            // _buildContinueWatchingItem(
            //   "Complete Web Development 2024",
            //   "TechMasterPro",
            //   "8h 30m",
            //   "30%",
            //   "5 week ago",
            // ),
            const SizedBox(height: 15),

            // SECTION: ALL PURCHASED VIDEOS (GRID)
            const Text(
              "All Purchased Videos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildPurchasedGrid(isDark),

            const SizedBox(height: 25),

            // SECTION: DOWNLOADED VIDEOS
            // _sectionHeader(Icons.file_download_outlined, "Downloadeed Videos"),

            // _buildDownloadedItem(
            //   "Complete Web Dasterclass",
            //   "TechMasterPro",
            //   "870 GB",
            //   "Dec 20, 2024",
            //   true,
            // ),
            // _buildDownloadedItem(
            //   "Photography Masterclass",
            //   "Sarah Mitchell",
            //   "1.2 GB",
            //   "Dec 15, 2024",
            //   false,
            // ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return Row(
      children: [
        _filterChip("All Videos", true),
        _filterChip("In Progress", false),
        _filterChip("Completed", false),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.tune, size: 20, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? brandGreen
            : (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white10
                  : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: brandGreen, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingItem(
    String title,
    String creator,
    String time,
    String prog,
    String date,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          _buildNetworkImage("https://invalid-url.com"),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  creator,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  "$time  •  $prog complete",
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedGrid(bool isDark) {
    return _con.videos.isEmpty
        ? Padding(padding: const EdgeInsets.all(8.0), child: TeseEmptyWidget())
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.9,
            ),
            itemCount: _con.videos.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/Player',
                    arguments: {'video': _con.videos[index]},
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNetworkImage(
                      _con.videos[index].thumbnailUrl ?? "",
                      width: double.infinity,
                      height: 130,
                      showPlay: true,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      _con.videos[index].title ?? "",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      UtilsHelper.formatLongDuration(
                        _con.videos[index].durationSeconds ?? 0,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildDownloadedItem(
    String title,
    String creator,
    String size,
    String date,
    bool isStarred,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Stack(
            children: [
              _buildNetworkImage(
                "https://invalid-url.com/dl",
                width: 120,
                height: 80,
                showPlay: false,
              ),
              const Positioned(
                child: Icon(Icons.videocam, color: Colors.white, size: 30),
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
              ),
              if (isStarred)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.stars, color: brandGreen, size: 18),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  creator,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "11 days old",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          size,
                          style: TextStyle(
                            color: brandGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          date,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
