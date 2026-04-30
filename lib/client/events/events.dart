import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/events/all_live_events.dart';
import 'package:smacredit/client/events/client_live_event_details.dart';
import 'package:smacredit/client/events/upcoming_events.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/theme/app_theme.dart';

// --- LIVE EVENTS WIDGET ---
class LiveEventsWidget extends StatefulWidget {
  const LiveEventsWidget({super.key});

  @override
  _LiveEventsWidgetState createState() => _LiveEventsWidgetState();
}

class _LiveEventsWidgetState extends StateMVC<LiveEventsWidget> {
  // MOCK DATA

  late ClientUserController _con;

  _LiveEventsWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForEventDashboad();
  }

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
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: Text("Tese Africa"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => ClientLiveEventsWidget(),
                  ),
                ).then((e) {
                  _con.listenForEventDashboad();
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00D285), // Your brandGreen
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              child: const Text("EXPLORE"),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSectionHeader("Live Now", true, '/LiveEvents', () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ClientEventListGroup(
                    type: EventGroupType.live,
                    title: 'Live events',
                  ),
                ),
              ).then((e) {
                _con.listenForEventDashboad();
              });
            }),
            _buildLiveList(isDark),
            _buildSectionHeader("Upcoming Events", true, '/UpcomingEvents', () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ClientEventListGroup(
                    type: EventGroupType.upcoming,
                    title: 'Upcoming events',
                  ),
                ),
              ).then((e) {
                _con.listenForEventDashboad();
              });
            }),
            _buildUpcomingList(isDark),
            _buildSectionHeader("Past Events", true, '/Past', () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => ClientEventListGroup(
                    type: EventGroupType.past,
                    title: 'Past events',
                  ),
                ),
              ).then((e) {
                _con.listenForEventDashboad();
              });
            }),

            // _buildSectionSubHeader("Past Events ", true, '/PastEvents'),
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
    VoidCallback callback,
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
                callback();
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

  goToEvent(EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ClientEventDetailsScreen(event: event),
      ),
    );
  }

  Widget _buildLiveList(bool isDark) {
    return Column(
      children: (_con.eventDashboardResponse?.live ?? [])
          .map(
            (session) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: InkWell(
                onTap: () {
                  goToEvent(session);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        _buildNetworkImage(session.thumbnail ?? ""),
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
                            "👁 ${session.purchaseCount}",
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: _badge(
                            brandGreen,
                            session.organizer?.fullname ?? "",
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: _badge(
                            Colors.black54,
                            session.startDate.toIso8601String(),
                          ),
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
                              session.organizer?.fullname ?? "",
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
                            session.price.toStringAsFixed(2),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildUpcomingList(bool isDark) {
    return Column(
      children: (_con.eventDashboardResponse?.nextUpcoming ?? [])
          .map(
            (event) => InkWell(
              onTap: () {
                goToEvent(event);
              },
              child: Container(
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
                    _buildNetworkImage(
                      event.thumbnail ?? "",
                      width: 80,
                      height: 80,
                    ),
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
                                event.price.toStringAsFixed(2),
                                style: TextStyle(
                                  color: brandGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            event.organizer?.fullname ?? "",
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
                                " ${event.startDate.toIso8601String()}",
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
                                " ${event.hasPurchased ? 'Registred' : 'Not Registered'}",
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: (_con.eventDashboardResponse?.past ?? []).length,
      itemBuilder: (context, index) {
        EventModel event = (_con.eventDashboardResponse?.past ?? [])[index];
        return InkWell(
          onTap: () {
            goToEvent(event);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  _buildNetworkImage(event.thumbnail ?? "", height: 150),
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: 40,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _badge(Colors.orange, "⭐ ${event.rating}"),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: _badge(Colors.black54, "👁 ${event.views}"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${event.title}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${event.organizer?.fullname ?? ''}",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  Text(
                    "${event.currency}${event.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: brandGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
