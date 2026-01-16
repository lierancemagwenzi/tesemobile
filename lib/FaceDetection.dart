import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:mnc_identifier_face/mnc_identifier_face.dart';
// import 'package:mnc_identifier_face/model/liveness_detection_result_model.dart';

class FaceDetectionWidget extends StatefulWidget {

  const FaceDetectionWidget({Key? key}) : super(key: key);

  @override
  _FaceDetectionWidgetState createState() => _FaceDetectionWidgetState();
}

class _FaceDetectionWidgetState extends State<FaceDetectionWidget> {


  Future<void> startDetection() async {
    try {
      // LivenessDetectionResult livenessResult =
      // await MncIdentifierFace().startLivenessDetection();
      // debugPrint("result is ${livenessResult.toJson().toString()}");
    } catch (e) {
      debugPrint('Something goes unexpected with error is $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(



      appBar: AppBar(title: const Text("Liveness test"),),


      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(


          mainAxisAlignment: MainAxisAlignment.center,
          children: [




          InkWell(

            onTap: (){
              startDetection();

            },
            child: Container(
              color: Colors.black,
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Center(child: Text("Test face")),
            ),
          )

        ],),
      )
      ,
    );
  }
}
