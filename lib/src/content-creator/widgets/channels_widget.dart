// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
// import 'package:smacredit/src/content-creator/models/channel_model.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';

// // 1. Data Model

// class ChannelListScreen extends StatefulWidget {
//   final VoidCallback onPop;

//   const ChannelListScreen({super.key, required this.onPop});

//   @override
//   StateMVC<ChannelListScreen> createState() => _ChannelListScreenState();
// }

// class _ChannelListScreenState extends StateMVC<ChannelListScreen> {
//   late CreatorController _con;

//   _ChannelListScreenState() : super(CreatorController()) {
//     _con = controller as CreatorController;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _con.listenForChannels();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Mock data based on your requirements

//     return PopScope(
//       canPop: false,
//       child: CustomOverlay(
//         loading: _con.loading,
//         child: Scaffold(
//           key: _con.scaffoldKey,
//           backgroundColor: const Color(0xFFF8F8F8), // Light grey background
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   _buildCustomAppBar(),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Container(
//                       width: double.infinity,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pushNamed(context, '/CreateChannel').then((
//                             v,
//                           ) {
//                             _con.listenForChannels();
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           shadowColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: const Text(
//                           "+ Create Channel",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // Channel List
//                   _con.channels.isEmpty
//                       ? RefreshIndicator(
//                           onRefresh: () async {
//                             await _con.refreshNotifications();
//                           },
//                           child: SingleChildScrollView(
//                             child: Column(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(30),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     shape: BoxShape.circle,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 10,
//                                         spreadRadius: 5,
//                                       ),
//                                     ],
//                                   ),
//                                   child: const Icon(
//                                     Icons.tv_off_rounded,
//                                     size: 80,
//                                     color: Color(
//                                       0xFFB0B3B8,
//                                     ), // Muted FB icon grey
//                                   ),
//                                 ),
//                                 const SizedBox(height: 32),

//                                 // 2. TEXT CONTENT
//                                 const Text(
//                                   "No Channels Yet",
//                                   style: TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 const Text(
//                                   "Create your first channel to start organizing your playlists and sharing your videos with the world.",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: Color(
//                                       0xFF65676B,
//                                     ), // Standard FB subtext color
//                                     height: 1.4,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 32),
//                               ],
//                             ),
//                           ),
//                         )
//                       : Expanded(
//                           child: ListView.builder(
//                             padding: const EdgeInsets.symmetric(horizontal: 16),
//                             itemCount: _con.channels.length,
//                             itemBuilder: (context, index) {
//                               return ChannelCard(channel: _con.channels[index]);
//                             },
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomAppBar() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Back Button
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios_new,
//                 size: 20,
//                 color: Colors.black,
//               ),
//               onPressed: widget.onPop, // Placeholder action
//             ),
//           ),

//           // Title
//           const Text(
//             'Channels',
//             style: TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.bold,
//               color: Colors.black,
//             ),
//           ),

//           // Filter Button
//           // Container(
//           //   decoration: BoxDecoration(
//           //     shape: BoxShape.circle,
//           //     border: Border.all(color: Colors.grey.shade200),
//           //   ),
//           //   child: const IconButton(
//           //     icon: Icon(Icons.tune, size: 24, color: Colors.red),
//           //     onPressed: null, // Placeholder action
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

// // 2. Custom Channel Card Widget
// class ChannelCard extends StatelessWidget {
//   final Channel channel;

//   const ChannelCard({super.key, required this.channel});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(context, '/Channel', arguments: channel);
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(color: Colors.grey.shade300, width: 0.5),
//         ),
//         child: Row(
//           children: [
//             // Channel Image
//             CircleAvatar(
//               radius: 25,
//               backgroundImage: NetworkImage(channel.coverImageUrl ?? ''),
//               backgroundColor: Colors.grey.shade200,
//             ),
//             const SizedBox(width: 12),

//             // Name, Description, and Date
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         channel.name ?? '',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(width: 5),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     "${channel.description}",
//                     style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),

//                   Row(
//                     children: [
//                       Icon(
//                         Icons.calendar_month,
//                         size: 14,
//                         color: Colors.grey.shade400,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         formatDateString(channel.createdAt),
//                         style: TextStyle(
//                           color: Colors.grey.shade400,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // Status Label
//             Text(
//               channel.status ?? '',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 15,
//                 color: channel.status == "Active"
//                     ? Colors.green
//                     : Colors.grey.shade700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String formatDateString(DateTime? dateTime) {
//     if (dateTime == null) {
//       return 'unknown date';
//     }
//     // 1. Convert the ISO 8601 string to a DateTime object
//     // DateTime.parse handles the T and timezone offset automatically.

//     // 2. Define the desired format
//     DateFormat formatter = DateFormat('yyyy-MM-dd');

//     // 3. Format the DateTime object
//     String formattedDate = formatter.format(dateTime);
//     // Output: 2025-11-18

//     return formattedDate;
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: CustomOverlay(
        loading: _con.loading,
        child: Scaffold(
          key: _con.scaffoldKey,
          backgroundColor: isDark ? Colors.black : Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(isDark),

                // 1. Create Channel Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildCreateButton(isDark),
                ),

                // 2. Channel List / Empty State
                Expanded(
                  child: _con.channels.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _con.channels.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
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
    );
  }

  Widget _buildCustomAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleButton(
            icon: Icons.arrow_back_ios_new,
            onTap: widget.onPop,
            isDark: isDark,
          ),
          Text(
            'Channels',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 45), // Visual balance for back button
        ],
      ),
    );
  }

  Widget _buildCreateButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF679E4F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/CreateChannel').then((v) {
            _con.listenForChannels();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          "+ Create Channel",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return RefreshIndicator(
      onRefresh: () async => await _con.listenForChannels(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1A1A1A)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.tv_off_rounded,
                  size: 80,
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "No Channels Yet",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Start organizing your playlists and sharing your videos with the world.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white38 : Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Reusable Channel Card ---
class ChannelCard extends StatelessWidget {
  final Channel channel;

  const ChannelCard({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isActive = channel.status?.toLowerCase() == "active";

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/Channel', arguments: channel),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            // 1. Cover Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: NetworkImage(channel.coverImageUrl ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 2. Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name ?? 'Untitled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channel.description ?? 'No description provided',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildDateLabel(isDark),
                ],
              ),
            ),

            // 3. Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (channel.status ?? 'Inactive').toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: isActive ? Colors.green : Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLabel(bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.calendar_month,
          size: 12,
          color: isDark ? Colors.white24 : Colors.grey.shade400,
        ),
        const SizedBox(width: 4),
        Text(
          DateFormat(
            'MMM dd, yyyy',
          ).format(channel.createdAt ?? DateTime.now()),
          style: TextStyle(
            color: isDark ? Colors.white24 : Colors.grey.shade400,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// --- Helper UI Components ---
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
