import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/auth/widgets/models/id_details.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/payments/models/payment_link_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
import 'package:uri_to_file/uri_to_file.dart';

import '../../../models/constants.dart';
import '../../../widgets/CustomButtons.dart';
import '../../controller/LoginController.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

class IDPickerWidget extends StatefulWidget {
  const IDPickerWidget({Key? key}) : super(key: key);

  @override
  _IDPickerWidgetState createState() => _IDPickerWidgetState();
}

class _IDPickerWidgetState extends StateMVC<IDPickerWidget> {
  final ImagePicker picker = ImagePicker();

  late LoginController _con;

  _IDPickerWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  final RegExp strictIdNumberRegex = RegExp(r'\d{2}-\d{6}[A-Z]\d{2}');

  // The DOB format is clearly: 26/08/1995
  // Pattern: 2 digits, slash, 2 digits, slash, 4 digits.
  final RegExp dobRegex = RegExp(r'\d{2}/\d{2}/\d{4}');
  // General pattern to look for common name labels followed by text
  final RegExp nameLineRegex = RegExp(
    r'(?:surname|last\sname|first\sname|name)\s+([a-z\s]+)',
    caseSensitive: false,
    multiLine: true,
  );

  Future<IdDetails> extractIdDetailsFromImage(File file) async {
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.camera);

    // if (image == null) {
    //   return IdDetails();
    // }

    final InputImage inputImage = InputImage.fromFilePath(file.path);
    final TextRecognizer textRecognizer = TextRecognizer(
      script: TextRecognitionScript.latin,
    );
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    textRecognizer.close();

    String fullText = recognizedText.text.toLowerCase();
    print(fullText);

    final allTextLower = recognizedText.text.toLowerCase();
    String? extractedIdNumber;
    String? extractedDob;
    String? extractedSurname;
    String? extractedFirstName;
    // --- 1. Extract Pattern-Based Fields (ID and DOB) ---

    // ID Number (from full text, using the strict pattern)
    final RegExp potentialIdLineRegex = RegExp(
      r'\d{2}-\s*?\d{6}',
      caseSensitive: false,
    );

    // Search the entire text block for the line containing the ID
    String? rawIdLine;
    for (String line in recognizedText.text.split('\n')) {
      if (potentialIdLineRegex.hasMatch(line)) {
        rawIdLine = line;
        break;
      }
    }

    if (rawIdLine != null) {
      // 1. Normalize the raw line (e.g., "43- 192463 d 18 citm" -> "43-192463D18CITM")
      String normalizedIdText = normalizeIdString(rawIdLine);

      // 2. Apply the strict regex
      final idMatch = strictIdNumberRegex.firstMatch(normalizedIdText);

      if (idMatch != null) {
        // 3. Capture the match, which stops exactly at the end of the 12th character.
        extractedIdNumber = idMatch.group(0);
        // Result: "43-192463D18"
      }
    }

    // DOB (from full text, using the strict pattern)
    final dobMatch = dobRegex.firstMatch(allTextLower);
    if (dobMatch != null) {
      extractedDob = dobMatch.group(0)?.trim();
    }

    // --- 2. Extract Keyword-Based Fields (Surname and First Name) ---

    // We must look for the text *after* the label

    // Simple, direct lookup for data following keywords:

    // Regex to find "surname" or "frst nanme" and capture the next word/line of text

    // Surname: Look for 'surname' followed by optional separators/spaces, then capture words
    // The provided example shows 'surname' is immediately followed by 'magwenzi'
    final surnameCapture = RegExp(
      r'(?:surname)\s*([a-z]+)',
      caseSensitive: false,
    ).firstMatch(allTextLower);
    if (surnameCapture != null && surnameCapture.groupCount >= 1) {
      extractedSurname = surnameCapture.group(1)?.toTitleCase();
    }

    // First Name: Look for 'frst nanme' (the common OCR typo) followed by the name
    final firstNameCapture = RegExp(
      r'(?:frst\s+nanme|first\s+name)\s*([a-z]+)',
      caseSensitive: false,
    ).firstMatch(allTextLower);
    if (firstNameCapture != null && firstNameCapture.groupCount >= 1) {
      extractedFirstName = firstNameCapture.group(1)?.toTitleCase();
    }

    // --- 3. Return Final Model ---
    return IdDetails(
      idNumber: extractedIdNumber,
      dob: extractedDob,
      surname: extractedSurname,
      firstName: extractedFirstName,
    );
  }

  String normalizeIdString(String raw) {
    // 1. Remove all whitespace (spaces, tabs, newlines)
    String cleaned = raw.replaceAll(RegExp(r'\s+'), '');
    // 2. Convert to uppercase for consistent letter matching (d -> D)
    return cleaned.toUpperCase();
  }

  dynamic _scannedDocuments;

  Future<void> scanDocument(String type) async {
    print("ios_scanning");
    dynamic scannedDocuments;
    try {
      scannedDocuments =
          await FlutterDocScanner().getScannedDocumentAsImages() ?? [];

      if (scannedDocuments == null || scannedDocuments.isEmpty) {
        print("User cancelled or no documents scanned");
        return;
      }

      if (scannedDocuments.length > 1) {
        print("You selected more than 1 image");
        for (var filePath in scannedDocuments) {
          print("Scanned file: $filePath");
          final file = File(filePath);
          // now you can upload, read bytes, preview, etc.
        }
      } else {
        final file = File(scannedDocuments[0]);
        print(" file: ${file.path}");
        if (type == 'front') {
          var details = await extractIdDetailsFromImage(file);

          print(details.toString());
          // if (details.dob != null && details.idNumber != null) {
          frontImage = file;

          id_details.value = details;
          // } else {
          //   CustomMessageHandler().showErrorSnakeBar(
          //     context,
          //     'Please use a clear id image',
          //   );

          //   return;
          // }
        } else {
          backImage = file;
        }

        setState(() {});

        // setState(() {
        //   _scannedDocuments = scannedDocuments;
        // });
      }
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }
    print(scannedDocuments.toString());
    if (!mounted) return;

    // try {
    //   File file = File(scannedDocuments.toString());

    //   bool exists = file.existsSync();
    //   if (exists) {
    //     if (type == 'front') {
    //       frontImage = file;
    //     } else {
    //       backImage = file;
    //     }

    //     setState(() {
    //       _scannedDocuments = scannedDocuments;
    //     });
    //   }
    // } catch (e) {
    //   print(e);
    // }
    setState(() {
      _scannedDocuments = scannedDocuments;
    });
  }

  Future<void> scanDocumentUri(String type) async {
    print("android_scanning");

    dynamic scannedDocuments;
    try {
      scannedDocuments =
          await FlutterDocScanner().getScanDocumentsUri() ??
          'Unknown platform documents';
    } on PlatformException {
      scannedDocuments = 'Failed to get scanned documents.';
    }
    print("scanned_document");
    print(scannedDocuments);

    try {
      List<String> list = scannedDocuments.toString().split(" ");

      list.forEach((element) {
        // print(element);
      });

      String the = list[1];
      String g = the.split("=")[1];
      String f = g.split("}")[0];

      print(f);
      convertUriToFile(f, type);
      if (!mounted) return;
      setState(() {
        _scannedDocuments = scannedDocuments;
      });
    } catch (e) {
      print(e);
    }

    // dynamic scannedDocuments;
    // try {
    //   scannedDocuments =
    //       await FlutterDocScanner().getScanDocuments(page: 1) ??
    //       'Unknown platform documents';
    // } on PlatformException {
    //   scannedDocuments = 'Failed to get scanned documents.';
    // }
    // print(scannedDocuments.toString());
  }

  File? frontImage;
  File? backImage;

  capture(String type) {
    if (Platform.isAndroid) {
      scanDocumentUri(type);
    } else {
      scanDocument(type);
    }
  }

  Future<void> convertUriToFile(String uriString, String type) async {
    print("konvict");
    try {
      // String uriString = 'content://sample.txt'; // Uri string

      // Don't pass uri parameter using [Uri] object via uri.toString().
      // Because uri.toString() changes the string to lowercase which causes this package to misbehave

      // If you are using uni_links package for deep linking purpose.
      // Pass the uri string using getInitialLink() or linkStream

      final String cleanedPath = uriString.startsWith('file://')
          ? uriString.substring('file://'.length)
          : uriString;

      // 2. Create the dart:io File object.
      // This object allows you to interact with the file system.
      final File file = File(cleanedPath);

      // File file = await toFile(uriString);
      print("scanned_file");
      var details = await extractIdDetailsFromImage(file);

      print(details.toString());

      if (type == 'front') {
        // if (details.dob != null && details.idNumber != null) {
        frontImage = file;

        id_details.value = details;
        setState(() {});
        // } else {
        //   CustomMessageHandler().showErrorSnakeBar(
        //     context,
        //     'Please use a clear id image',
        //   );

        //   return;
        // }
      } else {
        backImage = file;
        setState(() {});
      }

      print(file.path); // Converting uri to file
    } on UnsupportedError catch (e) {
      print(e.message); // Unsupported error for uri not supported
    } on IOException catch (e) {
      print(e); // IOException for system error
    } catch (e) {
      print("the_error");
      print(e); // General exception
    }
  }

  pickImage(String type) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      if (mounted) {
        setState(() {
          if (type == 'front') {
            frontImage = file;
          } else {
            backImage = file;
          }
        });
      }
    }
  }

  takeImage(String type) async {
    Navigator.pushNamed(context, '/IDScanner').then((value) {
      print("popped");
      if (value != null) {
        File file = value as File;
        if (mounted) {
          setState(() {
            if (type == 'front') {
              frontImage = file;
            } else {
              backImage = file;
            }
          });
        }
      }
    });
    // final XFile? image = await picker.pickImage(source: ImageSource.camera);
    // if(image!=null){
    //   File file=File(image.path);
    //   if(mounted) {
    //     setState(() {
    //       if (type == 'front') {
    //         frontImage = file;
    //       }
    //       else {
    //         backImage = file;
    //       }
    //     });
    //   }
    // }
  }

  void showModal(String type) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200, // Set your desired height
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select an option",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 16),
                CustomButtons.filledButton(
                  text: 'Pick from gallery',
                  callback: () {
                    Navigator.pop(context);
                    pickImage(type);
                  },
                ),
                const SizedBox(height: 16),
                CustomButtons.outlineButton(
                  text: 'Capture image',
                  callback: () {
                    Navigator.pop(context);
                    takeImage(type);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Constants.greyColor),
        ),
        bottomNavigationBar: frontImage != null && backImage != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButtons.filledButton(
                        text: 'Upload images',
                        callback: () {
                          if (_con.loading) {
                            // return;
                          }

                          _con.uploadIDFront(frontImage!, backImage!);
                          // Navigator.pop(context,[frontImage,backImage]);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              )
            : null,

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "National ID",
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: Colors.black),
                  ),
                  const SizedBox(height: 16),

                  frontImage != null
                      ? Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        )
                      : SizedBox(height: 0, width: 0),
                  SizedBox(height: 8),
                  CustomButtons.filledButton(
                    text: 'Front image',
                    callback: () {
                      // showModal('front');
                      capture("front");
                    },
                  ),
                  const SizedBox(height: 8),

                  Divider(),
                  const SizedBox(height: 8),
                  backImage != null
                      ? Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        )
                      : SizedBox(height: 0, width: 0),
                  SizedBox(height: 8),
                  CustomButtons.outlineButton(
                    text: 'Back Image',
                    callback: () {
                      capture('back');
                    },
                  ),
                  const SizedBox(height: 24),

                  // _scannedDocuments != null
                  //     ? Text(_scannedDocuments.toString())
                  //     : const Text("No Documents Scanned"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
