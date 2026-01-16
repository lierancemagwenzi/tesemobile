// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:m7_livelyness_detection/m7_livelyness_detection.dart';
//
// main(){
//
//
//   return runApp(TestWidget());
//
// }
//
// class TestWidget extends StatefulWidget {
//
//   const TestWidget({Key? key}) : super(key: key);
//
//   @override
//   _TestWidgetState createState() => _TestWidgetState();
// }
//
// class _TestWidgetState extends State<TestWidget> {
//
//
//   check()async{
//
//     final M7CapturedImage? response =
//         await M7LivelynessDetection.instance.detectLivelyness(
//       context,
//       config: M7DetectionConfig(
//         steps: [
//           M7LivelynessStepItem(
//             step: M7LivelynessStep.blink,
//             title: "Blink",
//             isCompleted: false,
//           ),
//           M7LivelynessStepItem(
//             step: M7LivelynessStep.smile,
//             title: "Smile",
//             isCompleted: false,
//           ),
//
//           // M7LivelynessStepItem(
//           //   step: M7LivelynessStep.turnLeft,
//           //   title: "TurnLeft",
//           //   isCompleted: false,
//           // ),
//           // M7LivelynessStepItem(
//           //   step: M7LivelynessStep.turnRight,
//           //   title: "TunRight",
//           //   isCompleted: false,
//           // ),
//         ],
//         startWithInfoScreen: false,
//       ),
//     );
// print("response_is ${response?.toJson().toString()}");
//     if(response!=null){
//
//       print(response.toJson().toString());
//     }
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: InkWell(
//
//             onTap: (){
//
//               check();
//             },
//             child: Container(
//
//
//
//               height: 200,
//               width: 200,
//
//
//               color: Colors. black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
