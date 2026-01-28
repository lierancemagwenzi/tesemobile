import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

// 1. Data Model

class ChannelListScreen extends StatefulWidget {
  final VoidCallback onPop;

  const ChannelListScreen({super.key, required this.onPop});

  @override
  StateMVC<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends StateMVC<ChannelListScreen> {
  late CreatorController _con;

  _ChannelListScreenState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForChannels();
  }

  @override
  Widget build(BuildContext context) {
    // Mock data based on your requirements

    return PopScope(
      canPop: false,
      child: CustomOverlay(
        loading: _con.loading,
        child: Scaffold(
          key: _con.scaffoldKey,
          backgroundColor: const Color(0xFFF8F8F8), // Light grey background
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildCustomAppBar(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/CreateChannel').then((
                            v,
                          ) {
                            _con.listenForChannels();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "+ Create Channel",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Channel List
                  _con.channels.isEmpty
                      ? RefreshIndicator(
                          onRefresh: () async {
                            await _con.refreshNotifications();
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(30),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.tv_off_rounded,
                                    size: 80,
                                    color: Color(
                                      0xFFB0B3B8,
                                    ), // Muted FB icon grey
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // 2. TEXT CONTENT
                                const Text(
                                  "No Channels Yet",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Create your first channel to start organizing your playlists and sharing your videos with the world.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(
                                      0xFF65676B,
                                    ), // Standard FB subtext color
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _con.channels.length,
                            itemBuilder: (context, index) {
                              return ChannelCard(channel: _con.channels[index]);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: Colors.black,
              ),
              onPressed: widget.onPop, // Placeholder action
            ),
          ),

          // Title
          const Text(
            'Channels',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // Filter Button
          // Container(
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     border: Border.all(color: Colors.grey.shade200),
          //   ),
          //   child: const IconButton(
          //     icon: Icon(Icons.tune, size: 24, color: Colors.red),
          //     onPressed: null, // Placeholder action
          //   ),
          // ),
        ],
      ),
    );
  }
}

// 2. Custom Channel Card Widget
class ChannelCard extends StatelessWidget {
  final Channel channel;

  const ChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/Channel', arguments: channel);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Row(
          children: [
            // Channel Image
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(channel.coverImageUrl ?? ''),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 12),

            // Name, Description, and Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        channel.name ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${channel.description}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDateString(channel.createdAt),
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status Label
            Text(
              channel.status ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: channel.status == "Active"
                    ? Colors.green
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDateString(DateTime? dateTime) {
    if (dateTime == null) {
      return 'unknown date';
    }
    // 1. Convert the ISO 8601 string to a DateTime object
    // DateTime.parse handles the T and timezone offset automatically.

    // 2. Define the desired format
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    // 3. Format the DateTime object
    String formattedDate = formatter.format(dateTime);
    // Output: 2025-11-18

    return formattedDate;
  }
}
