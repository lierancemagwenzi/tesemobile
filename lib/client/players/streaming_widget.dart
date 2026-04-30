import 'dart:async';
import 'dart:ui';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/events/live_stream_comments.dart';
import 'package:smacredit/client/home/music_home.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/client/payments/widgets/payment_widget.dart';
import 'package:smacredit/client/payments/widgets/qr_code_payment.dart';
import 'package:smacredit/client/players/live_like_button.dart';
import 'package:smacredit/client/players/stream_likes.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class TeseLiveEventScreen extends StatefulWidget {
  final EventModel eventModel;
  final StreamWatchUnlockModel streamUnlockModel;
  const TeseLiveEventScreen({
    Key? key,
    required this.eventModel,
    required this.streamUnlockModel,
  }) : super(key: key);

  @override
  StateMVC<TeseLiveEventScreen> createState() => _TeseLiveEventScreenState();
}

class _TeseLiveEventScreenState extends StateMVC<TeseLiveEventScreen> {
  bool _isFollowing = false;
  late BetterPlayerController _betterPlayerController;

  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;
  Timer? _viewerTimer;

  bool showDetails = true;
  @override
  void initState() {
    super.initState();
    _con.listenForStreamViwers(widget.eventModel.streamId ?? "");
    _startViewerTimer();
    _con.checkCreatorFollow(widget.eventModel.organizer?.id?.toInt() ?? 0);
    // 1. Construct the HLS Playback URL
    // Replace with your dynamic host if needed
    // String playbackUrl =
    //     "https://ams-54-167-81-151.antmedia.cloud:5443/WebRTCAppEE/streams/${widget.eventModel.streamId}.m3u8";

    // 2. Configure the Player
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
          aspectRatio: 9 / 16, // Matches mobile portrait broadcasting
          fit: BoxFit.cover, // Ensures full-screen coverage
          autoPlay: true,
          showPlaceholderUntilPlay: true,

          // Handle the "Offline" or "Loading" states
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: Colors.white70, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    "Waiting for broadcast to start...",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: Colors.red),
                ],
              ),
            );
          },

          // Hide all standard controls for a clean "Live" look
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            enableFullscreen: false,
            enablePlayPause: false,
            enableProgressBar: false,
            enableSkips: false,
            showControlsOnInitialize: false,
          ),
        );

    // 3. Initialize Source
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.streamUnlockModel.playbackUrl ?? "",
      // headers: {"Authorization": "Bearer ${widget.streamUnlockModel.key}"},
      liveStream: true,
      useAsmsSubtitles: false,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 5000,
        maxBufferMs: 15000,
      ),
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    Future.delayed(Duration(seconds: 3), () {
      _betterPlayerController.setupDataSource(dataSource);
    });

    // Force Landscape if needed, or stick to portrait for mobile-first apps
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _startViewerTimer() {
    _viewerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      print("checking viewer count");
      _con.listenForStreamViwers(widget.eventModel.streamId ?? "");
    });
  }

  late ClientUserController _con;

  _TeseLiveEventScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || _isSending) return;

    // 1. Clear the UI immediately for a "snappy" feel
    final String text = _commentController.text.trim();
    final Map<String, dynamic> user = userMap;
    _commentController.clear();

    setState(() {
      _isSending = true;
      // _userIsScrolling = false; // Ensure we snap to the new comment
    });

    try {
      // 2. REMOVE THE 'await' and the '.timeout'
      // By not awaiting, we trigger the write and move to the next line immediately.
      FirebaseFirestore.instance
          .collection('live-events')
          .doc(widget.eventModel.id.toString())
          .collection('comments')
          .add({
            'userName': user['name'] ?? 'Guest',
            'userImage': user['image'] ?? '',
            'userId': user['id'],
            'comment': text,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // 3. Reset the spinner immediately
      // The comment will stay on screen because of the StreamBuilder's local cache.
      if (mounted) {
        setState(() => _isSending = false);
      }
    } catch (e) {
      debugPrint("Local cache error: $e");
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _betterPlayerController.dispose();
    // Reset orientations when leaving the player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _viewerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. VIDEO BACKGROUND (Placeholder)
          SizedBox.expand(
            child: BetterPlayer(controller: _betterPlayerController),
          ),
          Positioned.fill(
            child: IgnorePointer(
              // Crucial: Allows touches to pass through to the video
              child: LikestreamOverlay(
                eventId: widget.eventModel.id.toString(),
              ),
            ),
          ),
          // 2. TOP BAR (Live Status & Controls)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildLiveBadge(),
                      const SizedBox(width: 8),
                      Text(
                        "${_con.viewersModel?.formattedViewers ?? '0'} watching",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const Spacer(),
                      _buildTopIcon(
                        showDetails
                            ? LucideIcons.chevronDown
                            : LucideIcons.chevronUp,
                        onTap: () {
                          setState(() {
                            showDetails = !showDetails;
                          });
                          // Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildTopIcon(
                        LucideIcons.x,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      // const SizedBox(width: 8),
                      // _buildTopIcon(LucideIcons.settings),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. RIGHT SIDEBAR (Interactions)
          if (showDetails)
            Positioned(
              right: 16,
              bottom: 120,
              child: Column(
                children: [
                  LiveLikeButton(
                    eventId: widget.eventModel.id.toString(),
                    userId: currentuser.value.user?.id.toString() ?? '',
                  ),
                  // _buildInteractionBtn(
                  //   LucideIcons.heart,
                  //   "24.8k",
                  //   color: Colors.red,
                  // ),
                  _buildInteractionBtn(LucideIcons.messageCircle, "17"),
                  _buildInteractionBtn(LucideIcons.share2, "Share"),
                  _buildInteractionBtn(
                    LucideIcons.dollarSign,
                    "Tip",
                    isHighlight: true,
                    onTap: () {
                      print("Tip pressed");
                      triggerTipModal();
                    },
                  ),
                  _buildInteractionBtn(
                    _con.isFollowingCreator == true
                        ? LucideIcons.user
                        : LucideIcons.userPlus,
                    _con.isFollowingCreator == true ? "unfollow" : "Follow",
                    onTap: () async {
                      print("tap pressed");
                      if (_con.isFollowingCreator == true) {
                        final bool? resu = await _con.unFollowCreator({
                          "creator_id": widget.eventModel.organizer?.id,
                        });
                        _con.checkCreatorFollow(
                          widget.eventModel.organizer?.id?.toInt() ?? 0,
                        );
                      } else {
                        final bool? resu = await _con.followCreator({
                          "creator_id": widget.eventModel.organizer?.id,
                        });
                        _con.checkCreatorFollow(
                          widget.eventModel.organizer?.id?.toInt() ?? 0,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

          // 4. BOTTOM OVERLAY (Comments & Event Info)
          if (showDetails)
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.75,
                padding: const EdgeInsets.only(bottom: 80, left: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: TeseLiveCommentsOverlay(
                        eventId: widget.eventModel.id.toString(),
                        currentUser: userMap,
                      ),
                    ),
                    // _buildCommentList(),
                    _buildEventCard(),
                  ],
                ),
              ),
            ),

          if (showDetails)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(bottom: 20),
                color: Colors.black.withOpacity(
                  0.5,
                ), // Background for input area only
                child: _buildBottomInput(),
              ),
            ),

          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   width:
          //       MediaQuery.of(context).size.width *
          //       0.85, // Stops it being too wide
          //   height:
          //       MediaQuery.of(context).size.height *
          //       0.45, // Comments take 45% of height
          //   child: TeseLiveCommentsOverlay(
          //     eventId: widget.eventModel.id.toString(),
          //     currentUser: userMap,
          //   ),
          // ),
        ],
      ),
    );
  }

  // --- COMPONENT BUILDERS ---

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        "LIVE",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildTopIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black26,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildInteractionBtn(
    IconData icon,
    String label, {
    Color color = Colors.white,
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          InkWell(
            onTap: onTap == null
                ? null
                : () {
                    print("onTap2 PRESSED");
                    onTap();
                  },
            child: Icon(
              icon,
              color: isHighlight ? const Color(0xFF00D285) : color,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> userMap = {
    'id': '${currentuser.value.user?.id?.toString()}',
    'name':
        '${currentuser.value.user?.fullname ?? ''}', // Full name or Username to display
    'image':
        currentuser.value.user?.selfie ??
        '', // URL to the user's profile picture
  };
  Widget _buildCommentList() {
    return SizedBox(
      height: 180,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCommentItem("Lunga", "tipped \$5", isTip: true),
          _buildCommentItem("Ashley", "Worth every dollar"),
          _buildCommentItem("Simba", "Who else is watching from Joburg?"),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String user, String msg, {bool isTip = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: isTip ? Colors.red.withOpacity(0.3) : Colors.black26,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$user  ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: msg,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: 1 == 1
                      ? buildNetworkImage(
                          widget.eventModel.thumbnail ?? '',
                          isDark: isDark,
                          width: 40,
                          height: 40,
                        )
                      : Image.network(
                          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.eventModel.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${widget.eventModel.organizer?.fullname ?? ''} • Live Event",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_con.isFollowingCreator == true) {
                    final bool? resu = await _con.unFollowCreator({
                      "creator_id": widget.eventModel.organizer?.id,
                    });
                    _con.checkCreatorFollow(
                      widget.eventModel.organizer?.id?.toInt() ?? 0,
                    );
                  } else {
                    final bool? resu = await _con.followCreator({
                      "creator_id": widget.eventModel.organizer?.id,
                    });
                    _con.checkCreatorFollow(
                      widget.eventModel.organizer?.id?.toInt() ?? 0,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing ? Colors.white24 : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _con.isFollowingCreator == true ? "Following" : "+ Subscribe",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextFormField(
                controller: _commentController,
                onFieldSubmitted: (v) {
                  _submitComment();
                },
                decoration: InputDecoration(
                  hintText: "Say something...",

                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          // const SizedBox(width: 12),
          // const Icon(LucideIcons.volume2, color: Colors.white),
          // const SizedBox(width: 12),
          // const Icon(LucideIcons.settings, color: Colors.white),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              _submitComment();
            },
            child: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(LucideIcons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // void _showTipSheet() {
  //   print("show");
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // MUST be true for keyboard shifting
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Padding(
  //       padding: EdgeInsets.only(
  //         bottom: MediaQuery.of(
  //           context,
  //         ).viewInsets.bottom, // Moves sheet up with keyboard
  //       ),
  //       child: _TipSheet(),
  //     ),
  //   );
  // }

  void triggerTipModal() {
    print("!!! MODAL FUNCTION REACHED !!!");
    print("--- INSIDE TRIGGER FUNCTION ---"); // Use a unique string

    if (!mounted) {
      print("Error: Widget is not mounted");
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TipSheet(
        organiser: widget.eventModel.organizer?.fullname ?? 'Organiser',
        eventModel: widget.eventModel,
      ),
    );
  }
}

class TipSheet extends StatefulWidget {
  final String organiser;
  final EventModel eventModel;
  const TipSheet({required this.organiser, required this.eventModel});

  @override
  StateMVC<TipSheet> createState() => _TipSheetState();
}

class _TipSheetState extends StateMVC<TipSheet> {
  final TextEditingController _conroller = TextEditingController();

  late ClientUserController _con;
  Timer? _timer;
  final _formKey = GlobalKey<FormState>();
  _TipSheetState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }
  void _showVideoPurchaseOptions(EventModel video) async {
    // Navigator.pop(context);
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
        "amount": num.tryParse(_conroller.text),
        "currency": video.currency,
        "paymentDescription": "Video Purchase payment",
        "payer": "${currentuser.value.user?.fullname}",
        "user_id": currentuser.value.user?.id,
        "event_id": video.id,
        "payerMobile": result.ecoCashNumber ?? "",
        "is_donation": true,
      };
      PaymentResponseWrapper? res = await _con.buyEvent(map);

      if (res != null) {
        if (result.method.toLowerCase() == 'visa' ||
            result.method.toLowerCase() == 'mastercard') {
          Navigator.pushNamed(
            context,
            '/VisaMastercardPayment',
            arguments:
                res.response?.paymentInitiationResponse?.paymentCode ?? "",
          ).then((e) {
            _con.listenForEvent(widget.eventModel.id);
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            _con.listenForEvent(widget.eventModel.id);
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
      _con.listenForEvent(widget.eventModel.id);
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
      _con.listenForEvent(widget.eventModel.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Send a Tip",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x, color: Colors.white54),
                ),
              ],
            ),
            Text(
              "Support ${widget.organiser} instantly during the live event.",
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                "1",
                "5",
                "10",
                "20",
              ].map((v) => _buildTipOpt(v)).toList(),
            ),
            const SizedBox(height: 16),
            _buildCustomAmount(),
            const SizedBox(height: 24),
            // const Text(
            //   "Payment Method",
            //   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 12),
            // Row(
            //   children: [
            //     _buildMethodChip("Wallet", true),
            //     _buildMethodChip("Card", false),
            //     _buildMethodChip("Mobile Money", false),
            //   ],
            // ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (num.tryParse(_conroller.text) == null) {
                    return;
                  }
                  if (_formKey.currentState!.validate()) {
                    // SUCCESS: Proceed to payment logic
                    _showVideoPurchaseOptions(widget.eventModel);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Send ${widget.eventModel.currency} ${_conroller.text}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipOpt(String label) {
    bool isSelected = label == _conroller.text;
    return InkWell(
      onTap: () {
        _conroller.text = label;
        setState(() {});
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.1) : Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }

    // Convert string to double safely
    final amount = double.tryParse(value);

    if (amount == null) {
      return 'Enter a valid number';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    // Optional: Limit maximum tip for security
    if (amount > 10000) {
      return 'Maximum tip is 10,000';
    }

    return null; // Return null if the input is valid
  }

  Widget _buildCustomAmount() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
          controller: _conroller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: _validateAmount,
          onChanged: (v) {
            setState(() {});
          },
          inputFormatters: [
            // Allow digits and only ONE decimal point
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: "Custom amount",
            hintStyle: TextStyle(color: Colors.white24),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMethodChip(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.red.withOpacity(0.1) : Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? Colors.red : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.red : Colors.white70,
          fontSize: 12,
        ),
      ),
    );
  }
}
