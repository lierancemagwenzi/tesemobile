import 'package:flutter/material.dart';

// --- DATA MODEL ---
class UpcomingEvent {
  final String title;
  final String creator;
  final String date;
  final String registered;
  final String price;
  final String imageUrl;
  bool isNotified;

  UpcomingEvent({
    required this.title,
    required this.creator,
    required this.date,
    required this.registered,
    required this.price,
    required this.imageUrl,
    this.isNotified = false,
  });
}

class ViewAllUpcomingEventsWidget extends StatefulWidget {
  const ViewAllUpcomingEventsWidget({super.key});

  @override
  _ViewAllUpcomingEventsWidgetState createState() =>
      _ViewAllUpcomingEventsWidgetState();
}

class _ViewAllUpcomingEventsWidgetState
    extends State<ViewAllUpcomingEventsWidget> {
  final Color brandGreen = const Color(0xFF00D285);
  final TextEditingController _searchController = TextEditingController();

  // 1. DUMMY LIST OF 10 ITEMS
  final List<UpcomingEvent> _allEvents = List.generate(10, (index) {
    final titles = [
      "Marketing Strategy",
      "UI/UX Design",
      "Content Creation",
      "Product Management",
    ];
    final creators = [
      "James Cooper",
      "Emma Davis",
      "Alex Johnson",
      "Sarah Mitchell",
    ];

    return UpcomingEvent(
      title: "${titles[index % 4]} 2026",
      creator: creators[index % 4],
      date: index == 0 ? "Today at 6:00 PM" : "Jan ${index + 10} at 2:00 PM",
      registered: "${200 + (index * 45)} registered",
      price: "\$${12.99 + index}",
      imageUrl: "https://invalid-link.com/event_$index",
    );
  });

  List<UpcomingEvent> _filteredEvents = [];

  @override
  void initState() {
    super.initState();
    _filteredEvents = _allEvents;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredEvents = _allEvents
          .where(
            (e) =>
                e.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                e.creator.toLowerCase().contains(
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
          "Upcoming Events",
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
                hintText: "Search upcoming sessions...",
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
            child: _filteredEvents.isEmpty
                ? const Center(child: Text("No upcoming events found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) =>
                        _buildEventItem(_filteredEvents[index], isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(UpcomingEvent event, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // IMAGE WITH ERROR BUILDER
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              event.imageUrl,
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 85,
                height: 85,
                color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200,
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: isDark ? Colors.white10 : Colors.grey.shade400,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),

          // EVENT DETAILS
          Expanded(
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
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      event.price,
                      style: TextStyle(
                        color: brandGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  event.creator,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(event.date, style: const TextStyle(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.registered,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // NOTIFICATION BUTTON
          GestureDetector(
            onTap: () => setState(() => event.isNotified = !event.isNotified),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: event.isNotified
                    ? brandGreen
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                event.isNotified
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: event.isNotified ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
