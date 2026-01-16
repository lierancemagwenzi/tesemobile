import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smacredit/src/addresses/controller/AddressController.dart';
import 'package:smacredit/src/addresses/models/DocumentTypeModel.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:smacredit/src/models/constants.dart';

class SignatureWidget extends StatefulWidget {

  DocumentTypeModel documentTypeModel;
   SignatureWidget({Key? key,required this.documentTypeModel}) : super(key: key);

  @override
  _SignatureWidgetState createState() => _SignatureWidgetState();
}

class _SignatureWidgetState extends StateMVC<SignatureWidget> {

  ByteData _img = ByteData(0);
  var color = Colors.black;
  var strokeWidth = 3.0;
  final _sign = GlobalKey<SignatureState>();


  late AddressController _con;

  _SignatureWidgetState() : super(AddressController()) {
    _con = controller as AddressController;
  }

 writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
   File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)).then((value) {


          if(value!=null){

            print(value.existsSync());

            if(value!=null){
              _con.uploadDocument(widget.documentTypeModel,value!);
            }
          }
        });


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
key: _con.scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black,),
        title: const Text("Add signature",style: TextStyle(color: Colors.black),),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.black12,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Signature(
                      color: color,
                      key: _sign,
                      onSign: () {
                        final sign = _sign.currentState;
                        debugPrint('${sign?.points.length} points in the signature');
                      },
                      // backgroundPainter: _WatermarkPaint("2.0", "2.0"),
                      strokeWidth: strokeWidth,
                    ),
                  ),
                ),
              ),
              _img.buffer.lengthInBytes == 0 ? Container() : LimitedBox(maxHeight: 200.0, child: Image.memory(_img.buffer.asUint8List())),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MaterialButton(
                          color: Constants.secondaryColor,
                          onPressed: () {
                            final sign = _sign.currentState;
                            sign?.clear();
                            setState(() {
                              _img = ByteData(0);
                            });
                            debugPrint("cleared");
                          },
                          child: Text("Clear signature",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),)),
                      SizedBox(width: 10,),

                      MaterialButton(
                          color: Constants.primaryColor,

                          onPressed: () async {
                            final sign = _sign.currentState;
                            //retrieve image data, do whatever you want with it (send to server, save locally...)
                            final image = await sign?.getData();
                            var data = await image?.toByteData(format: ui.ImageByteFormat.png);
                            sign?.clear();
                            final encoded = base64.encode(data?.buffer.asUint8List() as List<int>);
                            setState(() {
                              _img = data!;
                            });

                            Directory tempDir = await getTemporaryDirectory();
                            String tempPath = tempDir.path;
                            writeToFile(data!,"$tempPath/signature.png");
                            // _con.uploadSignature({"user_id":currentuser.value.id!,"signature":encoded});
                            debugPrint("onPressed " + encoded);
                          },
                          child:  Text("Save and upload",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white))),

                    ],
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: <Widget>[
                  //     MaterialButton(
                  //         onPressed: () {
                  //           setState(() {
                  //             color = color == Colors.green ? Colors.red : Colors.green;
                  //           });
                  //           debugPrint("change color");
                  //         },
                  //         child: Text("Change color")),
                  //     MaterialButton(
                  //         onPressed: () {
                  //           setState(() {
                  //             int min = 1;
                  //             int max = 10;
                  //             int selection = min + (Random().nextInt(max - min));
                  //             strokeWidth = selection.roundToDouble();
                  //             debugPrint("change stroke width to $selection");
                  //           });
                  //         },
                  //         child: Text("Change stroke width")),
                  //   ],
                  // ),
                ],
              )
            ],
          ),
          _con.loading?const Center(child: CircularProgressIndicator()):SizedBox(height: 0,)
        ],
      ),

    );
  }
}
