import 'package:flutter/material.dart';

class ViewLiveEventsWidget extends StatefulWidget {
  const ViewLiveEventsWidget({super.key});

  @override
  _ViewLiveEventsWidgetState createState() =>
      _ViewLiveEventsWidgetState();
}

class _ViewLiveEventsWidgetState extends State<ViewLiveEventsWidget> {
  final Color brandGreen = const Color(0xFF00D285);
  final Color brandRed = const Color(0xFFFF4B2B);

  // Controller for the search input
  final TextEditingController _searchController = TextEditingController();

  // 1. DUMMY LIST OF 10 ITEMS
  final List<LiveSession> _allSessions = List.generate(
    10,
    (index) => LiveSession(
      title: index % 2 == 0
          ? "React Advanced Patterns"
          : "Photography Masterclass",
      creator: index % 2 == 0 ? "TechMasterPro" : "Sarah Mitchell",
      category: index % 2 == 0 ? "Development" : "Photography",
      viewerCount: "${(100 + (index * 150))}",
      timeAgo: "${index + 5} mins ago",
      price: "Join \$${9.99 + index}",
      imageUrl: "https://invalid-url.com/live_$index",
    ),
  );

  // 2. FILTERED LIST
  List<LiveSession> _filteredSessions = [];

  @override
  void initState() {
    super.initState();
    _filteredSessions = _allSessions;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredSessions = _allSessions
          .where(
            (s) =>
                s.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                s.creator.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Live Events",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // THEMED SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search creators or sessions...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF161B22)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // SCROLLABLE LIST
          Expanded(
            child: _filteredSessions.isEmpty
                ? const Center(
                    child: Text("No events found matching your search"),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredSessions.length,
                    itemBuilder: (context, index) =>
                        _buildLiveCard(_filteredSessions[index], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard(LiveSession session, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              _buildPlaceholder(isDark),
              Positioned(top: 10, left: 10, child: _badge(brandRed, "● LIVE")),
              Positioned(
                top: 10,
                right: 10,
                child: _badge(Colors.black54, "👁 ${session.viewerCount}"),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: _badge(brandGreen, session.category),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(session.creator, style: const TextStyle(color: Colors.grey)),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  session.price,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.videocam_outlined,
        color: isDark ? Colors.white10 : Colors.grey.shade400,
        size: 40,
      ),
    );
  }

  Widget _badge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Data Model used in search
class LiveSession {
  final String title, creator, category, viewerCount, timeAgo, price, imageUrl;
  LiveSession({
    required this.title,
    required this.creator,
    required this.category,
    required this.viewerCount,
    required this.timeAgo,
    required this.price,
    required this.imageUrl,
  });
}
