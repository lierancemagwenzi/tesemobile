import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/CustomButtons.dart';

class PendingVerificationWidget extends StatefulWidget {

  const PendingVerificationWidget({Key? key}) : super(key: key);

  @override
  _PendingVerificationWidgetState createState() => _PendingVerificationWidgetState();
}

class _PendingVerificationWidgetState extends State<PendingVerificationWidget> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButtons.filledButton(text:'Okay',callback: (){

                  Navigator.pushNamed(context, '/Dashboard');
                }),
                const SizedBox(height: 16,),

                const SizedBox(height: 24,)
              ],),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              Icon(Icons.check_circle,color: Colors.green,size: 50,),

            SizedBox(height: 10,),
            Text("Pending employer approval",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
            SizedBox(height: 5,),
            Text("Your information is currently being reviewed. We will notify you as soon as we have an update",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.normal),textAlign: TextAlign.center,)
          ],),
        ),
      ),
    );
  }
}
