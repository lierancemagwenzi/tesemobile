import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_detection_randomized_plugin/flutter_liveness_detection_randomized_plugin.dart';
import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:m7_livelyness_detection/index.dart';
// import 'package:mnc_identifier_face/mnc_identifier_face.dart';
// import 'package:mnc_identifier_face/model/liveness_detection_result_model.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../../../helpers/Message.dart';
import '../../../widgets/CustomButtons.dart';
import '../../controller/LoginController.dart';
import '../../models/RegistrationDocumentsModel.dart';
import '../../models/UploadIDModel.dart';
import '../liveness.dart';

class RegistrationImagesWidget extends StatefulWidget {
  Country country;

  RegistrationImagesWidget({Key? key, required this.country}) : super(key: key);

  @override
  _RegistrationImagesWidgetState createState() =>
      _RegistrationImagesWidgetState();
}

class _RegistrationImagesWidgetState
    extends StateMVC<RegistrationImagesWidget> {
  late LoginController _con;

  _RegistrationImagesWidgetState() : super(LoginController()) {
    _con = controller as LoginController;
  }

  final ImagePicker picker = ImagePicker();
  UploadIdModel? idFront;
  UploadIdModel? idBack;
  UploadIdModel? passport;

  String type = '';

  String error1 = '';
  String error2 = '';

  File? imageResult;

  Future<void> detectAndroid() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FaceDetectionPage()),
      );
      if (result != null && result is File) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification Successful!')),
        );
        setState(() {
          imageResult = result;
        });
        _con.uploadSelfie(result);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera not active!')));
    }
  }

  Future<void> startDetection() async {
    // try {
    //   LivenessDetectionResult livenessResult =
    //       await MncIdentifierFace().startLivenessDetection();
    //   debugPrint("result is ${livenessResult.toJson().toString()}");

    //   if (livenessResult.isSuccess == true) {
    //     DetectionResult detectionResult = livenessResult.detectionResult
    //         .firstWhere((element) => (element.detectionMode == "HOLD_STILL" ||
    //             element.detectionMode == "OPEN_MOUTH"));

    //     // ignore: unnecessary_null_comparison
    //     if (detectionResult != null) {
    //       File file = File(detectionResult.imagePath);
    //       setState(() {
    //         imageResult = file;
    //       });

    //       _con.uploadSelfie(file);
    //     } else {
    //       CustomMessageHandler().showErrorSnakeBar(
    //           _con.scaffoldKey.currentContext!, "No detection result");
    //     }
    //   } else {
    //     CustomMessageHandler().showErrorSnakeBar(
    //         _con.scaffoldKey.currentContext!,
    //         "Detection not successful ${livenessResult.errorMessage}");
    //   }
    // } catch (e, stacktrace) {
    //   debugPrint(
    //     'Something goes unexpected with error is $e',
    //   );
    //   error1 = e.toString();
    //   error2 = stacktrace.toString();
    //   setState(() {});
    //   print('Exception: ' + e.toString());
    //   print('Stacktrace: ' + stacktrace.toString());
    //   CustomMessageHandler()
    //       .showErrorSnakeBar(_con.scaffoldKey.currentContext!, "Exception $e");
    // }
  }

  checkLiveness() async {
    final String?
    response = await FlutterLivenessDetectionRandomizedPlugin.instance.livenessDetection(
      context: context,
      config: LivenessDetectionConfig(
        cameraResolution:
            ResolutionPreset.medium, // adjust the quality of image processing
        imageQuality: 100, // adjust your image quality result
        isEnableMaxBrightness:
            true, // enable disable max brightness when taking face photo
        durationLivenessVerify: 60, // default duration value is 45 second
        showDurationUiText:
            false, // show or hide duration remaining when perfoming liveness detection
        startWithInfoScreen: true, // show or hide tutorial screen
        useCustomizedLabel:
            false, // set to true value for enable 'customizedLabel', set to false to use default label
        // provide an empty string if you want to pass the liveness challenge
        customizedLabel: LivenessDetectionLabelModel(
          // blink: '', // add empty string to skip/pass this liveness challenge
          // lookDown: '',
          lookLeft: '',
          // lookRight: '',
          lookUp:
              'Look up', // example of customize label name for liveness challenge. it will replace default 'look up'
          // smile: null, // null value to use default label name
        ),
      ),
      isEnableSnackBar:
          true, // snackbar to notify either liveness is success or failed
      shuffleListWithSmileLast:
          true, // put 'smile' challenge always at the end of liveness challenge, if `useCustomizedLabel` is true, this automatically set to false
      isDarkMode: false, // enable dark/light mode
      showCurrentStep: true, // show number current step of liveness
    );

    if (response != null) {
      print("response_is ${response}");
      setState(() {
        imageResult = File(response); // result liveness
      });
      _con.uploadSelfie(imageResult!);
    } else {}

    // final M7CapturedImage? response =
    // await M7LivelynessDetection.instance.detectLivelyness(
    //   context,
    //   config: M7DetectionConfig(
    //     steps: [
    //       M7LivelynessStepItem(
    //         step: M7LivelynessStep.blink,
    //         title: "Blink",
    //         isCompleted: false,
    //       ),
    //       M7LivelynessStepItem(
    //         step: M7LivelynessStep.smile,
    //         title: "Smile",
    //         isCompleted: false,
    //       ),
    //
    //       // M7LivelynessStepItem(
    //       //   step: M7LivelynessStep.turnLeft,
    //       //   title: "TurnLeft",
    //       //   isCompleted: false,
    //       // ),
    //       // M7LivelynessStepItem(
    //       //   step: M7LivelynessStep.turnRight,
    //       //   title: "TunRight",
    //       //   isCompleted: false,
    //       // ),
    //     ],
    //     startWithInfoScreen: false,
    //   ),
    // );
    // print("response_is ${response?.toJson().toString()}");
    // if(response!=null) {
    //   if (response.didCaptureAutomatically == true) {
    //     File file = File(response.imgPath);
    //     setState(() {
    //       imageResult = file;
    //     });
    //     _con.uploadSelfie(file);
    //   }
    //   else {
    //     CustomMessageHandler().showErrorSnakeBar(
    //         _con.scaffoldKey.currentContext!, "No detection result");
    //
    //     print(response.toJson().toString());
    //   }
    // }
    //
    // else{
    //   CustomMessageHandler().showErrorSnakeBar(_con.scaffoldKey.currentContext!, "Detection not successful");
    //
    // }
  }

  // {attempt: 8, detectionResult: [{detectionMode: HOLD_STILL, imagePath: /data/user/0/com.smatechgroup.smatcredit/files/img_HOLD_STILL.jpg, timeMilis: 2656}, {detectionMode: OPEN_MOUTH, imagePath: /data/user/0/com.smatechgroup.smatcredit/files/img_OPEN_MOUTH.jpg, timeMilis: 4068}, {detectionMode: BLINK, imagePath: /data/user/0/com.smatechgroup.smatcredit/files/img_BLINK.jpg, timeMilis: 943}, {detectionMode: SHAKE_HEAD, imagePath: /data/user/0/com.smatechgroup.smatcredit/files/img_SHAKE_HEAD.jpg, timeMilis: 1863}, {detectionMode: SMILE, imagePath: /data/user/0/com.smatechgroup.smatcredit/files/img_SMILE.jpg, timeMilis: 2438}], errorMessage: Sucess, isSuccess: true, totalTimeMilis: 13828}

  // pickImage() async {
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  //   if(image!=null){
  //     File file=File(image.path);
  //     setState(() {
  //       this.file=file;
  //     });
  //
  //   }
  // }
  takeImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      File file = File(image.path);
      setState(() {
        imageResult = file;
      });

      _con.uploadSelfie(file);
    }
  }

  bool documentValidator() {
    if (type == 'idcard') {
      return idFront != null && idBack != null;
    }

    if (type == 'passport') {
      return passport != null;
    }

    return false;
  }

  validator() {
    return _con.selfie != null && documentValidator();
  }

  void showModal() {
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
                  "Select document type",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: Colors.black),
                ),
                SizedBox(height: 16),
                CustomButtons.filledButton(
                  text: 'National ID',
                  callback: () {
                    Navigator.pop(context);

                    Navigator.pushNamed(context, '/IDPicker').then((value) {
                      if (value != null) {
                        List<UploadIdModel> files =
                            value as List<UploadIdModel>;

                        idBack = files[1];
                        idFront = files[0];
                        type = 'idcard';
                        setState(() {});
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomButtons.outlineButton(
                  text: 'Passport',
                  callback: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/PassportPicker').then((
                      value,
                    ) {
                      if (value != null) {
                        UploadIdModel file = value as UploadIdModel;
                        passport = file;
                        type = 'passport';
                        setState(() {});
                      }
                    });
                    ;
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

  buttons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButtons.filledButton(
              text: 'Next',
              callback: () async {
                var result = await _con.VerifyID({
                  "selfie": _con.selfie?.fileLink,
                  "id_card": idFront?.fileLink,
                });
                if (result != null && result.canProceed == true) {
                  RegistrationDocumentsModel reg = RegistrationDocumentsModel(
                    selfie: _con.selfie!,
                    type: type,
                    idBack: idBack,
                    idFront: idFront,
                    passport: passport,
                    country: widget.country,
                  );
                  Navigator.pushNamed(
                    context,
                    '/VerifyDetails',
                    arguments: reg,
                  );
                } else {
                  CustomMessageHandler().showErrorSnakeBar(
                    context,
                    "Failed to verify your ID document",
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _con.scaffoldKey,
        bottomNavigationBar: validator() ? buttons() : null,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Constants.greyColor),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Lets get started!",
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Constants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  "To your verify your identity, please upload clear copies of your identification documents",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),

              // Text(error1),
              // Divider(),
              // Text(error2),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xfff6edff),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (_con.loading) {
                            return;
                          }

                          if (Platform.isAndroid) {
                            detectAndroid();
                          } else {
                            checkLiveness();
                          }
                          // takeImage();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Constants.secondaryColor.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                  child: _con.selfie == null
                                      ? Icon(Icons.refresh, color: Colors.white)
                                      : Container(
                                          height: 50,
                                          width: 50,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Take photo",
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          if (_con.loading) {
                            return;
                          }
                          showModal();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Constants.secondaryColor.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.withOpacity(0.4),
                                    ),
                                    child: documentValidator() == false
                                        ? Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                          )
                                        : Container(
                                            height: 50,
                                            width: 50,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.withOpacity(0.4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.photo_album_sharp,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Upload ID document",
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
