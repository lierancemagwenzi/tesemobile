import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/events/client_live_event_details.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/events/widgets/broadcast_widget.dart';
import 'package:smacredit/src/content-creator/events/widgets/live_event_widget.dart';
import 'package:smacredit/src/models/UserModel.dart';

class CreatorEventsScreen extends StatefulWidget {
  final User artist;

  const CreatorEventsScreen({super.key, required this.artist});

  @override
  StateMVC<CreatorEventsScreen> createState() => _CreatorEventsScreenState();
}

class _CreatorEventsScreenState extends StateMVC<CreatorEventsScreen> {
  late CreatorController _con;

  _CreatorEventsScreenState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  @override
  void initState() {
    super.initState();
    // Fetch events for this specific creator on load
    _con.listenForCreatorEvents(
      user_id: widget.artist.id ?? 0,
      page: 1,
      limit: 10000,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color teseGreen = Color(0xFF00D285);
    final Color bgColor = isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () {
          return _con.listenForCreatorEvents(
            user_id: widget.artist.id ?? 0,
            page: 1,
            limit: 100,
          );
        },
        color: teseGreen,
        child: CustomScrollView(
          slivers: [
            // 1. DYNAMIC SPOTIFY-STYLE HEADER
            SliverAppBar(
              expandedHeight: 300.0,
              pinned: true,
              stretch: true,
              backgroundColor: bgColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.artist.fullname ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.artist.selfie ?? "",
                      fit: BoxFit.cover,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xFF121212)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. ACTION BUTTONS
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Text(
                      "Creator Events",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: teseGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.radio,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. DATA LIST / LOADING / EMPTY STATE
            if (_con.events.isEmpty && _con.loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: teseGreen),
                ),
              )
            else if (_con.events.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text("No events found for this creator")),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final event = _con.events[index];
                    return _buildEventTile(event, isDark, teseGreen);
                  }, childCount: _con.events.length),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(EventModel event, bool isDark, Color teseGreen) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          event.thumbnail ?? '',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) =>
              Container(color: Colors.grey[900], width: 60, height: 60),
        ),
      ),
      title: Text(
        event.title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            "${DateFormat('MMM dd, yyyy').format(event.startDate)} • ${event.currency} ${event.price}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (event.isLive)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "LIVE NOW",
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey),
      onTap: () {
        goToEvent(event);
      },
    );
  }

  goToEvent(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ClientEventDetailsScreen(event: event),
      ),
    ).then((v) {
      _con.listenForCreatorEvents(
        user_id: widget.artist.id ?? 0,
        page: 1,
        limit: 100,
      );
    });
  }
}
