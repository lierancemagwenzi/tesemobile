// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
// import 'package:smacredit/src/content-creator/models/channel_model.dart';
// import 'package:smacredit/src/repositories/user_repository.dart';
// import 'package:smacredit/src/utils/xhelper.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';

// class UnifiedPlaylistScreen extends StatefulWidget {
//   final Playlist playlist;
//   final Channel channel;
//   const UnifiedPlaylistScreen({
//     super.key,
//     required this.playlist,
//     required this.channel,
//   });

//   @override
//   StateMVC<UnifiedPlaylistScreen> createState() =>
//       _UnifiedPlaylistScreenState();
// }

// class _UnifiedPlaylistScreenState extends StateMVC<UnifiedPlaylistScreen> {
//   late CreatorController _con;

//   _UnifiedPlaylistScreenState() : super(CreatorController()) {
//     _con = controller as CreatorController;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _con.listenForPlaylist(widget.playlist.id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomOverlay(
//       loading: _con.loading,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF0F2F5), // Standard FB Grey
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0.5,
//           leading: InkWell(
//             onTap: () {
//               Navigator.pop(context);
//             },

//             child: const Icon(Icons.arrow_back, color: Colors.black),
//           ),
//           title: const Text(
//             "Playlist Details",
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 17,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.edit_outlined, color: Colors.black),
//               onPressed: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/UpdatePlaylist',
//                   arguments: _con.playlist,
//                 ).then((v) {
//                   _con.listenForPlaylist(widget.playlist.id);
//                 });
//               },
//             ),
//             // IconButton(
//             //   icon: const Icon(Icons.more_horiz, color: Colors.black),
//             //   onPressed: () {},
//             // ),
//           ],
//         ),
//         body: _con.playlist == null
//             ? SizedBox.shrink()
//             : Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: RefreshIndicator(
//                   onRefresh: () async {
//                     _con.listenForPlaylist(widget.playlist.id);
//                   },
//                   child: CustomScrollView(
//                     slivers: [
//                       // 1. PLAYLIST HEADER & ABOUT SECTION
//                       SliverToBoxAdapter(child: _buildPlaylistAboutSection()),

//                       // 2. ADD VIDEO ACTION BAR
//                       SliverToBoxAdapter(
//                         child: _buildCreateVideoButton(context),
//                       ),

//                       // 3. VIDEOS LIST HEADER
//                       const SliverPadding(
//                         padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
//                         sliver: SliverToBoxAdapter(
//                           child: Text(
//                             "Videos",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),

//                       SliverToBoxAdapter(child: PostUploadDisclaimer()),

//                       if (_con.playlist?.videos?.isEmpty == true) ...[
//                         SliverPadding(
//                           padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
//                           sliver: SliverToBoxAdapter(
//                             child: Column(
//                               children: [
//                                 _buildContentPlaceholder(),

//                                 const SizedBox(height: 30),

//                                 // --- Playlists Section ---

//                                 // Create Playlist Button (Theme Gradient)
//                                 const SizedBox(height: 20),
//                               ],
//                             ),
//                           ),
//                         ),

//                         // Content Placeholder
//                       ],

//                       // 4. VIDEO FEED (MAPS TO YOUR SQL SCHEMA)
//                       _buildVideoFeedList(),

//                       // Extra padding at the bottom
//                       const SliverToBoxAdapter(child: SizedBox(height: 40)),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildContentPlaceholder() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: Colors.grey.shade200,
//           style: BorderStyle.solid,
//         ),
//       ),
//       child: const Column(
//         children: [
//           Icon(Icons.video_library_outlined, color: Colors.grey, size: 40),
//           SizedBox(height: 10),
//           Text("No content uploaded yet", style: TextStyle(color: Colors.grey)),
//         ],
//       ),
//     );
//   }

//   // --- PLAYLIST ABOUT SECTION ---
//   Widget _buildPlaylistAboutSection() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Banner Thumbnail
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               _con.playlist?.thumbnailUrl ?? '',
//               headers: {'Cookie': cloudFrontCookieNotifier.value},
//               height: 180,
//               width: double.infinity,
//               fit: BoxFit.cover,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _con.playlist?.title ?? '',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _con.playlist?.description ?? '',
//             style: TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
//           ),
//           const Divider(height: 30),
//           // Metadata from SQL Fields
//           _buildMetaRow(
//             Icons.public,
//             "Visibility",
//             _con.playlist?.isPublic == true ? "Public" : "Private",
//           ),
//           _buildMetaRow(
//             Icons.monetization_on_outlined,
//             "Access",
//             "${_con.playlist?.type ?? ''} (${_con.playlist?.currency} ${_con.playlist?.price?.toStringAsFixed(2) ?? 0.00})",
//           ),
//           _buildMetaRow(
//             Icons.calendar_today_outlined,
//             "Created",
//             formatVideoDate(_con.playlist?.createdAt),
//           ),
//         ],
//       ),
//     );
//   }

//   String formatVideoDate(DateTime? date) {
//     if (date == null) {
//       return 'A time ago';
//     }
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = DateTime(now.year, now.month, now.day - 1);
//     final dateToCheck = DateTime(date.year, date.month, date.day);

//     if (dateToCheck == today) {
//       return "Today at ${DateFormat('jm').format(date)}"; // e.g., Today at 2:30 PM
//     } else if (dateToCheck == yesterday) {
//       return "Yesterday at ${DateFormat('jm').format(date)}"; // e.g., Yesterday at 10:15 AM
//     } else if (now.difference(date).inDays < 7) {
//       return "${now.difference(date).inDays} days ago"; // e.g., 3 days ago
//     } else {
//       return DateFormat('MMM d, yyyy').format(date); // e.g., Mar 22, 2025
//     }
//   }

//   // --- ADD VIDEO BUTTON (FB STYLE) ---
//   Widget _buildAddVideoAction() {
//     return Container(
//       margin: const EdgeInsets.only(top: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       color: Colors.white,
//       child: Row(
//         children: [
//           const CircleAvatar(
//             backgroundColor: Color(0xFFE7F3FF),
//             child: Icon(Icons.video_call, color: Color(0xFF1877F2)),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pushNamed(
//                   context,
//                   '/AddVideoScreen',
//                   arguments: widget.playlist,
//                 ).then((v) {
//                   _con.listenForPlaylist(widget.playlist.id);
//                 });
//                 // Navigate to Video Creation
//               },
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Text(
//                   "Add a video to this playlist...",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCreateVideoButton(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 50,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: const LinearGradient(
//           colors: [Color(0xFF558B4F), Color(0xFFD9CF52)],
//         ),
//       ),
//       child: ElevatedButton.icon(
//         onPressed: () {
//           Navigator.pushNamed(
//             context,
//             '/AddVideoScreen',
//             arguments: widget.playlist,
//           ).then((v) {
//             _con.listenForPlaylist(widget.playlist.id);
//           });
//         },
//         icon: const Icon(Icons.add_circle_outline, color: Colors.white),
//         label: const Text(
//           "Add Video",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   // --- VIDEO FEED LIST ---
//   Widget _buildVideoFeedList() {
//     return SliverList(
//       delegate: SliverChildBuilderDelegate(
//         (context, index) {
//           Video video = _con.playlist!.videos![index];
//           return Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             color: Colors.white,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Stack(
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         if (video.jobStatus?.toLowerCase() == "complete") {
//                           Navigator.pushNamed(
//                             context,
//                             '/VideoDetails',
//                             arguments: {
//                               'video': video,
//                               'playlist': _con.playlist,
//                               'channel': widget.channel,
//                             },
//                           );
//                         }
//                       },
//                       child: Image.network(
//                         video.thumbnailUrl ?? '',
//                         // headers: {'Cookie': cloudFrontCookieNotifier.value},
//                         height: 200,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             height: 200,
//                             width: double.infinity,
//                             color: Colors.grey[300],
//                             child: const Icon(
//                               Icons.broken_image,
//                               color: Colors.grey,
//                               size: 50,
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 10,
//                       right: 10,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 6,
//                           vertical: 2,
//                         ),
//                         color: Colors.black.withOpacity(0.8),
//                         child: Text(
//                           UtilsHelper.formatLongDuration(
//                             video.durationSeconds ?? 0,
//                           ),
//                           style: TextStyle(color: Colors.white, fontSize: 12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     if (video.jobStatus?.toLowerCase() == "complete") {
//                       Navigator.pushNamed(
//                         context,
//                         '/UpdateVideoScreen',
//                         arguments: {
//                           'video': video,
//                           'playlist': _con.playlist,
//                           'channel': widget.channel,
//                         },
//                       ).then((e) {
//                         _con.listenForPlaylist(widget.playlist.id);
//                       });
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 video.title ?? '',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),

//                               Text(
//                                 'Processing Status: ${video.jobStatus ?? ''}',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.normal,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               // Text(
//                               //   "1.2K views • Published ${formatVideoDate(video.updatedAt)}",
//                               //   style: TextStyle(
//                               //     color: Colors.grey,
//                               //     fontSize: 13,
//                               //   ),
//                               // ),
//                             ],
//                           ),
//                         ),
//                         if (video.jobStatus?.toLowerCase() == "complete")
//                           const Icon(Icons.edit, color: Colors.grey),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // const Divider(height: 1),
//                 // _buildSocialActions(),
//               ],
//             ),
//           );
//         },
//         childCount: _con.playlist?.videos?.length ?? 0, // Dummy video count
//       ),
//     );
//   }

//   // --- HELPERS ---

//   Widget _buildMetaRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, size: 18, color: Colors.grey.shade600),
//           const SizedBox(width: 10),
//           Text(
//             "$label: ",
//             style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.black87, fontSize: 14),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSocialActions() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         TextButton.icon(
//           onPressed: () {},
//           icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
//           label: const Text("Like"),
//         ),
//         TextButton.icon(
//           onPressed: () {},
//           icon: const Icon(Icons.chat_bubble_outline, size: 18),
//           label: const Text("Comment"),
//         ),
//         TextButton.icon(
//           onPressed: () {},
//           icon: const Icon(Icons.share_outlined, size: 18),
//           label: const Text("Share"),
//         ),
//       ],
//     );
//   }
// }

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/widgets/video_description.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class UnifiedPlaylistScreen extends StatefulWidget {
  final Playlist playlist;
  final Channel channel;
  const UnifiedPlaylistScreen({
    super.key,
    required this.playlist,
    required this.channel,
  });

  @override
  StateMVC<UnifiedPlaylistScreen> createState() =>
      _UnifiedPlaylistScreenState();
}

class _UnifiedPlaylistScreenState extends StateMVC<UnifiedPlaylistScreen> {
  late CreatorController _con;

  _UnifiedPlaylistScreenState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForPlaylist(widget.playlist.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Playlist Details",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: isDark ? Colors.white : Colors.black,
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/UpdatePlaylist',
                  arguments: _con.playlist,
                ).then((v) {
                  _con.listenForPlaylist(widget.playlist.id);
                });
              },
            ),
          ],
        ),
        body: _con.playlist == null
            ? const SizedBox.shrink()
            : RefreshIndicator(
                onRefresh: () async {
                  _con.listenForPlaylist(widget.playlist.id);
                },
                child: CustomScrollView(
                  slivers: [
                    // 1. PLAYLIST HEADER
                    SliverToBoxAdapter(
                      child: _buildPlaylistAboutSection(isDark),
                    ),

                    // 2. ADD VIDEO BUTTON
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildCreateVideoButton(context),
                      ),
                    ),

                    // 3. DISCLAIMER
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: PostUploadDisclaimer(),
                      ),
                    ),

                    // 4. VIDEOS HEADER
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          "Content",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // 5. EMPTY STATE OR LIST
                    if (_con.playlist?.videos?.isEmpty == true)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildContentPlaceholder(isDark),
                        ),
                      )
                    else
                      _buildVideoFeedList(isDark),

                    const SliverToBoxAdapter(child: SizedBox(height: 60)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPlaylistAboutSection(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF121212) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _con.playlist?.thumbnailUrl ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _con.playlist?.title ?? '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _con.playlist?.description ?? '',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const Divider(height: 40),
          _buildMetaRow(
            Icons.public,
            "Visibility",
            _con.playlist?.isPublic == true ? "Public" : "Private",
            isDark,
          ),
          _buildMetaRow(
            Icons.monetization_on_outlined,
            "Access",
            "${_con.playlist?.type} (${_con.playlist?.currency} ${_con.playlist?.price?.toStringAsFixed(2)})",
            isDark,
          ),

          _buildMetaRow(
            Icons.mic,
            "Playlist Type",
            _con.playlist?.isAudio == true ? 'Audio' : 'Video',
            isDark,
          ),
          _buildMetaRow(
            Icons.calendar_today_outlined,
            "Created",
            formatVideoDate(_con.playlist?.createdAt),
            isDark,
          ),

          SizedBox(height: 10),
          ViewEarningsButton(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor:
                    Colors.transparent, // Required for the glass effect
                isScrollControlled: true,
                builder: (context) => VideoEarningsSheet(
                  totalEarnings: (_con.playlist?.total_earnings ?? 0)
                      .toDouble(),
                  totalSales: (_con.playlist?.total_sales ?? 0),
                  monthlyEarnings: (_con.playlist?.monthly_earnings ?? 0)
                      .toDouble(),
                  monthlySales: (_con.playlist?.monthly_sales ?? 0),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFeedList(bool isDark) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        Video video = _con.playlist!.videos![index];
        bool isComplete = video.jobStatus?.toLowerCase() == "complete";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      if (isComplete) {
                        Navigator.pushNamed(
                          context,
                          '/VideoDetails',
                          arguments: {
                            'video': video,
                            'playlist': _con.playlist,
                            'channel': widget.channel,
                          },
                        );
                      }
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child:
                          widget.playlist.isAudio == true &&
                              video.thumbnailUrl == null
                          ? Container(
                              child: Icon(Icons.music_note, size: 50),
                              height: 180,
                              width: double.infinity,
                            )
                          : Image.network(
                              video.thumbnailUrl ?? '',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                height: 180,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: widget.playlist.isAudio == true
                                    ? Icon(Icons.music_note, size: 50)
                                    : Icon(Icons.broken_image),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        UtilsHelper.formatLongDuration(
                          video.durationSeconds ?? 0,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                onTap: () {
                  if (isComplete) {
                    Navigator.pushNamed(
                      context,
                      '/UpdateVideoScreen',
                      arguments: {
                        'video': video,
                        'playlist': _con.playlist,
                        'channel': widget.channel,
                      },
                    ).then((e) => _con.listenForPlaylist(widget.playlist.id));
                  }
                },
                title: Text(
                  video.title ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Status: ${video.jobStatus ?? 'Processing'}',
                  style: TextStyle(
                    color: isComplete ? const Color(0xFF679E4F) : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                trailing: isComplete
                    ? const Icon(Icons.edit_note, color: Colors.grey)
                    : const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
              ),
            ],
          ),
        );
      }, childCount: _con.playlist?.videos?.length ?? 0),
    );
  }

  Widget _buildCreateVideoButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/AddVideoScreen',
            arguments: widget.playlist,
          ).then((v) => _con.listenForPlaylist(widget.playlist.id));
        },
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text(
          widget.playlist.isAudio == true ? "Add Audio" : "Add Video",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF679E4F)),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.video_library_outlined, color: Colors.grey, size: 48),
          SizedBox(height: 12),
          Text(
            "No content uploaded yet",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String formatVideoDate(DateTime? date) {
    if (date == null) return 'A time ago';
    return DateFormat('MMM d, yyyy').format(date);
  }
}

class PostUploadDisclaimer extends StatelessWidget {
  const PostUploadDisclaimer({super.key});

  // Theme Colors
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), // Glass effect
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: brandGreen.withOpacity(0.2), // Subtle green border
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: brandGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: brandGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Post-Upload Guide",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _bulletPoint(
                  "Preview & Update: ",
                  "Only available once the job status is COMPLETE.",
                ),
                _bulletPoint(
                  "Visibility: ",
                  "Videos are HIDDEN by default. Use the 'Edit' icon in settings to make them public.",
                ),
                _bulletPoint(
                  "Pricing: ",
                  "Changes won't affect active sessions. New prices apply on the next play.",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(
              Icons.check_circle_outline,
              color: brandGreen,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
