import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientPaymentLinkDetailsWidget extends StatefulWidget {
  const ClientPaymentLinkDetailsWidget({
    super.key,
    required this.isNew,
    required this.paymentLink,
  });

  final PaymentLinkModel paymentLink;
  final bool isNew;

  @override
  StateMVC<ClientPaymentLinkDetailsWidget> createState() =>
      _ClientPaymentLinkDetailsWidgetState();
}

class _ClientPaymentLinkDetailsWidgetState
    extends StateMVC<ClientPaymentLinkDetailsWidget> {
  late PaymentController _con;

  // Custom Tese Palette (In case not fully defined in theme)
  static const Color teseGreen = Color(0xFF1B5E20);
  static const Color teseGold = Color(0xFFFFD700);

  _ClientPaymentLinkDetailsWidgetState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }

  @override
  void initState() {
    super.initState();
    _con.generateShotLink({
      "user_id": currentuser.value.user?.id,
      'username': currentuser.value.user?.username,
      'original_link': widget.paymentLink.paymentLinkShortUrl,
    });
  }

  final GlobalKey qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Link Details",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: BackButton(color: isDark ? Colors.white : Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 1. Success Indicator
                _buildSuccessHeader(isDark),

                const SizedBox(height: 30),

                // 2. The Details Card (Themed)
                _buildDetailsCard(theme, isDark),

                const SizedBox(height: 30),

                if (_con.shortLinkModel != null) ...[
                  // 3. QR & Link Section
                  _buildPaymentLinkField(theme, isDark),

                  const SizedBox(height: 20),

                  const Text(
                    'Scan QR to Pay',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  _buildQrCode(isDark),

                  const SizedBox(height: 20),

                  // Share Button
                  IconButton(
                    icon: Icon(
                      Icons.share_rounded,
                      color: isDark ? teseGold : teseGreen,
                      size: 32,
                    ),
                    onPressed: () =>
                        sharePaymentLink(_con.shortLinkModel?.shortLink ?? ''),
                  ),
                ],

                const SizedBox(height: 40),
                if (_con.shortLinkModel != null)
                  _buildActionButtons(context, isDark),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sharePaymentLink(String paymentLinkUrl) {
    // 1. Construct the message and URL
    String subject = "Payment Link from [Your Company Name]";
    String text =
        "Please use this link to complete your payment: $paymentLinkUrl";

    // 2. Call the static share method
    SharePlus.instance.share(
      ShareParams(text: 'check out my payment link $paymentLinkUrl'),
    );
  }

  Widget _buildSuccessHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: teseGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 60,
            color: teseGreen,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.isNew ? 'Link Created!' : 'Payment Link',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          widget.paymentLink.paymentProfileName,
          style: const TextStyle(color: teseGreen, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Email', widget.paymentLink.paymentLinkEmail, isDark),
          _buildDetailRow(
            'Currency',
            widget.paymentLink.paymentLinkCurrency,
            isDark,
          ),
          _buildDetailRow(
            'Amount',
            "${widget.paymentLink.paymentLinkCurrency} ${widget.paymentLink.paymentLinkAmount?.toStringAsFixed(2)}",
            isDark,
          ),
          _buildDetailRow(
            'Reference',
            widget.paymentLink.paymentLinkReference,
            isDark,
          ),
          _buildDetailRow('Type', widget.paymentLink.title, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _copyTextToClipboard(String text, BuildContext context) {
    // 1. Copy the text to the system clipboard
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      // 2. Provide visual feedback using a Tese-branded SnackBar
      if (context.mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Link copied to clipboard',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1B5E20), // Tese Green
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: "OK",
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }

  Widget _buildPaymentLinkField(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              _con.shortLinkModel?.shortLink ?? '',
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () => _copyTextToClipboard(
              _con.shortLinkModel?.shortLink ?? '-',
              context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCode(bool isDark) {
    return RepaintBoundary(
      key: qrKey,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // QR codes always need high contrast
          borderRadius: BorderRadius.circular(12),
        ),
        child: QrImageView(
          data: _con.shortLinkModel?.shortLink ?? '-',
          version: QrVersions.auto,
          size: 180.0,
          gapless: true,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: teseGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => launchInInternalBrowser(
              context,
              widget.paymentLink.paymentLinkUrl,
            ),
            child: const Text(
              "MAKE PAYMENT",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Close Details",
            style: TextStyle(color: isDark ? teseGold : teseGreen),
          ),
        ),
      ],
    );
  }

  Future<void> launchInInternalBrowser(
    BuildContext context,
    String urlString,
  ) async {
    final Uri url = Uri.parse(urlString);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    try {
      // 1. Check if the URL is valid and can be launched
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          // mode: LaunchMode.inAppWebView opens it inside the app
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
          // Customizing the browser toolbar to match Tese Branding
          browserConfiguration: BrowserConfiguration(
            showTitle: true,
            // Dark mode or Tese Green toolbar
            // toolbarColor: isDark
            //     ? const Color(0xFF0D1117)
            //     : const Color(0xFF1B5E20),
          ),
        );
      } else {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      // 2. Fallback using your CustomMessageHandler or a SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open the payment link. Please try again."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
