import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/notifications/controllers/notification_controller.dart';
import 'package:smacredit/src/notifications/models/notification_model.dart';
import 'package:smacredit/src/notifications/widgets/notification_details.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

// --- Data Model for a Single Notification ---
class NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String time;
  final bool isRead;

  const NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
  });
}

// --- Notification Card Widget ---
class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final NotificationModel notificationModel;
  final VoidCallback? onDelete; // Callback for delete action
  final VoidCallback? onClick;
  const NotificationCard({
    super.key,
    required this.notification,
    required this.notificationModel,
    this.onDelete,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notification.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification.icon,
              color: notification.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Details (Title, Description, Time)
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailScreen(
                          notification: notificationModel,
                        ),
                      ),
                    )
                    .then((_) {
                      onClick!();
                    });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),

          // Delete Icon
          InkWell(
            onTap: onDelete,
            child: Container(
              height: 50,
              width: 50,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Notifications Screen Widget (Stateful for tabs) ---
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  StateMVC<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends StateMVC<NotificationsScreen> {
  late NotificationController _con;

  _NotificationsScreenState() : super(NotificationController()) {
    _con = controller as NotificationController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForNotifications();
  }

  int _selectedTab = 0; // 0 for All, 1 for Unread

  // Mock Notification Data
  final List<NotificationItem> _allNotifications = [
    const NotificationItem(
      icon: Icons.check_circle_outline,
      iconColor: Colors.green, // Green for success
      title: 'Payment Received: \$23.50',
      description: 'Transaction from Rebecca_craft via Payment Link completed.',
      time: 'Today 11:04 AM',
      isRead: false,
    ),
    const NotificationItem(
      icon: Icons.link,
      iconColor: Colors.blue, // Blue for link/info
      title: 'Payment Link Created',
      description: 'Your "Church Offering" link is live and ready to use.',
      time: 'Today 11:03 AM',
      isRead: false,
    ),
    const NotificationItem(
      icon: Icons.cancel_outlined,
      iconColor: Colors.red, // Red for failure
      title: 'Withdrawal Failed: \$100.00',
      description:
          'Withdrawal attempt to Bank Transfer was unsuccessful. Please check details.',
      time: 'Today 10:59 AM',
      isRead: true,
    ),
    const NotificationItem(
      icon: Icons.add_card,
      iconColor: Colors.orange, // Orange for pending/in-progress
      title: 'Payout In Progress: \$400.00',
      description:
          'Payout to Ecocash is being processed and should complete in 24 hours.',
      time: 'Yesterday 10:58 AM',
      isRead: true,
    ),
    const NotificationItem(
      icon: Icons.receipt_long,
      iconColor: Colors.purple, // New color for a different category
      title: 'New Transaction: \$150.00',
      description:
          'Direct payment received from David_lyle (Transaction ID: #BK156373).',
      time: 'Yesterday 09:00 AM',
      isRead: false,
    ),
    const NotificationItem(
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
      title: 'Payment Received: \$5.50',
      description: 'Payment Request fulfilled by Coffee Shop.',
      time: 'Yesterday 08:30 AM',
      isRead: true,
    ),
  ];

  List<NotificationModel> get _filteredNotifications {
    if (_selectedTab == 0) {
      return _con.notifications;
    } else {
      return _con.notifications.where((n) => !n.opened!).toList();
    }
  }

  void _deleteNotification(NotificationModel notification) {
    _con.DeleteNotification(notification.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    // You can define primary and accent colors here for consistency
    final Color primaryGreen = Colors.green.shade700;
    final Color accentRed = Colors
        .red
        .shade400; // Keeping red for specific accents like the bell icon

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: Colors.grey.shade50, // Light grey background
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
                // Handle back navigation
              },
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_con.notifications.where((n) => !n.opened!).length} unread notifications',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            // Tab Selector (All / Unread)
            _buildTabSelector(primaryGreen, accentRed),
            const SizedBox(height: 16),

            // Notification List
            _filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        Text("No notifications found"),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return NotificationCard(
                          notification: NotificationItem(
                            icon: Icons.check_circle_outline,
                            iconColor: Colors.green,
                            title: notification.title ?? '',
                            description: notification.body ?? '',
                            time: formatRelativeTime(
                              notification.createdAt ?? DateTime.now(),
                            ),
                            isRead: notification.opened ?? false,
                          ),
                          onDelete: () {
                            print("cliked");
                            _deleteNotification(notification);
                          },
                          notificationModel: notification,
                          onClick: () => _con.MarkAsRead(notification.id!),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(Color primaryGreen, Color accentRed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // All Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedTab == 0
                        ? primaryGreen
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  'All (${_con.notifications.length})',
                  style: TextStyle(
                    color: _selectedTab == 0 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Unread Tab
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedTab == 1
                        ? primaryGreen
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  'Unread (${_con.notifications.where((n) => !n.opened!).length})',
                  style: TextStyle(
                    color: _selectedTab == 1 ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  navigateToDetail(
    BuildContext context,
    NotificationModel selectedNotification,
    int index,
  ) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                NotificationDetailScreen(notification: selectedNotification),
          ),
        )
        .then((_) {
          // _con.MarkAsRead(selectedNotification.id!, index, 1);
        });
  }

  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // 1. Determine if the date is Today, Yesterday, or another day
    String dayString;
    if (dateToCheck.isAtSameMomentAs(today)) {
      dayString = 'Today';
    } else if (dateToCheck.isAtSameMomentAs(yesterday)) {
      dayString = 'Yesterday';
    } else {
      // If not today or yesterday, show the full date (e.g., Nov 25)
      dayString = DateFormat('MMM d').format(dateTime);
    }

    // 2. Format the time part (e.g., 08:30 AM)
    // Use 'jm' for locale-aware time (e.g., '8:30 AM' in en_US)
    final timeString = DateFormat('jm').format(dateTime);

    // 3. Combine them
    return '$dayString $timeString';
  }
}
