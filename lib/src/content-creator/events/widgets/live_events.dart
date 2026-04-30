import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/events/widgets/create_event.dart';
import 'package:smacredit/src/content-creator/events/widgets/empty_events.dart';
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
  Timer? _timer;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color brandGreen = const Color(0xFF00D285);
  final Color brandRed = const Color(0xFFFF4B2B);

  _CreatorLiveEventsWidgetState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForEvents(page: 1, limit: 10);
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(() => setState(() {}));

    // Refresh the UI every second to update countdown timers
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
        _con.listenForEvents(
          page: (_con.eventResponse!.pagination.currentPage + 1),
          limit: 10,
        );
      }
    }
  }

  String _getCountdown(DateTime startDate) {
    final duration = startDate.difference(DateTime.now());
    if (duration.isNegative) return "Starting soon";

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return "${duration.inDays > 0 ? '${duration.inDays}d ' : ''}$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final events = _searchController.text.isEmpty
        ? _con.events
        : _con.events
              .where(
                (e) => e.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
              )
              .toList();

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: const Text(
            "Your Events",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => CreateEventScreen(
                      onPop: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ).then((e) {
                  _con.listenForEvents(page: 1, limit: 10, restart: true);
                });
              },
              icon: const Icon(
                LucideIcons.plusCircle,
                color: Color(0xFF00D285),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search your broadcasts...",
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100],
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
                      message:
                          "We couldn't find any events matching your search.",
                      icon: LucideIcons.searchX,
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: events.length,
                      itemBuilder: (context, index) =>
                          _buildEventCard(events[index], isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event, bool isDark) {
    final isPast = event.endDate.isBefore(DateTime.now());
    final bool canStart = event.canStart; // From your model logic

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
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // IMAGE SECTION
              Stack(
                children: [
                  Image.network(
                    event.thumbnail ?? '',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[900],
                      height: 160,
                      child: const Icon(LucideIcons.imageOff),
                    ),
                  ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _badge(
                      isPast
                          ? Colors.grey[800]!
                          : (event.isLive ? brandRed : brandGreen),
                      isPast ? "PAST" : (event.isLive ? "LIVE" : "UPCOMING"),
                    ),
                  ),
                  // Price Badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: _badge(
                      Colors.black87,
                      "${event.currency} ${event.price.toStringAsFixed(2)}",
                    ),
                  ),
                ],
              ),
              // INFO SECTION
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMM dd, HH:mm').format(event.startDate),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        if (!isPast && !event.isLive)
                          Text(
                            _getCountdown(event.startDate),
                            style: TextStyle(
                              color: brandGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _miniStat(
                            LucideIcons.users,
                            "${event.purchaseCount}",
                            "Sales",
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ACTION BUTTON
                        if (canStart && !isPast)
                          ElevatedButton.icon(
                            onPressed: () {
                              /* Navigator to Command Center */
                            },
                            icon: const Icon(
                              LucideIcons.playCircle,
                              size: 18,
                              color: Colors.black,
                            ),
                            label: const Text(
                              "START",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        else if (isPast)
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.barChart2, size: 18),
                            label: const Text("RECAP"),
                          )
                        else
                          const Text(
                            "Locked",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
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
      ),
    );
  }

  Widget _miniStat(IconData icon, String val, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          val,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
