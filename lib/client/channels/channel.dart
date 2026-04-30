import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/channels/error.dart';
import 'package:smacredit/client/channels/loading_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/client/payments/widgets/payment_widget.dart';
import 'package:smacredit/client/payments/widgets/qr_code_payment.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class ClientChannelPlaylistsWidget extends StatefulWidget {
  final Channel channel;
  const ClientChannelPlaylistsWidget({super.key, required this.channel});

  @override
  StateMVC<ClientChannelPlaylistsWidget> createState() =>
      _ClientChannelPlaylistsWidgetState();
}

class _ClientChannelPlaylistsWidgetState
    extends StateMVC<ClientChannelPlaylistsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  late ClientUserController _con;

  _ClientChannelPlaylistsWidgetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));

    _con.listenForChannelPlaylists(widget.channel.id);
    _con.listenForChannel(widget.channel.id);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect if the system/app is in dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
        appBar: _con.channel == null
            ? AppBar(
                backgroundColor: isDarkMode
                    ? const Color(0xFF121212)
                    : Colors.white,

                title: Text(
                  "Channel",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              )
            : null,
        body: _con.channel == null && _con.loadingStus == LoadingStus.failed
            ? Center(
                child: TeseErrorWidget(
                  onRetry: () {
                    _con.listenForChannel(widget.channel.id);
                  },
                ),
              )
            : _con.loadingStus == LoadingStus.pending ||
                  _con.loadingStus == LoadingStus.loading
            ? TeseShimmer(child: Center(child: Text("Loading")))
            : CustomScrollView(
                slivers: [
                  // 1. Header with Cover
                  SliverAppBar(
                    expandedHeight: 320.0,
                    pinned: true,
                    backgroundColor: Colors.black,
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildNetworkImage(
                            _con.channel?.coverImageUrl ?? "-",
                          ),
                          // Play Button Overlay
                          // Center(
                          //   child: Container(
                          //     padding: const EdgeInsets.all(12),
                          //     decoration: BoxDecoration(
                          //       color: Colors.black38,
                          //       shape: BoxShape.circle,
                          //       border: Border.all(
                          //         color: Colors.white,
                          //         width: 2,
                          //       ),
                          //     ),
                          //     child: const Icon(
                          //       Icons.play_arrow,
                          //       color: Colors.white,
                          //       size: 40,
                          //     ),
                          //   ),
                          // ),
                          // Bottom Gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildHeaderContent(),
                    ),
                  ),

                  // 2. Stats Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            UtilsHelper.formatNumber(
                              _con.channel?.playlistCount ?? 0,
                            ),
                            'Playlists',
                            isDarkMode,
                          ),
                          Container(
                            width: 1,
                            height: 30,
                            color: isDarkMode
                                ? Colors.white24
                                : Colors.grey[300],
                          ),
                          _buildStatItem(
                            UtilsHelper.formatNumber(
                              _con.channel?.videoCount ?? 0,
                            ),
                            'Videos',
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Playlists Heading
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        'Playlists',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // 4. List of Playlists
                  _con.playlists.isEmpty
                      ? SliverToBoxAdapter(child: TeseEmptyWidget())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildPlaylistListItem(
                              isDarkMode,
                              _con.playlists[index],
                            ),
                            childCount: _con.playlists.length,
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    // Remove Positioned! Just return the Column.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_con.channel?.subscriptionEnabled == true)
              Text(
                "${_con.channel?.subscriptionCurrency ?? 'USD'} ${(_con.channel?.subscriptionPrice ?? 0).toStringAsFixed(2)}",
                style: TextStyle(
                  color: Colors
                      .white, // Note: This might be invisible on light theme now
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              SizedBox(height: 0),

            IconButton(
              icon: Icon(
                _con.channel?.liked == true
                    ? Icons.favorite
                    : Icons.favorite_outline, // or Icons.info_outline
                color: Color(0xFF00D285), // Tese Green
                size: 24,
              ),
              tooltip: "Like channel",
              onPressed: () async {
                await _con
                    .likeChannel({
                      "channel_id": widget.channel.id,
                    }, _con.channel?.liked == true ? false : true)
                    .then((_) {
                      _con.listenForChannel(widget.channel.id);
                    });
              },
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(
                _con.channel?.logoUrl ?? "",
                headers: {'Cookie': cloudFrontCookieNotifier.value},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _con.channel?.name ?? "",
                style: const TextStyle(fontSize: 16), // Removed hardcoded white
              ),
            ),
            _buildSubscribeButton(_con.channel!),
          ],
        ),
        const SizedBox(height: 8),
        Text(_con.channel?.description ?? ""),
      ],
    );
  }

  Widget _buildHeaderContent1() {
    return Positioned(
      left: 20,
      bottom: 25,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Channel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(_con.channel?.logoUrl ?? ""),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _con.channel?.name ?? "",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              _buildSubscribeButton(_con.channel!),
            ],
          ),
          SizedBox(height: 8),
          Text(_con.channel?.description ?? ""),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(Channel channel) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: channel.shouldShowButton['positive'] == true
              ? [Colors.green, Colors.green]
              : [Color(0xFFFF416C), Color(0xFFFF4B2B)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: () {
          if (channel.shouldShowButton['status'] == 'not_subscribed') {
            UtilsHelper.ensureAuth(
              context,
              action: "to subscribe to channel",
              onAuthenticated: () {
                _showPurchaseOptions(channel);
              },
            );
            // _showPurchaseOptions(channel);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          channel.shouldShowButton['message'],
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label, bool isDark) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }

  Widget _buildPlaylistListItem(bool isDark, Playlist playlist) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/PlaylistVideos',
          arguments: {'playlist': playlist, 'channel': _con.channel},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                _buildNetworkImage(
                  playlist.thumbnailUrl ?? "",
                  width: 90,
                  height: 90,
                  radius: 10,
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.playlist_play,
                          color: Colors.white,
                          size: 14,
                        ),
                        Text(
                          ' ${playlist.videoCount}',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${playlist.title ?? ""}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    playlist.description ?? '',
                    maxLines: 2,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${playlist.videoCount} videos',
                    style: TextStyle(
                      color: Color(0xFFFF4B2B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              httpHeaders: {'Cookie': cloudFrontCookieNotifier.value},

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
