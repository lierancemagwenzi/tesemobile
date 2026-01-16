import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/controller/creator_controller.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:smat_pay_payment_plugin/util/models/request/track_payment_request.dart';

// --- Dummy Channel Model ---
class ChannelData {
  final String name;
  final String description;
  final String logoUrl;
  final String coverUrl;
  final bool isPublic;
  final String status;
  final bool subscriptionEnabled;
  final String price;
  final String currency;
  final String period;

  ChannelData({
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.coverUrl,
    required this.isPublic,
    required this.status,
    required this.subscriptionEnabled,
    required this.price,
    required this.currency,
    required this.period,
  });
}

class PlaylistData {
  final String title;
  final int videoCount;
  final String thumbnailUrl;

  PlaylistData({
    required this.title,
    required this.videoCount,
    required this.thumbnailUrl,
  });
}

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

  // --- UI Components ---

  Widget _buildCreatePlaylistButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF558B4F), Color(0xFFD9CF52)],
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/CreatePlaylist',
            arguments: widget.channel,
          ).then((v) {
            _con.listenForChannel(widget.channel.id);
          });
        },
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          "Create Playlist",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(Playlist playlist) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/Playlist',
          arguments: {'playlist': playlist, 'channel': widget.channel},
        ).then((v) {});
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Thumbnail with Video Count Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    playlist.thumbnailUrl ?? '',
                    width: 80,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 60,
                        width: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.playlist_play,
                          color: Colors.white,
                          size: 12,
                        ),
                        Text(
                          " ${playlist.videos!.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title ?? "-",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${playlist.videos!.length} Videos",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStack() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          color: Colors.grey.shade300,
        ),
        Positioned(
          bottom: -40,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        // --- AppBar with Edit Button ---
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },

            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: const Text(
            "Channel Preview",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: _con.channelModel == null
              ? []
              : [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/EditChannel',
                        arguments: widget.channel,
                      ).then((e) {
                        _con.listenForChannel(widget.channel.id);
                      });
                      // Action for editing
                    },
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Color(0xFFE55743),
                    ),
                    label: const Text(
                      "Edit",
                      style: TextStyle(
                        color: Color(0xFFE55743),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
        ),
        body: _con.channelModel == null
            ? SizedBox.shrink()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header: Cover and Logo Stack ---
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                _con.channelModel?.coverImageUrl ?? '',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -40,
                          left: 20,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: NetworkImage(
                                _con.channelModel?.logoUrl ?? '',
                              ),
                            ),
                          ),
                        ),
                        // Visibility Badge
                        Positioned(
                          bottom: 10,
                          right: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _con.channelModel?.isPublic == true
                                      ? Icons.public
                                      : Icons.lock,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _con.channelModel?.isPublic == true
                                      ? "Public"
                                      : "Private",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // --- Channel Content ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _con.channelModel?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _con.channelModel?.status
                                              ?.toLowerCase() ==
                                          "active"
                                      ? Colors.green.shade50
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _con.channelModel?.status ?? '',
                                  style: TextStyle(
                                    color:
                                        _con.channelModel?.status
                                                ?.toLowerCase() ==
                                            "active"
                                        ? Colors.green
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _con.channelModel?.description ?? '',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              // height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // --- Subscription Card ---
                          if (_con.channelModel?.subscriptionEnabled ==
                              $TrackPaymentRequestCopyWith)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F9F9),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Color(0xFFE55743),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Premium Access",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          "Billed ${_con.channelModel?.subscriptionPeriod}",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "${_con.channelModel?.subscriptionCurrency} ${_con.channelModel?.subscriptionPrice}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 25),

                          if (_con.channelModel?.playlists?.isEmpty ==
                              true) ...[
                            // Content Placeholder
                            const Text(
                              "Videos & Playlists",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildContentPlaceholder(),

                            const SizedBox(height: 30),

                            // --- Playlists Section ---

                            // Create Playlist Button (Theme Gradient)
                          ],
                          _buildCreatePlaylistButton(context),

                          const SizedBox(height: 20),
                          if (_con.channelModel?.playlists?.isEmpty ==
                              false) ...[
                            const Text(
                              "Videos & Playlists",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            // List of Playlists
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _con.channelModel!.playlists!.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildPlaylistCard(
                                  _con.channelModel!.playlists![index],
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildContentPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
          style: BorderStyle.solid,
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.video_library_outlined, color: Colors.grey, size: 40),
          SizedBox(height: 10),
          Text("No content uploaded yet", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
