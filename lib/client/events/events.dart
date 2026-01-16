import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/theme/app_theme.dart';

// --- DUMMY MODELS ---
class LiveSession {
  final String title;
  final String creator;
  final String category;
  final String viewerCount;
  final String timeAgo;
  final String price;
  final String imageUrl;
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

class UpcomingEvent {
  final String title;
  final String creator;
  final String date;
  final String registered;
  final String price;
  final String imageUrl;
  UpcomingEvent({
    required this.title,
    required this.creator,
    required this.date,
    required this.registered,
    required this.price,
    required this.imageUrl,
  });
}

// --- LIVE EVENTS WIDGET ---
class LiveEventsWidget extends StatefulWidget {
  const LiveEventsWidget({super.key});

  @override
  _LiveEventsWidgetState createState() => _LiveEventsWidgetState();
}

class _LiveEventsWidgetState extends StateMVC<LiveEventsWidget> {
  // MOCK DATA
  final List<LiveSession> liveNow = [
    LiveSession(
      title: "React Advanced Patterns",
      creator: "TechMasterPro",
      category: "Development",
      viewerCount: "1,247",
      timeAgo: "25 mins ago",
      price: "Join \$9.99",
      imageUrl: "https://fail.com/1",
    ),
    LiveSession(
      title: "Professional Photography",
      creator: "Sarah Mitchell",
      category: "Photography",
      viewerCount: "856",
      timeAgo: "10 mins ago",
      price: "Join \$14.99",
      imageUrl: "https://fail.com/2",
    ),
  ];

  final List<UpcomingEvent> upcoming = [
    UpcomingEvent(
      title: "Marketing Strategy 2024",
      creator: "James Cooper",
      date: "Today at 6:00 PM",
      registered: "523 registered",
      price: "\$19.99",
      imageUrl: "https://fail.com/3",
    ),
    UpcomingEvent(
      title: "UI/UX Design Workshop",
      creator: "Emma Davis",
      date: "Tomorrow at 3:00 PM",
      registered: "892 registered",
      price: "\$12.99",
      imageUrl: "https://fail.com/4",
    ),
  ];

  _LiveEventsWidgetState() : super(null);

  // Image Helper with themed error placeholders
  Widget _buildNetworkImage(
    String url, {
    double height = 200,
    double width = double.infinity,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade200,
          child: Icon(
            Icons.videocam_outlined,
            color: isDark ? Colors.white10 : Colors.grey.shade400,
            size: 40,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Image.network(
          "https://via.placeholder.com/100x40?text=Tese",
          height: 25,
          errorBuilder: (c, e, s) => const Text("Tese Africa"),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSectionHeader("Live Now", true, '/LiveEvents'),
            _buildLiveList(isDark),
            _buildSectionHeader("Upcoming Events", true, '/UpcomingEvents'),
            _buildUpcomingList(isDark),
            _buildSectionHeader("Past Events - Watch Recording", false, null),

            _buildSectionSubHeader(
              "Past Events - Watch Recording",
              true,
              '/PastEvents',
            ),
            _buildPastEventsGrid(isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: brandRed,
            radius: 25,
            child: const Icon(Icons.sensors, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Live Events",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Join live sessions with creators",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSubHeader(
    String title,
    bool showViewAll,
    String? routeName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),

          if (showViewAll && routeName != null)
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, routeName);
              },
              child: Text(
                "View All",
                style: TextStyle(color: brandRed, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool showViewAll,
    String? routeName,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (title.contains("Live"))
                Icon(Icons.circle, color: brandRed, size: 10),
              if (title.contains("Upcoming"))
                const Icon(Icons.calendar_today_outlined, size: 18),
              if (title.contains("Past"))
                const Icon(Icons.play_circle_outline, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (showViewAll && routeName != null)
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, routeName);
              },
              child: Text(
                "View All",
                style: TextStyle(color: brandRed, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveList(bool isDark) {
    return Column(
      children: liveNow
          .map(
            (session) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _buildNetworkImage(session.imageUrl),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _badge(brandRed, "● LIVE"),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _badge(
                          Colors.black54,
                          "👁 ${session.viewerCount}",
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: _badge(brandGreen, session.category),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: _badge(Colors.black54, session.timeAgo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.group_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.creator,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
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
                          session.price,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildUpcomingList(bool isDark) {
    return Column(
      children: upcoming
          .map(
            (event) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  if (!isDark)
                    const BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  _buildNetworkImage(event.imageUrl, width: 80, height: 80),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              event.price,
                              style: TextStyle(
                                color: brandGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          event.creator,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.orange,
                            ),
                            Text(
                              " ${event.date}",
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 12,
                              color: Colors.grey,
                            ),
                            Text(
                              " ${event.registered}",
                              style: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: brandGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPastEventsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                _buildNetworkImage("https://fail.com", height: 150),
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white70,
                  size: 40,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _badge(Colors.orange, "⭐ 4.9"),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: _badge(Colors.black54, "👁 3,421"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "JavaScript Pro Tips",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TechMasterPro",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  "\$9.99",
                  style: TextStyle(
                    color: brandGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
