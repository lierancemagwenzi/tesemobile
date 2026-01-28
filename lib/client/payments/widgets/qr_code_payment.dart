import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class TesePaymentQR extends StatefulWidget {
  final String paymentData; // Usually the payment link or transaction ID
  final String amount;

  const TesePaymentQR({
    super.key,
    required this.paymentData,
    required this.amount,
  });

  @override
  State<TesePaymentQR> createState() => _TesePaymentQRState();
}

class _TesePaymentQRState extends State<TesePaymentQR> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _shareQrCode() async {
    try {
      // 1. Capture the widget as an image
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2. Save to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/tese_payment_qr.png').create();
      await file.writeAsBytes(pngBytes);

      // 3. Share the file
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Pay me ${widget.amount} on Tese Africa');
    } catch (e) {
      debugPrint('Error sharing QR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Payment"),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.refresh),
          //   onPressed: () => _controller.reload(),
          // ),
        ],
      ),
      // backgroundColor: Colors.white,
      body: Column(
        // mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // This boundary defines what gets turned into the shared image
          Center(
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                color:
                    Colors.white, // Ensure white background for easy scanning
                child: Column(
                  children: [
                    const Text(
                      "Scan the QR code to make payment",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    QrImageView(
                      data: widget.paymentData,
                      version: QrVersions.auto,
                      size: 200.0,
                      gapless: false,
                    ),
                    Text(
                      widget.amount,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _shareQrCode,
            icon: const Icon(Icons.share),
            label: const Text("SHARE QR CODE"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20), // Tese Green
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
