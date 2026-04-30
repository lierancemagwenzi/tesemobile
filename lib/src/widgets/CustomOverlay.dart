import 'package:flutter/material.dart';

import '../models/constants.dart';

class CustomOverlay extends StatefulWidget {
  Widget child;
  String? text;
  bool loading;
  CustomOverlay({required this.child, required this.loading, this.text});

  @override
  _CustomOverlayState createState() => _CustomOverlayState();
}

class _CustomOverlayState extends State<CustomOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        widget.loading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // if (widget.text != null) ...[
                    //   Text(
                    //     widget.text!,
                    //     style: TextStyle(
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.w500,
                    //       fontSize: 16,
                    //     ),
                    //   ),

                    //   SizedBox(height: 10),
                    // ],
                    Card(
                      color: Constants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80),
                        //set border radius more than 50% of height and width to make circle
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(height: 0, width: 0),
      ],
    );
  }
}
