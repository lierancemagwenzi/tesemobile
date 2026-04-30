import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';

// --- DATA MODEL ---
class PastEvent {
  final String title;
  final String creator;
  final String rating;
  final String views;
  final String date;
  final String price;
  final String imageUrl;

  PastEvent({
    required this.title,
    required this.creator,
    required this.rating,
    required this.views,
    required this.date,
    required this.price,
    required this.imageUrl,
  });
}

class PastEventsWidget extends StatefulWidget {
  const PastEventsWidget({super.key});

  @override
  _PastEventsWidgetState createState() => _PastEventsWidgetState();
}

class _PastEventsWidgetState extends StateMVC<PastEventsWidget> {
  final Color brandGreen = const Color(0xFF00D285);
  final TextEditingController _searchController = TextEditingController();

  late ClientUserController _con;

  _PastEventsWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {

    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  List<EventModel> get _filteredEvents {
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
          "Past Event Recordings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // THEMED SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search recorded sessions...",
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

          // SCROLLABLE GRID
          Expanded(
            child: _filteredEvents.isEmpty
                ? const Center(child: Text("No recordings found"))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.78,
                        ),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) =>
                        _buildPastEventCard(_filteredEvents[index], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastEventCard(EventModel event, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IMAGE WITH OVERLAYS
        Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                event.thumbnail??"",
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: double.infinity,
                  color: isDark
                      ? const Color(0xFF1C1C1E)
                      : Colors.grey.shade200,
                  child: Icon(
                    Icons.play_circle_outline,
                    color: isDark ? Colors.white10 : Colors.grey.shade300,
                    size: 40,
                  ),
                ),
              ),
            ),
            // Play Icon Overlay
            const Icon(Icons.play_circle_fill, color: Colors.white70, size: 45),
            // Rating Badge (Top Right)
            Positioned(
              top: 8,
              right: 8,
              child: _badge(Colors.orange, "⭐ ${event.rating}"),
            ),
            // View Count (Bottom Left)
            Positioned(
              bottom: 8,
              left: 8,
              child: _badge(Colors.black54, "👁 ${event.views}"),
            ),
            // Date (Bottom Right)
            Positioned(
              bottom: 8,
              right: 8,
              child: _badge(Colors.black54, event.startDate.toIso8601String()),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // TEXT DETAILS
        Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                event.organizer?.fullname??"",
                style: const TextStyle(color: Colors.grey, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              event.price.toStringAsFixed(2),
              style: TextStyle(
                color: brandGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _badge(Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
