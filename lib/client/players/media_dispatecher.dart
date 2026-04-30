import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/playlist.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/models/media_response.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/client/payments/widgets/payment_widget.dart';
import 'package:smacredit/client/payments/widgets/qr_code_payment.dart';
import 'package:smacredit/client/players/custom_dialog.dart';
import 'package:smacredit/client/players/media_loader.dart';
import 'package:smacredit/client/players/premium_widget.dart';
import 'package:smacredit/client/players/tese_audio_player.dart';
import 'package:smacredit/client/players/video_player_widget.dart';
import 'package:smacredit/main.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/utils/xhelper.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaDispatcherScreen extends StatefulWidget {
  final Video video;
  const MediaDispatcherScreen({super.key, required this.video});

  @override
  StateMVC<MediaDispatcherScreen> createState() =>
      _MediaDispatcherScreenState();
}

class _MediaDispatcherScreenState extends StateMVC<MediaDispatcherScreen> {
  MediaResponse? media;
  bool hasFetched = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMedia();
  }

  late ClientUserController _con;

  _MediaDispatcherScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  getMedia() async {
    MediaResponse? mediaa = await _con.getMedia(widget.video.id);
    setState(() {
      hasFetched = true;
      media = mediaa;
    });
    if (mediaa != null) {
      if (mediaa.hasAccess) {
        if (mediaa.video.rating?.triggerWarning == true) {
          bool? proceed = await showAdultContentWarning(
            context: context,
            imageUrl: mediaa.video.rating?.icon ?? "",
            message: mediaa.video.rating?.message ?? "",
          );

          if (proceed != true) {
            // User declined or backed out
            Navigator.of(context).pop();
            return;
          } else {
            _navigate();
          }
        } else {
          _navigate();
        }
      } else {}
    } else {}
  }

  _navigate() {
    if (widget.video.isAudio == true) {
      _goToAudioPlayer();
    } else {
      _goToVideoPlayer();
    }
  }

  void _showVideoPurchaseOptions(Video video) async {
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
        "amount": video.price ?? 1,
        "currency": video.currency,
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
            getMedia();
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            getMedia();
          });
        } else if (result.method.toLowerCase() == 'zimswitch') {
          handleWebForm(res, isChannel: false);
        } else if (result.method.toLowerCase() == 'innbucks') {
          handleQRCode(res, isChannel: false);
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

  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse(_con.defaultLinkModel?.shortLink ?? '');
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $_url');
    }
  }

  String getPurchaseAmount(String? accessReason) {
    switch (accessReason) {
      case 'LOCKED_PREMIUM_VIDEO':
        return "${media?.video.currency}${(media?.video.price ?? 0).toStringAsFixed(2)}";

      case 'LOCKED_CHANNEL_SUBSCRIPTION_REQUIRED':
        return "${media?.channel.subscriptionCurrency}${(media?.channel.subscriptionPrice ?? 0).toStringAsFixed(2)}";

      case 'LOCKED_PLAYLIST_PURCHASE_REQUIRED':
        return "${media?.playlist.currency}${(media?.playlist.price ?? 0).toStringAsFixed(2)}";

      // case 'LOCKED_RESTRICTED':
      // case 'LOCKED_UNKNOWN':
      //   return "Access Restricted";

      default:
        return "USD0";
    }
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
            _con.listenForChannel(widget.video.channelId ?? 0);

            getMedia();
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            _con.listenForChannel(widget.video.channelId ?? 0);
            getMedia();
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

  handleWebForm(PaymentResponseWrapper payment, {bool isChannel = true}) {
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
      if (isChannel) {
        _con.listenForChannel(widget.video.channelId ?? 0);
        getMedia();
      } else {
        getMedia();
      }
    });
  }

  handleQRCode(PaymentResponseWrapper payment, {bool isChannel = true}) {
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
      if (isChannel) {
        _con.listenForChannel(widget.video.channelId ?? 0);
        getMedia();
      } else {
        getMedia();
      }
    });
  }

  void openCustomDialog(BuildContext context) {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            opaque: false, // This is the secret sauce for the blur effect
            barrierDismissible: true,
            pageBuilder: (context, _, __) => GlassOverlayDialog(
              child: PlayListVideosWidget(
                playlist: media!.playlist,
                hideMedia: true,
              ), // Pass any widget here (Earnings, Reports, etc.)
            ),
          ),
        )
        .then((value) {
          getMedia();
        });
  }

  void getAccess(String? accessReason) {
    if (accessReason == "LOCKED_PREMIUM_VIDEO") {
      UtilsHelper.ensureAuth(
        context,
        action: "to purchase the video",
        onAuthenticated: () {
          _showVideoPurchaseOptions(widget.video);
        },
      );
    } else if (accessReason == "LOCKED_CHANNEL_SUBSCRIPTION_REQUIRED") {
      UtilsHelper.ensureAuth(
        context,
        action: "to purchase the video",
        onAuthenticated: () {
          _showPurchaseOptions(media!.channel);
        },
      );
    } else if (accessReason == "LOCKED_PLAYLIST_PURCHASE_REQUIRED") {
      openCustomDialog(context);
    } else {}
  }

  void _goToVideoPlayer() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TeseVideoPlayerWidget(video: widget.video, media: media!),
      ),
    );
  }

  void _goToAudioPlayer() {
    if (kDebugMode) {
      print("going to player");
    }
    try {
      // teseAudioHandler.prepareMedia(widget.video, media!);
      teseAudioHandler.stop();
      teseAudioHandler.setVideo(media!.video, [media!.video]);

      Navigator.pushReplacementNamed(
        context,
        '/TeseAudoPlayer',
        // arguments: {
        //   'ads': media?.ads ?? [],
        //   'video': widget.video,
        //   "videos": [widget.video],
        // },
      );
    } catch (e, c) {
      if (kDebugMode) {
        print(c);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !hasFetched || media == null
          ? TeseMediaLoader(
              onExit: () {
                Navigator.pop(context);
              },
            )
          : hasFetched && media != null && media?.hasAccess != true
          ? TesePremiumPaywall(
              onExit: () {
                Navigator.pop(context);
              },
              reason: media?.accessReason ?? "",
              hasTrailer: widget.video.trailer != null,

              watchTrailer: () {
                Navigator.pushNamed(
                  context,
                  '/VideoTrailer',
                  arguments: {'video': widget.video},
                );
              },
              onPurchase: () {
                getAccess(media?.accessReason ?? "-");
              },

              videoTitle: widget.video.title ?? "",
              price: getPurchaseAmount(media?.accessReason ?? "-"),
              currency: widget.video.currency ?? "USD",
              thumbnailUrl: widget.video.thumbnailUrl ?? "",
            )
          : TeseMediaLoader(
              onExit: () {
                Navigator.pop(context);
              },
            ),
    );
  }

  Future<bool?> showAdultContentWarning({
    required BuildContext context,
    required String message,
    required String imageUrl,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color teseGreen = const Color(0xFF00D285);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Force a choice
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Premium blur effect
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. The Icon/Image from URL
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: teseGreen.withOpacity(0.1),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (context, url, error) => Icon(
                        Icons.warning_amber_rounded,
                        size: 40,
                        color: teseGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. The Warning Title
                const Text(
                  "Adult Content Warning",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 12),

                // 3. The Custom Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text(
                          "Go Back",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: teseGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Continue"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
