import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

// import 'package:mobile_scanner/mobile_scanner.dart';

class ScanToPay extends StatefulWidget {
  const ScanToPay({Key? key}) : super(key: key);

  @override
  _ScanToPayState createState() => _ScanToPayState();
}

class _ScanToPayState extends State<ScanToPay> {
  String? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: MobileScanner(
      //   onDetect: (result) {
      //     print(result.barcodes.first.rawValue);
      //   },
      // ),
      body: ElevatedButton(
        onPressed: () async {
          String? res = await SimpleBarcodeScanner.scanBarcode(
            context,
            barcodeAppBar: const BarcodeAppBar(
              appBarTitle: 'Test',
              centerTitle: false,
              enableBackButton: true,
              backButtonIcon: Icon(Icons.arrow_back_ios),
            ),
            isShowFlashIcon: true,
            delayMillis: 2000,
            cameraFace: CameraFace.front,
          );
          setState(() {
            result = res as String;
          });
        },
        child: const Text('Open Scanner'),
      ),
    );
  }
}
