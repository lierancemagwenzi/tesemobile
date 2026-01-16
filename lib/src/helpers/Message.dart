import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomMessageHandler{



  showSuccessSnakeBar(BuildContext context,String message){
    final snackBar = SnackBar(
      backgroundColor: Colors.green,
      content:  Text(message,style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

  showErrorSnakeBar(BuildContext context,String message){
    final snackBar = SnackBar(
      backgroundColor: Colors.redAccent,
      content:  Text(message,style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white)),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }
}