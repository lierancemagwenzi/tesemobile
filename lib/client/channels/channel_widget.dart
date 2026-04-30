import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/client/payments/widgets/payment_widget.dart';
import 'package:smacredit/client/payments/widgets/qr_code_payment.dart';
import 'package:smacredit/src/content-creator/events/widgets/creator_events.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class YouTubeStyleChannelScreen extends StatefulWidget {
  final Channel channel;
  const YouTubeStyleChannelScreen({super.key, required this.channel});

  @override
  StateMVC<YouTubeStyleChannelScreen> createState() =>
      _YouTubeStyleChannelScreenState();
}

class _YouTubeStyleChannelScreenState
    extends StateMVC<YouTubeStyleChannelScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Color teseGreen = const Color(0xFF00D285);
  late AnimationController _shimmerController;
  late ClientUserController _con;

  _YouTubeStyleChannelScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
    _con.listenForChannelPlaylists(widget.channel.id);
    _con.listenForChannel(widget.channel.id);
    _con.listenForChannelVideos(widget.channel.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : Colors.white;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: const BackButton(),
          actions: [


     
            // IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            // IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        body: _con.channel == null
            ? SizedBox()
            : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Channel Banner
                          _buildNetworkImage(
                            widget.channel.coverImageUrl ?? "",
                            height: 150,
                            width: double.infinity,
                          ),

                          // 2. Channel Info Section
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                    widget.channel.logoUrl ?? "",
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.channel.name ?? "Channel",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${_con.channel?.creator?.name ?? "unkown"} ${_con.channel?.creator?.lastname ?? "creator"}",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "@${widget.channel.shortname} • ${widget.channel.playlistCount} playlists • ${widget.channel.videoCount} videos",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _con.channel?.liked == true
                                            ? Icons.favorite
                                            : Icons
                                                  .favorite_outline, // or Icons.info_outline
                                        color: Color(0xFF00D285), // Tese Green
                                        size: 24,
                                      ),
                                      tooltip: "Like channel",
                                      onPressed: () async {
                                        UtilsHelper.ensureAuth(
                                          context,
                                          action: "to like the channel",
                                          onAuthenticated: () async {
                                            await _con
                                                .likeChannel(
                                                  {
                                                    "channel_id":
                                                        widget.channel.id,
                                                  },
                                                  _con.channel?.liked == true
                                                      ? false
                                                      : true,
                                                )
                                                .then((_) {
                                                  _con.listenForChannel(
                                                    widget.channel.id,
                                                  );
                                                });
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.channel.description ?? "",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),

                                const SizedBox(height: 16),
                                // Subscribe Button
                                if (_con.channel != null &&
                                    _con.channel?.subscriptionEnabled == true)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_con
                                                .channel
                                                ?.shouldShowButton['status'] ==
                                            'not_subscribed') {
                                          UtilsHelper.ensureAuth(
                                            context,
                                            action: "to subscribe to channel",
                                            onAuthenticated: () {
                                              _showPurchaseOptions(
                                                _con.channel!,
                                              );
                                            },
                                          );
                                          // _showPurchaseOptions(channel);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        foregroundColor: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "${_con.channel!.shouldShowButton['message']} ${_con.channel?.subscriptionCurrency ?? 'USD'} ${(_con.channel?.subscriptionPrice ?? 0).toStringAsFixed(2)}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        foregroundColor: isDark
                                            ? Colors.black
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "No subscription requirement",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 3. Persistent Tabs
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorColor: isDark ? Colors.white : Colors.black,
                          labelColor: isDark ? Colors.white : Colors.black,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: "HOME"),
                            Tab(text: "PLAYLISTS"),
                            Tab(text: "ABOUT"),
                          ],
                        ),
                        bgColor,
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHomeTab(isDark),
                    _buildPlaylistTab(isDark),
                    const Center(child: Text("Channel Description and Stats")),
                  ],
                ),
              ),
      ),
    );
  }

  handleWebForm(PaymentResponseWrapper payment) {
    if (kDebugMode) {
      print('got_here');
      print(
        payment.response?.paymentInitiationResponse?.paymentRedirectUrl ?? '',
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => TesePaymentWebView(
          initialUrl:
              payment.response?.paymentInitiationResponse?.paymentRedirectUrl ??
              '',
          successUrl: '',
          onPaymentSuccess: () {},
        ),
      ),
    ).then((v) {
      _con.listenForChannel(widget.channel.id);
    });
  }

  handleQRCode(PaymentResponseWrapper payment) {
    if (kDebugMode) {
      print('got_here');
      print(
        payment.response?.paymentInitiationResponse?.paymentRedirectUrl ?? '',
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => TesePaymentQR(
          paymentData:
              payment.response?.paymentInitiationResponse?.paymentToken ?? '',
          amount:
              '${payment.purchase?.currency ?? ''}${payment.purchase?.amount?.toStringAsFixed(2) ?? '0.00'}',
        ),
      ),
    ).then((v) {
      _con.listenForChannel(widget.channel.id);
    });
  }

  void _showPurchaseOptions(Channel video) async {
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
        "wallet": result.method,
        "amount": video.subscriptionPrice ?? 1,
        "currency": video.subscriptionCurrency,
        "paymentDescription": "Channel  subscription payment",
        "payer": "${currentuser.value.user?.fullname}",
        "user_id": currentuser.value.user?.id,
        "channel_id": video.id,
        "payerMobile": result.ecoCashNumber ?? "",
      };
      PaymentResponseWrapper? res = await _con.buyChannel(map);

      if (res != null) {
        if (result.method.toLowerCase() == 'visa' ||
            result.method.toLowerCase() == 'mastercard') {
          Navigator.pushNamed(
            context,
            '/VisaMastercardPayment',
            arguments:
                res.response?.paymentInitiationResponse?.paymentCode ?? "",
          ).then((e) {
            _con.listenForChannel(widget.channel.id);
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            _con.listenForChannel(widget.channel.id);
          });
        } else if (result.method.toLowerCase() == 'zimswitch') {
          handleWebForm(res);
        } else if (result.method.toLowerCase() == 'innbucks') {
          handleQRCode(res);
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

  Widget _buildBanner() {
    return AspectRatio(
      aspectRatio: 16 / 4,
      child: CachedNetworkImage(
        imageUrl: "https://picsum.photos/id/237/800/200",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildNetworkImage(
    String url, {
    double? width,
    double? height,
    double radius = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: 1 == 1
          ? CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,

              fit: BoxFit.cover,
              // 1. Placeholder shown while downloading
              placeholder: (context, url) => Container(
                color: Colors.grey[900], // Matches Tese Navy
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              // 2. Error widget shown if the link is broken
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white24),
              ),
            )
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _ShimmerBox(
                  width: width,
                  height: height,
                  controller: _shimmerController,
                );
              },

              errorBuilder: (context, error, stackTrace) => Container(
                width: width,
                height: height,
                color: Colors.grey[50],
              ),
            ),
    );
  }

  Widget _buildHomeTab(bool isDark) {
    Video? featured = getMostViewedVideo();
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (featured != null) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Featured",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/Player',
                arguments: {'video': featured, 'channel': _con.channel},
              );
            },
            child: _buildVideoCard(
              "${featured.title ?? "Video"}",
              "${featured.viewCount} views • ${featured.likeCount} likes",
              isDark,
              featured.thumbnailUrl ?? "",
            ),
          ),
          const Divider(),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Recent Uploads",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...(_con.videos).map((v) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/Player',
                arguments: {'video': v, 'channel': _con.channel},
              );
            },
            child: _buildVideoListItem(
              v.title ?? "",
              "${v.viewCount} views",
              isDark,
              v.thumbnailUrl ?? "",
              40.0,
              40.0,
            ),
          );
        }),
        // _buildVideoListItem("How to build Tese Africa UI", "15K views", isDark),
        // _buildVideoListItem("Flutter & Android 15 testing", "8K views", isDark),
      ],
    );
  }

  Video? getMostViewedVideo() {
    if (_con.videos.isEmpty) return null;

    return _con.videos.reduce(
      (current, next) =>
          (next.viewCount ?? 0) > (current.viewCount ?? 0) ? next : current,
    );
  }

  Widget _buildPlaylistTab(bool isDark) {
    return ListView.builder(
      itemCount: _con.playlists.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/PlaylistVideos',
              arguments: {
                'playlist': _con.playlists[index],
                'channel': _con.channel,
              },
            );
          },
          leading: Container(
            width: 120,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(_con.playlists[index].thumbnailUrl ?? ""),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              alignment: Alignment.center,
              color: Colors.black45,
              child: const Icon(Icons.playlist_play, color: Colors.white),
            ),
          ),
          title: Text(
            _con.playlists[index].title ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "${_con.playlists[index].videoCount} ${_con.playlists[index].isAudio == true ? 'Tracks' : 'Videos'}",
          ),
          trailing: const Icon(Icons.more_vert),
        );
      },
    );
  }

  Widget _buildVideoCard(String title, String meta, bool isDark, String url) {
    return InkWell(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              // color: Colors.transparent,
              child: Stack(
                children: [
                  _buildNetworkImage(
                    url,
                    height: double.infinity,
                    width: double.infinity,
                  ),

                  Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(meta),
            trailing: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoListItem(
    String title,
    String views,
    bool isDark,
    String url,
    height,
    width,
  ) {
    return ListTile(
      leading: _buildNetworkImage(url, height: height, width: width),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(views, style: const TextStyle(fontSize: 12)),
    );
  }
}

// Delegate for the Sticky TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final AnimationController controller;

  const _ShimmerBox({this.width, this.height, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.white10, Colors.white24, Colors.white10]
                  : [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: const [0.1, 0.5, 0.9],
              begin: Alignment(-1.0 + controller.value, -0.3),
              end: Alignment(1.0 + controller.value, 0.3),
            ),
          ),
        );
      },
    );
  }
}
