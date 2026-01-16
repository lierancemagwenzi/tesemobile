import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/theme/app_theme.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class PlayListVideosWidget extends StatefulWidget {
  final Playlist playlist;
  // final Channel channel;
  const PlayListVideosWidget({
    super.key,
    required this.playlist,
    // required this.channel,
  });

  @override
  StateMVC<PlayListVideosWidget> createState() => _PlayListVideosWidgetState();
}

class _PlayListVideosWidgetState extends StateMVC<PlayListVideosWidget> {
  late ClientUserController _con;

  _PlayListVideosWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();

    _con.listenForPlaylistVideos(widget.playlist.id);
    _con.listenForChannel(widget.playlist.channelId ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    // Theme-aware variables based on previous discussions
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;
    final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          backgroundColor: scaffoldBg,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },

            child: Icon(Icons.arrow_back, color: textColor),
          ),
          title: Text(
            '${widget.playlist.title ?? ''} playlist',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          actions: [
            // Icon(Icons.share, color: textColor),
            // const SizedBox(width: 16),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER SECTION
              _buildHeaderCard(cardColor, textColor, subTextColor, isDark),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Text(
                  'Videos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              // 2. VIDEO LIST
              _con.videos.isEmpty
                  ? TeseEmptyWidget()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _con.videos.length,
                      itemBuilder: (context, index) => _buildVideoListItem(
                        textColor,
                        subTextColor,
                        isDark,
                        _con.videos[index],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    Color cardColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner with Playlist Icon
          Stack(
            children: [
              _buildNetworkImage(
                widget.playlist.thumbnailUrl ?? "",
                height: 200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                isDark: isDark,
              ),
              Positioned(
                bottom: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.playlist_play, color: Colors.white, size: 20),
                      SizedBox(width: 5),
                      Text(
                        '${_con.videos.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.playlist.title}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.playlist.description}',
                  style: TextStyle(color: subTextColor, fontSize: 15),
                ),
                const SizedBox(height: 16),
                // Creator Attribution Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    _buildNetworkImage(
                      _con.channel?.logoUrl ?? "",
                      height: 45,
                      width: 45,
                      isCircle: true,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            _con.channel?.name ?? "",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            _con.channel?.description ?? "",
                            // maxLines: 1,
                            // overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoListItem(
    Color textColor,
    Color subTextColor,
    bool isDark,
    Video video,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/Player',
          arguments: {'video': video, 'channel': _con.channel},
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail
            _buildNetworkImage(
              video.thumbnailUrl ?? "",
              width: 90,
              height: 90,
              borderRadius: BorderRadius.circular(15),
              isDark: isDark,
            ),
            const SizedBox(width: 15),
            // Video Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //  _con.channel?.name ?? "",
                  //   style: TextStyle(color: Colors.grey, fontSize: 12),
                  // ),
                  Text(
                    '${video.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '${video.description}',

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Stats Row
                  Row(
                    children: [
                      _buildSmallIconText(
                        Icons.favorite_border,
                        "${video.likeCount ?? 0}",
                        subTextColor,
                      ),
                      const SizedBox(width: 12),
                      _buildSmallIconText(
                        Icons.visibility_outlined,
                        "${video.viewCount ?? 0}",
                        subTextColor,
                      ),
                      const SizedBox(width: 12),
                      _buildSmallIconText(
                        Icons.file_download_outlined,
                        "${video.downloadCount ?? 0}",
                        subTextColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D285), // Tese Green
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Play',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                video.hasAccess == true
                    ? Icon(
                        Icons.check_circle_outline_outlined,
                        color: const Color(0xFF00D285),
                      )
                    : Icon(Icons.lock, color: Color(0xFFFFD700)),
              ],
            ),
            // else
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: [
            //       InkWell(
            //         onTap: () {
            //           if (video.hasPurchased == 0) {
            //             UtilsHelper.ensureAuth(
            //               context,
            //               action: "to purchase this video",
            //               onAuthenticated: () {
            //                 _showPurchaseOptions(video);
            //               },
            //             );
            //           }
            //         },
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 12,
            //             vertical: 8,
            //           ),
            //           decoration: BoxDecoration(
            //             color: const Color(0xFF00D285), // Tese Green
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //           child: const Row(
            //             children: [
            //               Text(
            //                 'Purchase1',
            //                 style: TextStyle(
            //                   color: Colors.white,
            //                   fontSize: 12,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //               Icon(
            //                 Icons.chevron_right,
            //                 color: Colors.white,
            //                 size: 16,
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            //       const SizedBox(height: 25),
            //       Text(
            //         'Watch Trailer',
            //         style: TextStyle(color: subTextColor, fontSize: 11),
            //       ),
            //     ],
            //   ),
          ],
        ),
      ),
    );
  }

  bool didPurchase(Video video) {
    if (_con.channel?.subscriptionEnabled == true &&
            _con.channel?.hasPurchased == 1 ||
        video.accessType?.toLowerCase() == 'paid') {
      if (video.hasPurchased == 1) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  bool hasAccess(Video video) {
    if (video.accessType?.toLowerCase() == 'paid') {
      if (_con.channel?.subscriptionEnabled == true &&
          _con.channel?.hasPurchased == 1) {
        return true;
      }
      if (video.hasPurchased == 1) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  void _showPurchaseOptions(Video video) async {
    final PaymentSelection? result =
        await showModalBottomSheet<PaymentSelection>(
          context: context,
          isScrollControlled: true, // Important for the keyboard
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => const PaymentModal(),
        );

    if (result != null) {
      print("Selected: ${result.method}");
      if (result.ecoCashNumber != null) {
        print("EcoCash Number: ${result.ecoCashNumber}");
      }

      Map map = {
        "wallet": "Visa",
        "amount": video.price ?? 1,
        "currency": "USD",
        "paymentDescription": "Video Purchase payment",
        "payer": "${currentuser.value.user?.fullname}",
        "user_id": currentuser.value.user?.id,
        "video_id": video.id,
        "payerMobile": result.ecoCashNumber ?? "",
      };
      PaymentResponseWrapper? res = await _con.buyVideo(map);

      if (res != null) {
        if (result.method.toLowerCase() == 'visa' ||
            result.method.toLowerCase() == 'mastercard') {
          Navigator.pushNamed(
            context,
            '/VisaMastercardPayment',
            arguments:
                res.response?.paymentInitiationResponse?.paymentCode ?? "",
          ).then((e) {
            _con.listenForPlaylistVideos(widget.playlist.id);
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            _con.listenForPlaylistVideos(widget.playlist.id);
          });
        }
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          context,
          "Something went wrong.Try again",
        );
      }

      // TODO: Trigger your Paynow / Paynow_flutter integration here
    }
  }

  // REUSABLE IMAGE HELPER (SHIMMER + ERROR)
  Widget _buildNetworkImage(
    String url, {
    double? height,
    double? width,
    BorderRadius? borderRadius,
    bool isCircle = false,
    required bool isDark,
  }) {
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: isDark ? Colors.white10 : Colors.grey[300]!,
        highlightColor: isDark ? Colors.white24 : Colors.grey[100]!,
        child: Container(
          height: height,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: borderRadius,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey[300],
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.broken_image,
          color: isDark ? Colors.white30 : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSmallIconText(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
