// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:smacredit/src/payments/models/payment_link_model.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// // import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:smacredit/src/payments/models/payout_model.dart';
// import 'package:smacredit/src/payments/models/transaction_model.dart';
// import 'package:url_launcher/url_launcher.dart';

// // --- Payment Link Success Screen Widget ---

// class PayoutDetailScreen extends StatefulWidget {
//   const PayoutDetailScreen({super.key, required this.transaction});

//   final PayoutModel transaction;

//   @override
//   State<PayoutDetailScreen> createState() => _PayoutDetailScreenState();
// }

// class _PayoutDetailScreenState extends State<PayoutDetailScreen> {
//   final GlobalKey qrKey = GlobalKey();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),

//               // 1. Success Message
//               Text(
//                 'Payout detail',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // 2. Large Checkmark Icon
//               widget.transaction.payoutMerchantStatus?.toLowerCase() == 'paid'
//                   ? const CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.green,
//                       child: Icon(Icons.check, size: 50, color: Colors.white),
//                     )
//                   : const CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.red,
//                       child: Icon(Icons.close, size: 50, color: Colors.white),
//                     ),
//               const SizedBox(height: 10),

//               // 3. Sub-message
//               Text(
//                 widget.transaction.payoutMerchantRef ??
//                     '', // Assuming this is the merchant name
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.green.shade700,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.transaction.payoutMerchantStatus ?? '',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//               const SizedBox(height: 30),

//               // 4. Payment Details Card
//               _buildDetailsCard(),
//               const SizedBox(height: 30),

//               // 7. Action Buttons
//               _buildActionButtons(context),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String formatDateString(DateTime dateTime) {
//     // 1. Convert the ISO 8601 string to a DateTime object
//     // DateTime.parse handles the T and timezone offset automatically.

//     // 2. Define the desired format
//     DateFormat formatter = DateFormat('yyyy-MM-dd');

//     // 3. Format the DateTime object
//     String formattedDate = formatter.format(dateTime);
//     // Output: 2025-11-18

//     return formattedDate;
//   }

//   Widget _buildDetailsCard() {
//     return Container(
//       key: qrKey,

//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Payout Details',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 10),
//           _buildDetailRow(
//             'Ticket Number:',
//             widget.transaction.payoutMerchantRef ?? '',
//           ),

//           // _buildDetailRow('Payer Email:', widget.transaction.ema),
//           _buildDetailRow(
//             'Currency:',
//             widget.transaction.payoutMerchantCurrency ?? '-',
//           ),
//           // _buildDetailRow('Reference:', widget.transaction.payerReference),
//           // _buildDetailRow('Payment Code:', widget.transaction.payerCode),
//           _buildDetailRow(
//             'Payment Date:',
//             formatDateString(widget.transaction.createdAt ?? DateTime.now()),
//           ),
//           _buildDetailRow(
//             'Requested Amount:',
//             widget.transaction.payoutMerchantAmount?.toStringAsFixed(2) ??
//                 '0.0',
//           ),
//           _buildDetailRow(
//             'Payment Platform Charges:',
//             widget.transaction.payoutMerchantSmatPayAmountFees
//                     ?.toDouble()
//                     .toStringAsFixed(2) ??
//                 '-',
//           ),
//           _buildDetailRow(
//             'Bank Charges:',
//             widget.transaction.payoutMerchantBankFeesAmount
//                     ?.toDouble()
//                     .toStringAsFixed(2) ??
//                 '-',
//           ),
//           _buildDetailRow(
//             'Actual payout:',
//             widget.transaction.payoutMerchantActualPayoutBalance
//                     ?.toStringAsFixed(2) ??
//                 '0.00',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 90, // Fixed width for labels
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(color: Colors.black)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _copyTextToClipboard(String text, BuildContext context) {
//     Clipboard.setData(ClipboardData(text: text)).then((_) {
//       // Optional: Show a message to the user that the text has been copied.
//       // For example, using a SnackBar:
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
//     });
//   }

//   Future<void> launchInInternalBrowser(
//     BuildContext context,
//     String urlString,
//   ) async {
//     // 1. Convert the string URL to a Uri object
//     final Uri url = Uri.parse(urlString);

//     // 2. Check if the URL can be launched
//     if (await canLaunchUrl(url)) {
//       // 3. Launch the URL using the inAppWebView mode
//       await launchUrl(
//         url,
//         mode: LaunchMode.inAppWebView,
//         // You can customize the appearance of the web view here (iOS only)
//         // webViewConfiguration: const WebViewConfiguration(
//         //   enableJavaScript: true,
//         // ),
//       );
//     } else {
//       // 4. Handle failure (e.g., if the URL is invalid or the device lacks a browser component)
//       if (context.mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
//       }
//     }
//   }

//   void sharePaymentLink(String paymentLinkUrl) {
//     // 1. Construct the message and URL
//     String subject = "Payment Link from [Your Company Name]";
//     String text =
//         "Please use this link to complete your payment: $paymentLinkUrl";

//     // 2. Call the static share method
//     SharePlus.instance.share(
//       ShareParams(text: 'check out my payment link $paymentLinkUrl'),
//     );
//   }

//   // --- Image Saving Logic ---
//   Future<void> _saveQrCode(GlobalKey qrKey, BuildContext context) async {
//     // // 1. Request Storage Permission (Crucial for Android 10/11+)
//     // final status = await Permission.storage.request();

//     // if (status.isGranted) {
//     //   try {
//     //     // 2. Capture the QR code image from the RepaintBoundary
//     //     RenderRepaintBoundary boundary =
//     //         qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

//     //     // Use pixelRatio for better quality (e.g., 3.0 for high resolution)
//     //     var image = await boundary.toImage(pixelRatio: 3.0);
//     //     ByteData? byteData = await image.toByteData(
//     //       format: ImageByteFormat.png,
//     //     );
//     //     Uint8List pngBytes = byteData!.buffer.asUint8List();

//     //     // 3. Save the PNG bytes to the device's gallery
//     //     final result = await ImageGallerySaver.saveImage(
//     //       pngBytes,
//     //       // The default Flutter image naming strategy should be fine.
//     //       name: "receipt-${DateTime.now().millisecondsSinceEpoch}",
//     //     );

//     //     // 4. Provide Feedback
//     //     String message = result['isSuccess']
//     //         ? "Detail saved successfully!"
//     //         : "Failed to save detail.";

//     //     // Dismiss the dialog after saving attempt
//     //     // Navigator.of(context).pop();
//     //     ScaffoldMessenger.of(
//     //       context,
//     //     ).showSnackBar(SnackBar(content: Text(message)));
//     //   } catch (e) {
//     //     // Navigator.of(context).pop();
//     //     ScaffoldMessenger.of(
//     //       context,
//     //     ).showSnackBar(SnackBar(content: Text('Error')));
//     //   }
//     // } else {
//     //   // Handle permission denied
//     //   Navigator.of(context).pop();
//     //   ScaffoldMessenger.of(context).showSnackBar(
//     //     const SnackBar(content: Text('Storage permission denied.')),
//     //   );
//     // }
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 20),

//         // Close and View Link Buttons (Row at the bottom)
//         Row(
//           children: [
//             // Close Button
//             Expanded(
//               child: SizedBox(
//                 height: 50,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     Navigator.pop(context);

//                     // Handle close action
//                   },
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: Colors.green.shade400, width: 2),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: Text(
//                     'Close',
//                     style: TextStyle(
//                       color: Colors.green.shade700,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 15),

//             // View Link Button (Red Solid)
//             Expanded(
//               child: SizedBox(
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   icon: const Icon(
//                     Icons.download_outlined,
//                     color: Colors.white,
//                   ),
//                   label: const Text(
//                     'Download',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onPressed: () {
//                     _saveQrCode(qrKey, context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smacredit/src/payments/models/payout_model.dart';

class PayoutDetailScreen extends StatefulWidget {
  const PayoutDetailScreen({super.key, required this.transaction});

  final PayoutModel transaction;

  @override
  State<PayoutDetailScreen> createState() => _PayoutDetailScreenState();
}

class _PayoutDetailScreenState extends State<PayoutDetailScreen> {
  final GlobalKey qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPaid =
        widget.transaction.payoutMerchantStatus?.toLowerCase() == 'paid';
    final statusColor = isPaid ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payout Detail',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // 1. Status Icon & Text
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.pending_rounded,
                  size: 60,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.transaction.payoutMerchantRef ?? 'No Reference',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (widget.transaction.payoutMerchantStatus ?? 'Pending')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 2. Receipt Card (The RepaintBoundary covers this)
              RepaintBoundary(key: qrKey, child: _buildReceiptCard(isDark)),

              const SizedBox(height: 40),

              // 3. Action Buttons
              _buildActionButtons(context, isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('General Information', isDark),
          _buildDetailRow(
            'Ticket No:',
            widget.transaction.payoutMerchantRef ?? '',
            isDark,
          ),
          _buildDetailRow(
            'Currency:',
            widget.transaction.payoutMerchantCurrency ?? '-',
            isDark,
          ),
          _buildDetailRow(
            'Date:',
            formatDateString(widget.transaction.createdAt ?? DateTime.now()),
            isDark,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Colors.white10),
          ),

          _sectionHeader('Financial Breakdown', isDark),
          _buildDetailRow(
            'Requested:',
            '\$${widget.transaction.payoutMerchantAmount?.toStringAsFixed(2)}',
            isDark,
          ),
          _buildDetailRow(
            'SmatPay Fee:',
            '-\$${widget.transaction.payoutMerchantSmatPayAmountFees?.toStringAsFixed(2)}',
            isDark,
            isNegative: true,
          ),
          _buildDetailRow(
            'Bank Charges:',
            '-\$${widget.transaction.payoutMerchantBankFeesAmount?.toStringAsFixed(2)}',
            isDark,
            isNegative: true,
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Actual Payout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '\$${widget.transaction.payoutMerchantActualPayoutBalance?.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: isDark ? Colors.greenAccent : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: isDark ? Colors.white38 : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isDark, {
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isNegative
                  ? Colors.red.shade400
                  : (isDark ? Colors.white : Colors.black),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text(
              'SHARE RECEIPT',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _captureAndShareReceipt(),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CLOSE',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Logic Helpers ---

  String formatDateString(DateTime dateTime) =>
      DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);

  Future<void> _captureAndShareReceipt() async {
    try {
      RenderRepaintBoundary boundary =
          qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/receipt_${widget.transaction.payoutMerchantRef}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Payout Receipt: ${widget.transaction.payoutMerchantRef}',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error sharing receipt')));
    }
  }
}
