import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/events/widgets/live_event_widget.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class CreatorLiveEventsWidget extends StatefulWidget {
  final VoidCallback onPop;
  const CreatorLiveEventsWidget({super.key, required this.onPop});

  @override
  _CreatorLiveEventsWidgetState createState() =>
      _CreatorLiveEventsWidgetState();
}

class _CreatorLiveEventsWidgetState extends StateMVC<CreatorLiveEventsWidget> {
  late CreatorController _con;

  _CreatorLiveEventsWidgetState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  final Color brandGreen = const Color(0xFF00D285);
  final Color brandRed = const Color(0xFFFF4B2B);

  // Controller for the search input
  final TextEditingController _searchController = TextEditingController();

  // 1. DUMMY LIST OF 10 ITEMS

  // 2. FILTERED LIST
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _con.listenForEvents(page: 1, limit: 3,restart: true);
    _scrollController.addListener(_scrollListener);
    print("initstate");
    _searchController.addListener(_onSearchChanged);
  }

  List<EventModel> get _allSessions {
    if (_searchController.text.isEmpty) {
      return _con.events;
    }

    List<EventModel> _filteredSessions = _con.events
        .where(
          (s) =>
              s.title.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ) ||
              (s.organizer?.name ?? "").toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
        )
        .toList();

    return _filteredSessions;
  }

  void _scrollListener() {
    // Trigger when user is 200 pixels from the bottom
    if (_scrollController.position.extentAfter < 200) {
      if (!_con.loading) {
        if ((_con.eventResponse?.pagination.currentPage ?? 0) <
            (_con.eventResponse?.pagination.totalPages ?? 0)) {
          _con.listenForEvents(
            page: ((_con.eventResponse?.pagination.currentPage ?? 0) + 1),
            limit: 3,
            restart: false
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Always dispose to avoid memory leaks
    super.dispose();
    _searchController.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
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
                  hintText: "Search events...",
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
              child: _allSessions.isEmpty
                  ? const Center(
                      child: Text("No events found matching your search"),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _allSessions.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) =>
                          _buildLiveCard(_allSessions[index], isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCard(EventModel session, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatorEventCommandCenter(event: session),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildPlaceholder(isDark),
                Positioned(
                  top: 10,
                  left: 10,
                  child: _badge(brandRed, "● LIVE"),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _badge(Colors.black54, "👁 ${session.purchaseCount}"),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: _badge(brandGreen, 'Live Event'),
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
                Text(
                  session.organizer?.name ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    session.price?.toStringAsFixed(2) ?? '0.00',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
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
