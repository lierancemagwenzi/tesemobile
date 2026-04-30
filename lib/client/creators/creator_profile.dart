import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/client/payments/widgets/payment_widget.dart';
import 'package:smacredit/client/payments/widgets/qr_code_payment.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';

class CreatorProfileScreen extends StatefulWidget {
  final User user;
  const CreatorProfileScreen({super.key, required this.user});

  @override
  StateMVC<CreatorProfileScreen> createState() => _CreatorProfileScreenState();
}

class _CreatorProfileScreenState extends StateMVC<CreatorProfileScreen> {
  late ClientUserController _con;

  _CreatorProfileScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForCreatorChannels(widget.user.id ?? 0);
    _con.checkCreatorFollow(widget.user.id!);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      bottomNavigationBar: SafeArea(child: _buildViewLinksButton(context)),

      body: CustomScrollView(
        slivers: [
          // 1. COLLAPSING BANNER & AVATAR
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Banner Image
                  _buildNetworkImage(
                    widget.user.banner ?? "",
                    height: 200,
                    isDark: isDark,
                  ),
                  // Overlapping Profile Image
                  Positioned(
                    bottom: -40,
                    left: 20,
                    child: _buildProfileImage(isDark),
                  ),
                ],
              ),
            ),
          ),

          // 2. CREATOR INFO & STATS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.user.fullname,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      if (_con.isFollowingCreator != null)
                        ElevatedButton(
                          onPressed: () async {
                            if (_con.isFollowingCreator == true) {
                              final bool? resu = await _con.unFollowCreator({
                                "creator_id": widget.user.id,
                              });
                              _con.checkCreatorFollow(widget.user.id ?? 0);
                              if (resu == true) {
                                CustomMessageHandler().showSuccessSnakeBar(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  "Unfollowed",
                                );
                              } else {
                                CustomMessageHandler().showErrorSnakeBar(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  "Something went wrong",
                                );
                              }
                            } else {
                              final bool? resu = await _con.followCreator({
                                "creator_id": widget.user.id,
                              });
                              _con.checkCreatorFollow(widget.user.id ?? 0);
                              if (resu == true) {
                                CustomMessageHandler().showSuccessSnakeBar(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  "followed",
                                );
                              } else {
                                CustomMessageHandler().showErrorSnakeBar(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  "Something went wrong",
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _con.isFollowingCreator == true
                                ? Colors.red
                                : Colors.green,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            _con.isFollowingCreator == true
                                ? 'unfollow'
                                : 'Follow',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    widget.user.description ?? "",
                    style: TextStyle(fontSize: 16, color: subTextColor),
                  ),
                  const SizedBox(height: 20),
                  // Stats Row
                  Row(
                    children: [
                      _buildStatColumn(
                        UtilsHelper.formatNumber(
                          widget.user.followerCount ?? 0,
                        ),
                        "Followers",
                        textColor,
                        subTextColor,
                      ),
                      const SizedBox(width: 40),
                      _buildStatColumn(
                        UtilsHelper.formatNumber(widget.user.videoCount ?? 0),
                        "Videos",
                        textColor,
                        subTextColor,
                      ),
                      const SizedBox(width: 40),
                      _buildStatColumn(
                        UtilsHelper.formatNumber(widget.user.channelCount ?? 0),
                        "Channels",
                        textColor,
                        subTextColor,
                      ),
                    ],
                  ),

                  // InkWell(
                  //   onTap: () {
                  //     Navigator.pushNamed(
                  //       context,
                  //       '/CreatorPaymentLinks',
                  //       arguments: widget.user,
                  //     );
                  //   },
                  //   child: Text(
                  //     "Payment links",
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
                  // SizedBox(height: 30),
                  // _buildViewLinksButton(context),
                  const SizedBox(height: 30),
                  Text(
                    'Channels',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // 3. CHANNEL LIST
          _con.channels.isEmpty
              ? SliverToBoxAdapter(child: TeseEmptyWidget())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildChannelCard(
                      context,
                      isDark,
                      textColor,
                      subTextColor,
                      _con.channels[index],
                    ),
                    childCount: _con.channels.length, // Matches image
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildViewLinksButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Tese Africa Branding Colors
    const Color teseGreen = Color(0xFF1B5E20);
    const Color teseLightGreen = Color(0xFF52B681);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          // Gradient only applied in Light Mode for depth; solid deep color for Dark Mode
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [teseGreen, teseLightGreen],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: isDark ? teseGreen : null,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: teseGreen.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/CreatorPaymentLinks',
              arguments: widget.user,
            );
          },
          icon: const Icon(Icons.link_rounded, color: Colors.white),
          label: const Text(
            "VIEW PAYMENT LINKS",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 15,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  // CHANNEL CARD COMPONENT
  Widget _buildChannelCard(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subTextColor,
    Channel channel,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/CreatorChannelView', arguments: channel);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Channel Thumbnail
                _buildNetworkImage(
                  channel.coverImageUrl ?? "",
                  width: 100,
                  height: 100,
                  borderRadius: BorderRadius.circular(15),
                  isDark: isDark,
                ),
                const SizedBox(width: 15),
                // Channel Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildIconText(
                        Icons.playlist_play,
                        "${UtilsHelper.formatNumber(channel.playlistCount ?? 0)} Playlists",
                        subTextColor,
                      ),
                      _buildIconText(
                        Icons.play_arrow_outlined,
                        "${UtilsHelper.formatNumber(channel.videoCount ?? 0)} Videos",
                        subTextColor,
                      ),
                    ],
                  ),
                ),

                // Subscribe Button
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (channel.shouldShowButton['status'] == 'not_subscribed') {
                  UtilsHelper.ensureAuth(
                    context,
                    action: "to subscribe to channel",
                    onAuthenticated: () {
                      _showPurchaseOptions(channel);
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: channel.shouldShowButton['positive'] == true
                    ? Colors.green
                    : const Color(0xFFFF3B30), // Tese Red
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                channel.shouldShowButton['message'],
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PROFILE AVATAR WITH VERIFIED BADGE
  Widget _buildProfileImage(bool isDark) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            shape: BoxShape.circle,
          ),
          child: _buildNetworkImage(
            widget.user.selfie ?? "",
            height: 100,
            width: 100,
            isCircle: true,
            isDark: isDark,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 4, bottom: 4),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF00D285), // Tese Green
            child: Icon(Icons.check, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }

  // GLOBAL IMAGE HANDLER WITH SHIMMER
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

  Widget _buildStatColumn(
    String value,
    String label,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: subTextColor)),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(color: color, fontSize: 13)),
        ],
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
      _con.listenForCreatorChannels(widget.user.id ?? 0);
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
      _con.listenForCreatorChannels(widget.user.id ?? 0);
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
      if (kDebugMode) {
        print("Selected: ${result.method}");
      }
      if (result.ecoCashNumber != null) {
        if (kDebugMode) {
          print("EcoCash Number: ${result.ecoCashNumber}");
        }
      }

      Map map = {
        "wallet": result.method,
        "amount": video.subscriptionPrice ?? 1,
        "currency": "USD",
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
            _con.listenForCreatorChannels(widget.user.id ?? 0);
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            _con.listenForCreatorChannels(widget.user.id ?? 0);
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
