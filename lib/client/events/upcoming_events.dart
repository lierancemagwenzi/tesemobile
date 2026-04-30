import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/events/client_live_event_details.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/events/widgets/empty_events.dart';

enum EventGroupType { live, past, upcoming }

class ClientEventListGroup extends StatefulWidget {
  final EventGroupType type;
  final String title;

  const ClientEventListGroup({
    super.key,
    required this.type,
    this.title = "Events",
  });

  @override
  _ClientEventListGroupState createState() => _ClientEventListGroupState();
}

class _ClientEventListGroupState extends StateMVC<ClientEventListGroup> {
  late ClientUserController _con;
  final Color brandGreen = const Color(0xFF00D285);
  final Color brandRed = const Color(0xFFFF4B2B);

  _ClientEventListGroupState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    // Assuming this method exists in your controller to handle the enum
    _con.listenForClientEvents(widget.type);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // True Black background for the Scaffold
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            LucideIcons.chevronLeft,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
      body: _con.loading && _con.events.isEmpty
          ? Center(child: CircularProgressIndicator(color: brandGreen))
          : _con.events.isEmpty
          ? const TeseEmptyEventsState(
              title: "No Events Found",
              message: "Check back later for more broadcasts.",
              icon: LucideIcons.calendarX2,
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _con.events.length,
                    itemBuilder: (context, index) {
                      final event = _con.events[index];
                      return _buildClientTile(event, isDark);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildClientTile(EventModel event, bool isDark) {
    Color statusColor = brandGreen;
    String statusText = "UPCOMING";

    // Using the logic you specified
    if (event.isLive) {
      statusColor = brandRed;
      statusText = "LIVE NOW";
    } else if (event.isPast) {
      statusColor = Colors.grey;
      statusText = "FINISHED";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // Slightly lighter than pure black for depth
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            event.thumbnail ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              color: Colors.grey[900],
              width: 60,
              height: 60,
              child: const Icon(
                LucideIcons.imageOff,
                size: 20,
                color: Colors.white24,
              ),
            ),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd • HH:mm').format(event.startDate),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${event.currency} ${event.price.toStringAsFixed(0)}",
              style: TextStyle(
                color: brandGreen,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            if (event.hasPurchased)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  LucideIcons.checkCircle,
                  size: 14,
                  color: brandGreen,
                ),
              ),
          ],
        ),
        onTap: () {
          goToEvent(event);
        },
      ),
    );
  }

  goToEvent(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ClientEventDetailsScreen(event: event),
      ),
    );
  }
}
