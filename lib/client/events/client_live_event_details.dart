import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/events/live_stream_comments.dart';
import 'package:smacredit/client/payments/models/payment.dart';
import 'package:smacredit/client/payments/models/payment_response.dart';
import 'package:smacredit/client/payments/widgets/payment_form.dart';
import 'package:smacredit/client/payments/widgets/payment_widget.dart';
import 'package:smacredit/client/payments/widgets/qr_code_payment.dart';
import 'package:smacredit/client/players/live_event_player.dart';
import 'package:smacredit/client/players/streaming_widget.dart';
import 'package:smacredit/src/content-creator/events/models/event_model.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class ClientEventDetailsScreen extends StatefulWidget {
  final EventModel event;
  const ClientEventDetailsScreen({super.key, required this.event});

  @override
  StateMVC<ClientEventDetailsScreen> createState() =>
      _ClientEventDetailsScreenState();
}

class _ClientEventDetailsScreenState
    extends StateMVC<ClientEventDetailsScreen> {
  late ClientUserController _con;
  Timer? _timer;

  _ClientEventDetailsScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    super.initState();

    _con.listenForEvent(widget.event.id);
    // Refresh countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getRemainingTime() {
    final diff = _con.eventModel!.startDate.difference(DateTime.now());
    if (diff.isNegative) return "00:00:00";

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(diff.inHours);
    final minutes = twoDigits(diff.inMinutes.remainder(60));
    final seconds = twoDigits(diff.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  void _showVideoPurchaseOptions(EventModel video) async {
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
        "amount": video.price,
        "currency": video.currency,
        "paymentDescription": "Video Purchase payment",
        "payer": "${currentuser.value.user?.fullname}",
        "user_id": currentuser.value.user?.id,
        "event_id": video.id,
        "payerMobile": result.ecoCashNumber ?? "",
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
            _con.listenForEvent(widget.event.id);
          });
        } else if (result.method.toLowerCase() == 'ecocash') {
          Navigator.pushNamed(
            context,
            '/PaymentWaitingScreen',
            arguments: result.ecoCashNumber,
          ).then((e) {
            _con.listenForEvent(widget.event.id);
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

  void _handleJoinRequest() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from clicking away
      builder: (context) => TeseTimerDialog(
        seconds: 5,
        onTimerComplete: () {
          // This is your callback action
          _navigateToLiveStream();
        },
      ),
    );
  }

  Future<void> _navigateToLiveStream() async {
    // Your logic to launch BetterPlayer or AntMedia view
    print("Timer finished! Launching stream...");
    StreamWatchUnlockModel? details = await _con.joinStream({
      "stream_id": widget.event.id,
    });

    if (details != null) {
      if (details.valid == true) {
        if (1 == 1) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => TeseLiveEventScreen(
                eventModel: _con.eventModel!,
                streamUnlockModel: details!,
              ),
            ),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => TeseStreamViewer(
              eventModel: _con.eventModel!,
              streamUnlockModel: details!,
            ),
          ),
        );
      } else {
        CustomMessageHandler().showErrorSnakeBar(
          context,
          details.message ?? "",
        );
      }
    } else {
      CustomMessageHandler().showErrorSnakeBar(
        context,
        "Something went wrong.Try again",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color teseGreen = Color(0xFF00D285);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: _con.eventModel == null
            ? EventDetailsLoadingWidget()
            : CustomScrollView(
                slivers: [
                  // 1. IMMERSIVE HEADER
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _con.eventModel?.thumbnail ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                Container(color: Colors.grey[900]),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. CONTENT
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TITLE & ORGANIZER
                          Text(
                            _con.eventModel!.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildOrganizerRow(teseGreen),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(color: Colors.white10),
                          ),

                          // 3. LARGE CENTERED COUNTDOWN (If Upcoming)
                          if (_con.eventModel!.isUpcoming) ...[
                            const Center(
                              child: Text(
                                "STARTS IN",
                                style: TextStyle(
                                  color: Colors.grey,
                                  letterSpacing: 2,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                _getRemainingTime(),
                                style: const TextStyle(
                                  fontSize: 54,
                                  fontWeight: FontWeight.w200,
                                  fontFamily: 'Courier',
                                ), // Monospace vibe
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],

                          // 4. EVENT DETAILS GRID
                          _buildDetailGrid(),

                          const SizedBox(height: 40),

                          // 5. STATUS & ACTION BUTTON
                          _buildActionButton(teseGreen),

                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOrganizerRow(Color teseGreen) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: teseGreen.withOpacity(0.1),
          child: const Icon(LucideIcons.user, color: Colors.grey, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _con.eventModel?.organizer?.fullname ?? "Tese Creator",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              "Organizer",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailGrid() {
    return Column(
      children: [
        _detailItem(
          LucideIcons.calendar,
          "Date",
          DateFormat('EEEE, MMM dd').format(_con.eventModel!.startDate),
        ),
        _detailItem(
          LucideIcons.clock,
          "Schedule",
          "${DateFormat('HH:mm').format(_con.eventModel!.startDate)} - ${DateFormat('HH:mm').format(_con.eventModel!.endDate)}",
        ),
        _detailItem(
          LucideIcons.info,
          "Status",
          _con.eventModel!.hasPurchased ? "Ticket Purchased" : "Not Purchased",
        ),
      ],
    );
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
      _con.listenForEvent(widget.event.id);
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
      _con.listenForEvent(widget.event.id);
    });
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF00D285)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Color teseGreen) {
    bool hasPurchased = _con.eventModel!.hasPurchased;
    bool canJoin =
        _con.eventModel!.canJoin; // Assumes your model handles this logic

    if (hasPurchased) {
      if (canJoin) {
        return _largeButton(
          "JOIN LIVE STREAM",
          teseGreen,
          LucideIcons.playCircle,
          onPressed: () async {
            _handleJoinRequest();
            return;
          },
        );
      } else {
        return _largeButton(
          "YOU'RE REGISTERED",
          Colors.white12,
          LucideIcons.checkCircle,
          isEnabled: false,
          onPressed: () {},
        );
      }
    } else {
      return _largeButton(
        "GET TICKET - ${_con.eventModel?.currency} ${_con.eventModel?.price}",
        teseGreen,
        LucideIcons.ticket,
        onPressed: () {
          _showVideoPurchaseOptions(_con.eventModel!);
        },
      );
    }
  }

  Widget _largeButton(
    String label,
    Color color,
    IconData icon, {
    bool isEnabled = true,

    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon, color: isEnabled ? Colors.black : Colors.white24),
        label: Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.black : Colors.white24,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}

class EventDetailsLoadingWidget extends StatelessWidget {
  const EventDetailsLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color baseColor = isDark ? Colors.grey[900]! : Colors.grey[300]!;
    final Color highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER SKELETON
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.white,
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. TITLE SKELETON
                    Container(
                      height: 32,
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. ORGANIZER ROW SKELETON
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Container(height: 14, width: 100, color: Colors.white),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // 4. COUNTDOWN SKELETON
                    Center(
                      child: Container(
                        height: 60,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 5. INFO GRID SKELETONS
                    _buildSkeletonItem(),
                    _buildSkeletonItem(),
                    _buildSkeletonItem(),

                    const SizedBox(height: 40),

                    // 6. BUTTON SKELETON
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(height: 20, width: 20, color: Colors.white),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 10, width: 40, color: Colors.white),
              const SizedBox(height: 8),
              Container(height: 14, width: 120, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}

class TeseTimerDialog extends StatefulWidget {
  final VoidCallback onTimerComplete;
  final int seconds;

  const TeseTimerDialog({
    super.key,
    required this.onTimerComplete,
    this.seconds = 30,
  });

  @override
  State<TeseTimerDialog> createState() => _TeseTimerDialogState();
}

class _TeseTimerDialogState extends State<TeseTimerDialog> {
  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.seconds;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        Navigator.of(context).pop(); // Close dialog
        widget.onTimerComplete(); // Trigger the callback
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tese Africa Branding Colors (Example: Deep Orange/Gold/Black)
    const teseOrange = Color(0xFFFF5722);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sensors, size: 50, color: teseOrange),
            const SizedBox(height: 16),
            const Text(
              "Preparing Your Stream",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Waking up the server for the best quality experience...",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _timeLeft / widget.seconds,
                    strokeWidth: 8,
                    valueColor: const AlwaysStoppedAnimation<Color>(teseOrange),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                Text(
                  "$_timeLeft",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _getMessage(_timeLeft),
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: teseOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMessage(int time) {
    if (time > 20) return "Igniting engines...";
    if (time > 10) return "Connecting to Johannesburg hub...";
    return "Finalizing security...";
  }
}
