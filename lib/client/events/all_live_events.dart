import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/events/client_live_event_details.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/events/widgets/empty_events.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class ClientLiveEventsWidget extends StatefulWidget {
  const ClientLiveEventsWidget({super.key});

  @override
  _ClientLiveEventsWidgetState createState() => _ClientLiveEventsWidgetState();
}

class _ClientLiveEventsWidgetState extends StateMVC<ClientLiveEventsWidget> {
  late ClientUserController _con;
  Timer? _timer;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color brandGreen = const Color(0xFF00D285);
  final Color brandRed = const Color(0xFFFF4B2B);

  _ClientLiveEventsWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForEvents(page: 1, limit: 10);
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(() => setState(() {}));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  goToEvent(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ClientEventDetailsScreen(event: event),
      ),
    );
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
    if (duration.isNegative) return "In Progress";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${duration.inHours}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
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
      loading: _con.loading && events.isEmpty,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Black
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Explore Events",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Find a live session...",
                  prefixIcon: const Icon(LucideIcons.search, size: 20),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1A1A1A)
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
                  ? const TeseEmptyEventsState(
                      title: "Nothing here",
                      message: "Check back later for live sessions.",
                      icon: LucideIcons.calendarX,
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: events.length,
                      itemBuilder: (context, index) =>
                          _buildClientEventCard(events[index], isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientEventCard(EventModel event, bool isDark) {
    final bool isLive = event.isLive;
    final bool isPast = event.isPast;
    final bool hasPurchased = event.hasPurchased;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLive
              ? brandRed.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            goToEvent(event);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE SECTION
              Stack(
                children: [
                  Image.network(
                    event.thumbnail ?? '',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        Container(color: Colors.grey[900], height: 180),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _badge(
                      isLive
                          ? brandRed
                          : (isPast ? Colors.grey[800]! : brandGreen),
                      isLive ? "LIVE" : (isPast ? "ENDED" : "UPCOMING"),
                    ),
                  ),
                  if (!isPast && !isLive)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _badge(
                        Colors.black54,
                        _getCountdown(event.startDate),
                      ),
                    ),
                ],
              ),

              // CONTENT SECTION
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Text(
                          "${event.currency} ${event.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            color: brandGreen,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "by ${event.organizer?.fullname ?? 'Tese Creator'}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white10),
                    ),

                    Row(
                      children: [
                        _infoIcon(
                          LucideIcons.users,
                          "${event.purchaseCount} joined",
                        ),
                        const SizedBox(width: 16),
                        _infoIcon(
                          LucideIcons.clock,
                          DateFormat('HH:mm').format(event.startDate),
                        ),
                        const Spacer(),

                        // MAIN ACTION BUTTON
                        if (isLive && hasPurchased)
                          _actionButton(
                            "JOIN NOW",
                            brandRed,
                            LucideIcons.playCircle,
                          )
                        else if (!hasPurchased && !isPast)
                          _actionButton(
                            "GET TICKET",
                            brandGreen,
                            LucideIcons.ticket,
                          )
                        else if (hasPurchased && !isLive && !isPast)
                          _actionButton(
                            "REGISTERED",
                            Colors.white10,
                            LucideIcons.checkCircle,
                            textColor: Colors.white60,
                          )
                        else
                          const Text(
                            "Event Ended",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
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

  Widget _infoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _actionButton(
    String label,
    Color bg,
    IconData icon, {
    Color textColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
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
