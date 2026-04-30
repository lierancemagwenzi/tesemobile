// import 'package:flutter/material.dart';
// import 'package:mvc_pattern/mvc_pattern.dart';
// import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
// import 'package:smacredit/src/content-creator/models/channel_model.dart';
// import 'package:smacredit/src/widgets/CustomOverlay.dart';
// import 'package:smat_pay_payment_plugin/util/models/request/track_payment_request.dart';

// // --- Dummy Channel Model ---
// class ChannelData {
//   final String name;
//   final String description;
//   final String logoUrl;
//   final String coverUrl;
//   final bool isPublic;
//   final String status;
//   final bool subscriptionEnabled;
//   final String price;
//   final String currency;
//   final String period;

//   ChannelData({
//     required this.name,
//     required this.description,
//     required this.logoUrl,
//     required this.coverUrl,
//     required this.isPublic,
//     required this.status,
//     required this.subscriptionEnabled,
//     required this.price,
//     required this.currency,
//     required this.period,
//   });
// }

// class PlaylistData {
//   final String title;
//   final int videoCount;
//   final String thumbnailUrl;

//   PlaylistData({
//     required this.title,
//     required this.videoCount,
//     required this.thumbnailUrl,
//   });
// }

// class ChannelPreview extends StatefulWidget {
//   final Channel channel;
//   const ChannelPreview({super.key, required this.channel});

//   @override
//   StateMVC<ChannelPreview> createState() => _ChannelPreviewState();
// }

// class _ChannelPreviewState extends StateMVC<ChannelPreview> {
//   late CreatorController _con;

//   _ChannelPreviewState() : super(CreatorController()) {
//     _con = controller as CreatorController;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _con.listenForChannel(widget.channel.id);
//   }

//   // --- UI Components ---

//   Widget _buildCreatePlaylistButton(BuildContext context) {
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
//             '/CreatePlaylist',
//             arguments: widget.channel,
//           ).then((v) {
//             _con.listenForChannel(widget.channel.id);
//           });
//         },
//         icon: const Icon(Icons.add_circle_outline, color: Colors.white),
//         label: const Text(
//           "Create Playlist",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaylistCard(Playlist playlist) {
//     return InkWell(
//       onTap: () {
//         Navigator.pushNamed(
//           context,
//           '/Playlist',
//           arguments: {'playlist': playlist, 'channel': widget.channel},
//         ).then((v) {});
//       },
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: Row(
//           children: [
//             // Thumbnail with Video Count Badge
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     playlist.thumbnailUrl ?? '',
//                     width: 80,
//                     height: 60,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         height: 60,
//                         width: 80,
//                         color: Colors.grey[300],
//                         child: const Icon(
//                           Icons.broken_image,
//                           color: Colors.grey,
//                           size: 50,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Positioned(
//                   right: 0,
//                   bottom: 0,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 4,
//                       vertical: 2,
//                     ),
//                     decoration: const BoxDecoration(
//                       color: Colors.black87,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(4),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.playlist_play,
//                           color: Colors.white,
//                           size: 12,
//                         ),
//                         Text(
//                           " ${playlist.videos!.length}",
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 15),
//             // Info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     playlist.title ?? "-",
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   Text(
//                     "${playlist.videos!.length} Videos",
//                     style: const TextStyle(color: Colors.grey, fontSize: 13),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderStack() {
//     return Stack(
//       clipBehavior: Clip.none,
//       children: [
//         Container(
//           height: 160,
//           width: double.infinity,
//           color: Colors.grey.shade300,
//         ),
//         Positioned(
//           bottom: -40,
//           left: 20,
//           child: Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 4),
//             ),
//             child: CircleAvatar(
//               radius: 45,
//               backgroundColor: Colors.grey.shade400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomOverlay(
//       loading: _con.loading,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         // --- AppBar with Edit Button ---
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
//             "Channel Preview",
//             style: TextStyle(color: Colors.black, fontSize: 18),
//           ),
//           actions: _con.channelModel == null
//               ? []
//               : [
//                   TextButton.icon(
//                     onPressed: () {
//                       Navigator.pushNamed(
//                         context,
//                         '/EditChannel',
//                         arguments: widget.channel,
//                       ).then((e) {
//                         _con.listenForChannel(widget.channel.id);
//                       });
//                       // Action for editing
//                     },
//                     icon: const Icon(
//                       Icons.edit,
//                       size: 18,
//                       color: Color(0xFFE55743),
//                     ),
//                     label: const Text(
//                       "Edit",
//                       style: TextStyle(
//                         color: Color(0xFFE55743),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//         ),
//         body: _con.channelModel == null
//             ? SizedBox.shrink()
//             : SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // --- Header: Cover and Logo Stack ---
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Container(
//                           height: 180,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                               image: NetworkImage(
//                                 _con.channelModel?.coverImageUrl ?? '',
//                               ),
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: -40,
//                           left: 20,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(color: Colors.white, width: 4),
//                             ),
//                             child: CircleAvatar(
//                               radius: 45,
//                               backgroundImage: NetworkImage(
//                                 _con.channelModel?.logoUrl ?? '',
//                               ),
//                             ),
//                           ),
//                         ),
//                         // Visibility Badge
//                         Positioned(
//                           bottom: 10,
//                           right: 15,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.6),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   _con.channelModel?.isPublic == true
//                                       ? Icons.public
//                                       : Icons.lock,
//                                   color: Colors.white,
//                                   size: 14,
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Text(
//                                   _con.channelModel?.isPublic == true
//                                       ? "Public"
//                                       : "Private",
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 50),

//                     // --- Channel Content ---
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Name and Status
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _con.channelModel?.name ?? '',
//                                 style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color:
//                                       _con.channelModel?.status
//                                               ?.toLowerCase() ==
//                                           "active"
//                                       ? Colors.green.shade50
//                                       : Colors.grey.shade100,
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   _con.channelModel?.status ?? '',
//                                   style: TextStyle(
//                                     color:
//                                         _con.channelModel?.status
//                                                 ?.toLowerCase() ==
//                                             "active"
//                                         ? Colors.green
//                                         : Colors.grey,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _con.channelModel?.description ?? '',
//                             style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 12,
//                               // height: 1.4,
//                             ),
//                           ),

//                           const SizedBox(height: 25),

//                           // --- Subscription Card ---
//                           if (_con.channelModel?.subscriptionEnabled ==
//                               $TrackPaymentRequestCopyWith)
//                             Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFF9F9F9),
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(color: Colors.grey.shade200),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const CircleAvatar(
//                                     backgroundColor: Color(0xFFE55743),
//                                     child: Icon(
//                                       Icons.star,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 15),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Text(
//                                           "Premium Access",
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                         Text(
//                                           "Billed ${_con.channelModel?.subscriptionPeriod}",
//                                           style: const TextStyle(
//                                             color: Colors.grey,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Text(
//                                     "${_con.channelModel?.subscriptionCurrency} ${_con.channelModel?.subscriptionPrice}",
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                           const SizedBox(height: 25),

//                           if (_con.channelModel?.playlists?.isEmpty ==
//                               true) ...[
//                             // Content Placeholder
//                             const Text(
//                               "Videos & Playlists",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             _buildContentPlaceholder(),

//                             const SizedBox(height: 30),

//                             // --- Playlists Section ---

//                             // Create Playlist Button (Theme Gradient)
//                           ],
//                           _buildCreatePlaylistButton(context),

//                           const SizedBox(height: 20),
//                           if (_con.channelModel?.playlists?.isEmpty ==
//                               false) ...[
//                             const Text(
//                               "Videos & Playlists",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 15),
//                             // List of Playlists
//                             ListView.separated(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: _con.channelModel!.playlists!.length,
//                               separatorBuilder: (context, index) =>
//                                   const SizedBox(height: 12),
//                               itemBuilder: (context, index) {
//                                 return _buildPlaylistCard(
//                                   _con.channelModel!.playlists![index],
//                                 );
//                               },
//                             ),
//                           ],
//                           const SizedBox(height: 40),
//                         ],
//                       ),
//                     ),
//                   ],
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
// }

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/content-creator/widgets/video_description.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class ChannelPreview extends StatefulWidget {
  final Channel channel;
  const ChannelPreview({super.key, required this.channel});

  @override
  StateMVC<ChannelPreview> createState() => _ChannelPreviewState();
}

class _ChannelPreviewState extends StateMVC<ChannelPreview> {
  late CreatorController _con;

  _ChannelPreviewState() : super(CreatorController()) {
    _con = controller as CreatorController;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForChannel(widget.channel.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final model = _con.channelModel;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: model == null
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(model, isDark),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50), // Offset for the logo
                          _buildChannelInfo(model, isDark),
                          const SizedBox(height: 24),
                          if (model.subscriptionEnabled == true)
                            _buildSubscriptionPremiumCard(model, isDark),
                          const SizedBox(height: 16),
                          ViewEarningsButton(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors
                                    .transparent, // Required for the glass effect
                                isScrollControlled: true,
                                builder: (context) => VideoEarningsSheet(
                                  totalEarnings:
                                      (_con.channelModel?.total_earnings ?? 0)
                                          .toDouble(),
                                  totalSales:
                                      (_con.channelModel?.total_sales ?? 0),
                                  monthlyEarnings:
                                      (_con.channelModel?.monthly_earnings ?? 0)
                                          .toDouble(),
                                  monthlySales:
                                      (_con.channelModel?.monthly_sales ?? 0),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          _buildPlaylistSectionHeader(isDark),
                          const SizedBox(height: 16),
                          _buildCreatePlaylistButton(context, isDark),
                          const SizedBox(height: 20),
                          _buildPlaylistList(model, isDark),
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

  Widget _buildSliverAppBar(Channel model, bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? Colors.black : Colors.white,
      leading: _buildCircleAction(
        Icons.arrow_back,
        () => Navigator.pop(context),
        isDark,
      ),
      actions: [
        _buildCircleAction(Icons.edit_outlined, () {
          Navigator.pushNamed(
            context,
            '/EditChannel',
            arguments: widget.channel,
          ).then((e) => _con.listenForChannel(widget.channel.id));
        }, isDark),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(model.coverImageUrl ?? '', fit: BoxFit.cover),
            // Gradient Overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ),
            // Floating Avatar
            Positioned(
              bottom: -40,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.black : Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: NetworkImage(model.logoUrl ?? ''),
                ),
              ),
            ),
            // Visibility Chip
            Positioned(
              bottom: 15,
              right: 20,
              child: _buildVisibilityChip(model.isPublic ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelInfo(Channel model, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                model.name ?? '',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            _buildStatusBadge(model.status ?? 'Inactive'),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          model.description ?? '',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPremiumCard(Channel model, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A1A),
            isDark ? Colors.grey.shade900 : Colors.black,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF679E4F),
            child: Icon(Icons.star_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Premium Channel",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Billed ${model.subscriptionPeriod}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${model.subscriptionCurrency} ${model.subscriptionPrice}",
            style: const TextStyle(
              color: Color(0xFFBCCB4F),
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistList(Channel model, bool isDark) {
    if (model.playlists == null || model.playlists!.isEmpty) {
      return _buildEmptyState(isDark);
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: model.playlists!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildPlaylistCard(model.playlists![index], isDark),
    );
  }

  Widget _buildPlaylistCard(Playlist playlist, bool isDark) {
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        '/Playlist',
        arguments: {'playlist': playlist, 'channel': widget.channel},
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.network(
                    playlist.thumbnailUrl ?? '',
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black26,
                      child: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title ?? "-",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${playlist.videos?.length ?? 0} Videos",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  if (playlist.isAudio == true) ...[
                    const SizedBox(height: 4),
                    Divider(),
                    const SizedBox(height: 4),
                    Text(
                      "Audio playlist",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.white24 : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper UI Utilities ---

  Widget _buildCircleAction(IconData icon, VoidCallback onTap, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildVisibilityChip(bool isPublic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublic ? Icons.public : Icons.lock_outline,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            isPublic ? "Public" : "Private",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool active = status.toLowerCase() == "active";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: active ? Colors.green : Colors.grey,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildCreatePlaylistButton(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF679E4F).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(
          context,
          '/CreatePlaylist',
          arguments: widget.channel,
        ).then((v) => _con.listenForChannel(widget.channel.id)),
        icon: const Icon(Icons.add_box_rounded, color: Colors.white),
        label: const Text(
          "Create New Playlist",
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

  Widget _buildPlaylistSectionHeader(bool isDark) {
    return Row(
      children: [
        Text(
          "Playlists",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const Spacer(),
        const Icon(Icons.sort, color: Colors.grey, size: 18),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_motion_outlined,
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            size: 50,
          ),
          const SizedBox(height: 16),
          Text(
            "No playlists found",
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
