import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

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

  _SearchWidgetState() : super(null);

  // Robust image helper to prevent UI breakage from bad URLs
  Widget _buildNetworkImage(
    String url, {
    double height = 80,
    double width = 80,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Popular Videos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildPopularList(isDark),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Show More",
                  style: TextStyle(
                    color: brandGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Trending Creators",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            _buildTrendingList(isDark),
            const SizedBox(height: 100), // Space for FAB
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
        child: const TextField(
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
      itemCount: popularVideos.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final video = popularVideos[index];
        return InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/Player');
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                _buildNetworkImage(video.image),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.creator,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        video.title,
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
                          _iconStat(Icons.favorite_border, video.likes),
                          _iconStat(Icons.visibility_outlined, video.views),
                          _iconStat(Icons.download_outlined, video.downloads),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
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
                          Text("Purchase "),
                          Icon(Icons.chevron_right, size: 14),
                        ],
                      ),
                    ),
                    const Text(
                      "20 sec Pre Listen",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
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
        itemCount: trendingCreators.length,
        itemBuilder: (context, index) {
          final creator = trendingCreators[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 15),
            child: Column(
              children: [
                Stack(
                  children: [
                    _buildNetworkImage(creator.image, width: 140, height: 100),
                    if (creator.isExclusive)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "EXCLUSIVE",
                            style: TextStyle(
                              color: Color(0xFF00D285),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  creator.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
