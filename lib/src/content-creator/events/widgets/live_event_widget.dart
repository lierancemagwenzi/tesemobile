import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/events/client_live_event_details.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/content-creator/events/widgets/broadcast_widget.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class CreatorEventCommandCenter extends StatefulWidget {
  final EventModel event;

  const CreatorEventCommandCenter({super.key, required this.event});

  @override
  StateMVC<CreatorEventCommandCenter> createState() =>
      _CreatorEventCommandCenterState();
}

class _CreatorEventCommandCenterState
    extends StateMVC<CreatorEventCommandCenter> {
  late CreatorController _con;

  _CreatorEventCommandCenterState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  // Helper to calculate duration string
  String _getDuration() {
    final diff = _con.eventModel!.endDate.difference(
      _con.eventModel!.startDate,
    );
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    return "${hours}h ${minutes}m";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.listenForEvent(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    const Color teseGreen = Color(0xFF00D285);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isPast = _con.eventModel?.isPast ?? true;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        body: _con.eventModel == null
            ? EventDetailsLoadingWidget()
            : CustomScrollView(
                slivers: [
                  // 1. DYNAMIC HEADER WITH OVERLAY
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _con.eventModel!.thumbnail ?? '',
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  isDark
                                      ? const Color(0xFF0F0F0F)
                                      : Colors.white,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. MAIN CONTENT
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusBadge(isPast, teseGreen),
                          const SizedBox(height: 12),
                          Text(
                            _con.eventModel!.title,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // 3. STATS GRID (Dummy data for past events)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem(
                                LucideIcons.users,
                                isPast
                                    ? "1.2k"
                                    : "${_con.eventModel!.purchaseCount}",
                                "Viewers",
                              ),
                              _buildStatItem(
                                LucideIcons.messageSquare,
                                isPast ? "458" : "0",
                                "Comments",
                              ),
                              _buildStatItem(
                                LucideIcons.clock,
                                _getDuration(),
                                "Duration",
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(color: Colors.white10),
                          ),

                          // 4. SCHEDULE DETAILS
                          _buildDetailRow(
                            LucideIcons.calendar,
                            "Starts",
                            DateFormat(
                              'EEEE, MMM dd • HH:mm',
                            ).format(_con.eventModel!.startDate),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            LucideIcons.calendarCheck,
                            "Ends",
                            DateFormat(
                              'EEEE, MMM dd • HH:mm',
                            ).format(_con.eventModel!.endDate),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            LucideIcons.banknote,
                            "Revenue",
                            "${_con.eventModel!.currency} ${_con.eventModel!.price * (isPast ? 1200 : _con.eventModel!.purchaseCount)}",
                          ),

                          const SizedBox(height: 40),

                          // 5. CONDITIONAL ACTION BUTTON
                          if (!isPast && _con.eventModel!.canStart)
                            _buildActionButton(
                              "START BROADCAST",
                              teseGreen,
                              LucideIcons.play,
                              () async {
                                StreamWatchUnlockModel? details = await _con
                                    .startStream({
                                      "stream_id": _con.eventModel!.id,
                                    });

                                if (details != null) {
                                  if (details.valid == true) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => StreamSelectionDialog(
                                        onMobileStream: () {
                                          if (kDebugMode) {
                                            print(
                                            "User selected Mobile - Open Camera Logic",
                                          );
                                          }
                                          // Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (context) =>
                                                  FullScreenBroadcast(
                                                    eventModel:
                                                        _con.eventModel!,
                                                    streamWatchUnlockModel:
                                                        details,
                                                  ),
                                            ),
                                          );
                                        },
                                        onProfessionalStream: () {
                                          // Navigator.pop(context);
                                          print(
                                            "User selected Pro - API call to trigger RTMP email",
                                          );
                                          // _con.requestStreamConfiguration(eventId);
                                        },
                                      ),
                                    );
                                  } else {
                                    CustomMessageHandler().showErrorSnakeBar(
                                      context,
                                      details.message ?? "",
                                    );
                                  }
                                } else {
                                  CustomMessageHandler().showErrorSnakeBar(
                                    context,
                                    "Something went wrong.Try again",
                                  );
                                }
                              },
                            )
                          else if (isPast)
                            _buildActionButton(
                              "VIEW ANALYTICS",
                              Colors.white24,
                              LucideIcons.barChart3,
                              () {},
                            )
                          else
                            _buildWaitingCard(),

                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPast, Color teseGreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPast ? Colors.white10 : teseGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPast ? "PAST EVENT" : "UPCOMING",
        style: TextStyle(
          color: isPast ? Colors.grey : teseGreen,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start, // or start if you want it left-aligned
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00D285)),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    IconData icon,
    onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          onPressed();
        },
        icon: Icon(icon, color: Colors.black),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.info, color: Colors.amber),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "You can go live 15 minutes before the scheduled start time.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class StreamSelectionDialog extends StatelessWidget {
  final VoidCallback onMobileStream;
  final VoidCallback onProfessionalStream;

  const StreamSelectionDialog({
    super.key,
    required this.onMobileStream,
    required this.onProfessionalStream,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // BRANDED ICON
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF00D285), // Tese Green
              child: Icon(LucideIcons.video, color: Colors.black, size: 28),
            ),
            const SizedBox(height: 20),
            const Text(
              "Start Streaming",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
            ),
            const SizedBox(height: 12),
            const Text(
              "An email with configuration for external software has been sent to you.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 32),

            // ACTION: MOBILE
            _buildActionButton(
              context: context,
              label: "STREAM ON MOBILE",
              icon: LucideIcons.smartphone,
              isPrimary: true,
              onTap: onMobileStream,
            ),

            const SizedBox(height: 12),

            // ACTION: PROFESSIONAL
            _buildActionButton(
              context: context,
              label: "PROFESSIONAL STREAMING",
              icon: LucideIcons.monitor,
              isPrimary: false,
              onTap: onProfessionalStream,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onTap();
              },
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D285),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onTap();
              },
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black,
                side: BorderSide(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
    );
  }
}
