import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/events/widgets/empty_events.dart';
import 'package:smacredit/src/content-creator/events/widgets/live_event_widget.dart';

class CreatorPastEventsWidget extends StatefulWidget {
  const CreatorPastEventsWidget({super.key, required this.onPop});
  final VoidCallback onPop;

  @override
  _CreatorPastEventsWidgetState createState() =>
      _CreatorPastEventsWidgetState();
}

class _CreatorPastEventsWidgetState extends StateMVC<CreatorPastEventsWidget> {
  final Color brandGreen = const Color(0xFF00D285);
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CreatorController _con;

  _CreatorPastEventsWidgetState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForPastEvents(page: 1, limit: 10);
    _searchController.addListener(() => setState(() {}));
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 200 && !_con.loading) {
      if ((_con.eventResponse?.pagination.currentPage ?? 0) <
          (_con.eventResponse?.pagination.totalPages ?? 0)) {
        _con.listenForPastEvents(
          page: ((_con.eventResponse?.pagination.currentPage ?? 0) + 1),
          limit: 10,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    return "${diff.inHours}h ${diff.inMinutes % 60}m";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? const Color(0xFF111111) : Colors.white;

    final events = _searchController.text.isEmpty
        ? _con.events
        : _con.events
              .where(
                (e) => e.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // True Black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: widget.onPop,
        ),
        title: const Text(
          "Past Broadcasts",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          // THEMED SEARCH
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search history...",
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: events.isEmpty && !_con.loading
                ? TeseEmptyEventsState(
                    title: "No Results",
                    message: _con.events.isEmpty
                        ? "You haven't scheduled any broadcasts yet. Start one now to engage your audience!"
                        : "We couldn't find any events matching your search.",
                    icon: LucideIcons.searchX,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) =>
                        _buildPastEventCard(events[index], isDark, cardColor),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastEventCard(EventModel event, bool isDark, Color cardColor) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreatorEventCommandCenter(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            // HEADER IMAGE WITH "ARCHIVED" LOOK
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.2),
                      BlendMode.darken,
                    ),
                    child: Image.network(
                      event.thumbnail ?? '',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: Colors.grey[900], height: 120),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _badge(Colors.black87, "RECORDED"),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _badge(
                    brandGreen,
                    "${event.currency} ${event.price.toStringAsFixed(0)}",
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // PERFORMANCE STATS GRID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statTile(
                        LucideIcons.playCircle,
                        "${event.views}",
                        "Total Views",
                      ),
                      _statTile(
                        LucideIcons.messageSquare,
                        "42",
                        "Comments",
                      ), // Dummy for now
                      _statTile(
                        LucideIcons.clock,
                        _getDuration(event.startDate, event.endDate),
                        "Runtime",
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white10),
                  ),

                  // METADATA ROW
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.calendar,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd, yyyy').format(event.startDate),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      // RECAP BUTTON
                      TextButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          LucideIcons.barChart3,
                          size: 16,
                          color: brandGreen,
                        ),
                        label: Text(
                          "ANALYTICS",
                          style: TextStyle(
                            color: brandGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          backgroundColor: brandGreen.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 5),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _badge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
