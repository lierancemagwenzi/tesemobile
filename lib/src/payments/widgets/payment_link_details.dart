import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/payments/controller/payment_controller.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

// --- Data Model for Displaying Payment Link Details ---
class PaymentLinkDetails {
  final String name;
  final String date;
  final String email;
  final String address;
  final String telephone;
  final String currency;
  final String reference;
  final String paymentLinkUrl;

  const PaymentLinkDetails({
    required this.name,
    required this.date,
    required this.email,
    required this.address,
    required this.telephone,
    required this.currency,
    required this.reference,
    required this.paymentLinkUrl,
  });
}

// --- Payment Link Success Screen Widget ---

class PaymentLinkSuccessScreen extends StatefulWidget {
  const PaymentLinkSuccessScreen({
    super.key,
    required this.isNew,
    required this.paymentLink,
  });

  final PaymentLinkModel paymentLink;
  final bool isNew;

  @override
  StateMVC<PaymentLinkSuccessScreen> createState() =>
      _PaymentLinkSuccessScreenState();
}

class _PaymentLinkSuccessScreenState
    extends StateMVC<PaymentLinkSuccessScreen> {
  late PaymentController _con;

  _PaymentLinkSuccessScreenState() : super(PaymentController()) {
    _con = controller as PaymentController;
  }

  PaymentLinkDetails get details {
    return PaymentLinkDetails(
      name: widget.paymentLink.paymentProfileName,
      date: '2025-11-17',
      email: widget.paymentLink.paymentLinkEmail,
      address: '4056 4th street Madokero',
      telephone: widget.paymentLink.paymentLinkToken,
      currency: widget.paymentLink.paymentLinkCurrency,
      reference: widget.paymentLink.paymentLinkReference,
      paymentLinkUrl: widget.paymentLink.paymentLinkShortUrl,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
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
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // 1. Success Message
                Text(
                  widget.isNew
                      ? 'Payment Link Created Successfully!'
                      : 'Payment Link',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Large Checkmark Icon
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 10),

                // 3. Sub-message
                Text(
                  widget
                      .paymentLink
                      .paymentProfileName, // Assuming this is the merchant name
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isNew
                      ? 'Your payment link has been created and is\nready to use'
                      : "Your payment link is ready",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // 4. Payment Details Card
                _buildDetailsCard(),
                const SizedBox(height: 30),

                if (widget.isNew == false) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Delete Payment Link',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              bool? result = await _con.deletePaymentLink(
                                widget.paymentLink.id,
                              );

                              if (result == true) {
                                showDeleteSuccessDialog(context);
                              } else {
                                CustomMessageHandler().showErrorSnakeBar(
                                  context,
                                  'Something went wrong. Try again',
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],

                if (_con.shortLinkModel != null) ...[
                  // 5. Payment Link URL
                  _buildPaymentLinkField(),
                  const SizedBox(height: 30),

                  // 6. QR Code Section
                  const Text(
                    'QR Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildQrCode(),
                  const SizedBox(height: 10),

                  InkWell(
                    onTap: () {
                      sharePaymentLink(_con.shortLinkModel?.shortLink ?? '');
                    },

                    child: Icon(Icons.share, size: 40),
                  ),
                  const Text(
                    'Scan this QR code to access your payment link',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                ],
                // 7. Action Buttons
                if (_con.shortLinkModel != null) _buildActionButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDateString(DateTime dateTime) {
    // 1. Convert the ISO 8601 string to a DateTime object
    // DateTime.parse handles the T and timezone offset automatically.

    // 2. Define the desired format
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    // 3. Format the DateTime object
    String formattedDate = formatter.format(dateTime);
    // Output: 2025-11-18

    return formattedDate;
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildDetailRow('Name:', details.name),

          _buildDetailRow('Email:', details.email),

          _buildDetailRow('Currency:', details.currency),
          _buildDetailRow(
            'Amount:',
            widget.paymentLink.paymentLinkAmount?.toStringAsFixed(2) ?? '-',
          ),

          _buildDetailRow('Reference:', details.reference),
          _buildDetailRow('Payment type:', widget.paymentLink.title),
          _buildDetailRow(
            'Start Date:',
            formatDateString(widget.paymentLink.paymentLinkStartDate),
          ),
          _buildDetailRow(
            'End Date:',
            formatDateString(widget.paymentLink.paymentLinkEndDate),
          ),
          _buildDetailRow(
            'Description:',
            widget.paymentLink.paymentProfileDescription.trim(),
          ),

          if (_con.shortLinkModel != null)
            _buildDetailRow(
              'Number of clicks:',
              (_con.shortLinkModel?.clicks ?? 0).toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90, // Fixed width for labels
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLinkField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        // Use SelectableText for easy copying
                        _con.shortLinkModel?.shortLink ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer(),
              // Expanded(
              //   child: 1 == 1
              //       ? IconButton(
              //           icon: const Icon(Icons.settings), // The icon to display
              //           onPressed: () {
              //             _copyTextToClipboard(
              //               _con.shortLinkModel?.shortLink ?? '-',
              //               context,
              //             );
              //           }, // The function to call when tapped
              //           tooltip:
              //               'Settings', // Optional: Text that appears on a long press
              //           color: Colors.white, // Optional: Color of the icon
              //         )
              //       : InkWell(
              //           onTap: () {
              //             _copyTextToClipboard(
              //               _con.shortLinkModel?.shortLink ?? '-',
              //               context,
              //             );
              //           },

              //           child: Container(
              //             height: 50,
              //             width: 50,

              //             child: Center(child: Icon(Icons.copy, size: 50)),
              //           ),
              //         ),
              // ),
              // IconButton(
              //   icon: const Icon(
              //     Icons.settings,
              //     color: Colors.black,
              //   ), // The icon to display
              //   onPressed: () {
              //     _copyTextToClipboard(
              //       _con.shortLinkModel?.shortLink ?? '-',
              //       context,
              //     );
              //   }, // The function to call when tapped
              //   tooltip:
              //       'Settings', // Optional: Text that appears on a long press
              //   color: Colors.white, // Optional: Color of the icon
              // ),
            ],
          ),

          IconButton(
            icon: const Icon(
              Icons.copy_all_outlined,
              size: 50,
            ), // The icon to display
            onPressed: () {
              _copyTextToClipboard(
                _con.shortLinkModel?.shortLink ?? '-',
                context,
              );
            }, // The function to call when tapped
            tooltip: 'Copy', // Optional: Text that appears on a long press
            color: Colors.black, // Optional: Color of the icon
          ),
        ],
      ),
    );
  }

  void showDeleteSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // User can tap outside to close
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: PopScope(
            canPop: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Wrap content height
                children: [
                  // 1. Success Icon with subtle background
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF679E4F), // Your theme green
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Title
                  const Text(
                    "Deleted Successfully",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Subtitle
                  const Text(
                    "The payment link has been deleted successfully.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 4. Action Button (Matching your Gradient theme)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).pop();

                      goHome();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF679E4F), Color(0xFFBCCB4F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Okay",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  goHome() {
    Navigator.pushNamed(context, '/Dashboard', arguments: 1);
  }

  void _copyTextToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      // Optional: Show a message to the user that the text has been copied.
      // For example, using a SnackBar:
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
    });
  }

  Future<void> launchInInternalBrowser(
    BuildContext context,
    String urlString,
  ) async {
    // 1. Convert the string URL to a Uri object
    final Uri url = Uri.parse(urlString);

    // 2. Check if the URL can be launched
    if (await canLaunchUrl(url)) {
      // 3. Launch the URL using the inAppWebView mode
      await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
        // You can customize the appearance of the web view here (iOS only)
        // webViewConfiguration: const WebViewConfiguration(
        //   enableJavaScript: true,
        // ),
      );
    } else {
      // 4. Handle failure (e.g., if the URL is invalid or the device lacks a browser component)
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
      }
    }
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

  // --- Image Saving Logic ---
  Future<void> _saveQrCode(GlobalKey qrKey, BuildContext context) async {
    // 1. Request Storage Permission (Crucial for Android 10/11+)
    final status = await Permission.storage.request();

    if (status.isGranted) {
      try {
        // 2. Capture the QR code image from the RepaintBoundary
        RenderRepaintBoundary boundary =
            qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

        // Use pixelRatio for better quality (e.g., 3.0 for high resolution)
        var image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData = await image.toByteData(
          format: ImageByteFormat.png,
        );
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // 3. Save the PNG bytes to the device's gallery
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';

        final file = File(filePath);
        await file.writeAsBytes(pngBytes);

        // Save to gallery
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Scan this QR code'),
        );

        // Dismiss the dialog after saving attempt
      } catch (e) {
        print(e);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      // Handle permission denied
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied.')),
      );
    }
  }

  Widget _buildQrCode() {
    // Placeholder for an actual QR Code widget (e.g., using qr_flutter package)
    // We use a Container with an Image placeholder to match the look.
    return Container(
      width: 200,
      height: 200,
      color: Colors
          .transparent, // QR code background is typically white/transparent
      child: RepaintBoundary(
        key: qrKey,
        child: QrImageView(
          data:
              _con.shortLinkModel?.shortLink ??
              '-', // The data string to encode
          version: QrVersions.auto, // Automatically selects the best version
          size: 250.0, // Size of the QR code square
          gapless: true, // Remove extra white space around the QR dots
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,

          // You can customize the look of the embedded dots:
          // dataModuleSettings: const QrDataModuleSettings(
          //   type: QrDataModuleType.square,
          // ),
          // Optional: Add a small logo in the center (Requires a specific image asset)
          // embeddedImage: AssetImage('assets/logo.png'),
          // embeddedImageStyle: const QrEmbeddedImageStyle(
          //   size: Size(40, 40),
          // ),
        ),
      ),
      // -,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Download Button (Red background gradient)
        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.shade400),
          ),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.cloud_download, color: Colors.red),
            label: const Text(
              'Download',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              _saveQrCode(qrKey, context);
              // Handle download action
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide.none, // Remove default border
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Close and View Link Buttons (Row at the bottom)
        Row(
          children: [
            // Close Button
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.isNew) {
                      Navigator.pop(context);
                    }

                    // Handle close action
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green.shade400, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),

            // View Link Button (Red Solid)
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.link, color: Colors.white),
                  label: const Text(
                    'View Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    launchInInternalBrowser(
                      context,
                      _con.shortLinkModel?.shortLink ?? '',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
