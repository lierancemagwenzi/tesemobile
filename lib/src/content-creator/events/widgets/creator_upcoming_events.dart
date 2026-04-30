import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/events/widgets/empty_events.dart';
import 'package:smacredit/src/content-creator/events/widgets/live_event_widget.dart';

class ViewAllCreatorUpcomingEventsWidget extends StatefulWidget {
  const ViewAllCreatorUpcomingEventsWidget({super.key});

  @override
  _ViewAllCreatorUpcomingEventsWidgetState createState() =>
      _ViewAllCreatorUpcomingEventsWidgetState();
}

class _ViewAllCreatorUpcomingEventsWidgetState
    extends StateMVC<ViewAllCreatorUpcomingEventsWidget> {
  final Color brandGreen = const Color(0xFF00D285);
  final Color brandRed = const Color(0xFFFF4B2B);
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late CreatorController _con;
  Timer? _timer;

  _ViewAllCreatorUpcomingEventsWidgetState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForUpcomingEvents(page: 1, limit: 10);
    _searchController.addListener(() => setState(() {}));
    _scrollController.addListener(_scrollListener);

    // Global timer to refresh all countdowns every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.extentAfter < 200 && !_con.loading) {
      if ((_con.eventResponse?.pagination.currentPage ?? 0) <
          (_con.eventResponse?.pagination.totalPages ?? 0)) {
        _con.listenForUpcomingEvents(
          page: ((_con.eventResponse?.pagination.currentPage ?? 0) + 1),
          limit: 10,
        );
      }
    }
  }

  // Logic to calculate remaining time
  String _getTimeRemaining(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return "Starting...";

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return "${days}d ${hours}h left";
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // Logic to calculate event duration
  String _getDuration(DateTime start, DateTime end) {
    final diff = end.difference(start);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return hours > 0 ? "${hours}h ${minutes}m" : "${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color surfaceColor = isDark ? const Color(0xFF0A0A0A) : Colors.white;

    final events = _searchController.text.isEmpty
        ? _con.events
        : _con.events.where((e) {
            final query = _searchController.text.toLowerCase();
            return e.title.toLowerCase().contains(query);
          }).toList();

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Black in dark mode
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Upcoming Events",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          events.isEmpty && !_con.loading
              ? TeseEmptyEventsState(
                  title: "No Results",
                  message: "We couldn't find any events matching your search.",
                  icon: LucideIcons.searchX,
                )
              : Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) => _buildEnhancedEventCard(
                      events[index],
                      isDark,
                      surfaceColor,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search your schedule...",
          prefixIcon: const Icon(LucideIcons.search, size: 18),
          filled: true,
          fillColor: isDark ? const Color(0xFF161B22) : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedEventCard(
    EventModel event,
    bool isDark,
    Color surfaceColor,
  ) {
    final bool isLive = event.isLive;
    final String duration = _getDuration(event.startDate, event.endDate);

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
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isLive
                ? brandRed.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Column(
          children: [
            // TOP SECTION: Thumbnail & Overlays
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Image.network(
                    event.thumbnail ?? '',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        Container(color: Colors.grey[900], height: 140),
                  ),
                ),
                // LIVE PULSE BADGE
                if (isLive)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _LivePulseBadge(color: brandRed),
                  )
                else
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _badge(
                      Colors.black54,
                      _getTimeRemaining(event.startDate),
                    ),
                  ),
                // PRICE TAG
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

            // BOTTOM SECTION: Details
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

                  // STAT GRID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniInfo(LucideIcons.clock, duration, "Duration"),
                      _miniInfo(
                        LucideIcons.users,
                        "${event.purchaseCount}",
                        "Registrations",
                      ),
                      _miniInfo(
                        LucideIcons.calendar,
                        DateFormat('MMM dd').format(event.startDate),
                        "Date",
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.white10),
                  ),

                  // START/END TIMES
                  Row(
                    children: [
                      Expanded(child: _timeBlock("START", event.startDate)),
                      Container(width: 1, height: 30, color: Colors.white10),
                      Expanded(child: _timeBlock("END", event.endDate)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // START BUTTON (Only if canStart)
                  if (event.canStart && !isLive)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "GO LIVE NOW",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _miniInfo(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _timeBlock(String label, DateTime time) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        Text(
          DateFormat('HH:mm').format(time),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ],
    );
  }

  Widget _badge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

// THE LIVE PULSE WIDGET
class _LivePulseBadge extends StatefulWidget {
  final Color color;
  const _LivePulseBadge({required this.color});

  @override
  State<_LivePulseBadge> createState() => _LivePulseBadgeState();
}

class _LivePulseBadgeState extends State<_LivePulseBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.5).animate(_controller),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            "LIVE",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
