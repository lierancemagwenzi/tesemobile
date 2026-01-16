import 'dart:io';
import 'dart:math';
// import 'package:camera/camera.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
// import 'package:flutter_camera_overlay/model.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';

import '../utils/file_utils.dart';

class IDScannerWidget extends StatefulWidget {

  const IDScannerWidget({Key? key}) : super(key: key);

  @override
  _IDScannerWidgetState createState() => _IDScannerWidgetState();
}

class _IDScannerWidgetState extends State<IDScannerWidget> {
  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    throw UnimplementedError();
  }

  // final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  // final picker = ImagePicker();
  // Future getImageFromGallery() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     final inputImage = InputImage.fromFile(File(pickedFile.path));
  //     process(inputImage);
  //   }
  // }
  // process(InputImage inputImage) async {
  //
  //   final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
  //   String text = recognizedText.text;
  //   print(text);
  //   for (TextBlock block in recognizedText.blocks) {
  //     final Rect rect = block.boundingBox;
  //     final List<Point<int>> cornerPoints = block.cornerPoints;
  //     final String text = block.text;
  //     // print(text);
  //     final List<String> languages = block.recognizedLanguages;
  //
  //     for (TextLine line in block.lines) {
  //       // print("${line.text}${line.confidence} ${line.recognizedLanguages}");
  //       // Same getters as TextBlock
  //       for (TextElement element in line.elements) {
  //         // Same getters as TextBlock
  //       }
  //     }
  //   }
  // }
  //
  //
  // OverlayFormat format = OverlayFormat.cardID1;
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body:1==1?   FutureBuilder<List<CameraDescription>?>(
  //       future: availableCameras(),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           if (snapshot.data == null) {
  //             return const Align(
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   'No camera found',
  //                   style: TextStyle(color: Colors.black),
  //                 ));
  //           }
  //           return CameraOverlay(
  //               snapshot.data!.first,
  //               CardOverlay.byFormat(format),
  //                   (XFile file) => showDialog(
  //                 context: context,
  //                 barrierColor: Colors.black,
  //                 builder: (context) {
  //                   CardOverlay overlay = CardOverlay.byFormat(format);
  //                   return  1==1?Material(
  //
  //                     child: GestureDetector(
  //
  //                       onTap: (){
  //                         Navigator.pop(context);
  //                         Navigator.of(context, rootNavigator: true).pop(File(file.path));
  //
  //                       },
  //                       child: Container(
  //
  //                       decoration:    BoxDecoration(
  //                               image: DecorationImage(
  //                                 fit: BoxFit.fitWidth,
  //                                 alignment: FractionalOffset.center,
  //                                 image: FileImage(
  //                                   File(file.path),
  //                                 ),
  //                               ))
  //                       ),
  //                     ),
  //                   ):AlertDialog(
  //                       actionsAlignment: MainAxisAlignment.center,
  //                       backgroundColor: Colors.black,
  //                       title: const Text('Capture',
  //                           style: TextStyle(color: Colors.white),
  //                           textAlign: TextAlign.center),
  //                       actions: [
  //                         OutlinedButton(
  //                             onPressed: () => Navigator.of(context).pop(),
  //                             child: const Icon(Icons.close)),
  //
  //                         OutlinedButton(
  //                             onPressed: () {
  //                               Navigator.of(context).pop();
  //                               Navigator.of(context).pop();
  //                             },
  //                             child: const Icon(Icons.done))
  //                       ],
  //                       content: InkWell(
  //                         onTap: (){
  //                           Navigator.of(context).pop();
  //
  //                           Navigator.of(context, rootNavigator: true).pop(File(file.path));
  //                         },
  //                         child: SizedBox(
  //                             width: double.infinity,
  //                             child: AspectRatio(
  //                               aspectRatio: overlay.ratio!,
  //                               child: Container(
  //                                 decoration: BoxDecoration(
  //                                     image: DecorationImage(
  //                                       fit: BoxFit.fitWidth,
  //                                       alignment: FractionalOffset.center,
  //                                       image: FileImage(
  //                                         File(file.path),
  //                                       ),
  //                                     )),
  //                               ),
  //                             )),
  //                       ));
  //                 },
  //               ),
  //               info:
  //               'Position your ID card within the rectangle and ensure the image is perfectly readable.',
  //               label: 'Scanning ID Card');
  //         } else {
  //           return const Align(
  //               alignment: Alignment.center,
  //               child: Text(
  //                 'Fetching cameras',
  //                 style: TextStyle(color: Colors.black),
  //               ));
  //         }
  //       },
  //     ): Container(
  //       color: Colors.white,
  //       child: CameraAwesomeBuilder.awesome(
  //         saveConfig: SaveConfig.photoAndVideo(
  //           photoPathBuilder: () => path(CaptureMode.photo),
  //           videoPathBuilder: () => path(CaptureMode.video),
  //           initialCaptureMode: CaptureMode.photo,
  //         ),
  //         enablePhysicalButton: true,
  //         filter: AwesomeFilter.AddictiveRed,
  //         // flashMode: FlashMode.auto,
  //         aspectRatio: CameraAspectRatios.ratio_16_9,
  //         previewFit: CameraPreviewFit.fitWidth,
  //         onMediaTap: (mediaCapture) {
  //           // OpenFile.open(mediaCapture.filePath);
  //         },
  //       ),
  //     ),
  //   );
  // }

}
