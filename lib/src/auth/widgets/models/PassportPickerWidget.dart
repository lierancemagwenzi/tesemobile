import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/constants.dart';
import '../../../widgets/CustomButtons.dart';

class PassportPickerWidget extends StatefulWidget {

  const PassportPickerWidget({Key? key}) : super(key: key);

  @override
  _PassportPickerWidgetState createState() => _PassportPickerWidgetState();
}

class _PassportPickerWidgetState extends State<PassportPickerWidget> {
  final ImagePicker picker = ImagePicker();

  File? frontImage;
  pickImage(String type) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if(image!=null){
      File file=File(image.path);
      if(mounted){
        setState(() {
          frontImage=file;


        });
      }


    }
  }
  takeImage(String type) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if(image!=null){
      File file=File(image.path);
      if(mounted) {
        setState(() {
          frontImage = file;

        });
      }
    }
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
                Text("Select an option",style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black),),
                const SizedBox(height: 16,),
                CustomButtons.filledButton(text:'Pick from gallery',callback: (){
Navigator.pop(context);
                  pickImage(type);
                }),
                const SizedBox(height: 16,),
                CustomButtons.outlineButton(text:'Capture image',callback: (){
                  Navigator.pop(context);
                 takeImage(type);
                }),
                const SizedBox(height: 24,)
              ],),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Constants.greyColor,),
      ),
      bottomNavigationBar:frontImage!=null? Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButtons.filledButton(text:'Done',callback: (){
                Navigator.pop(context,frontImage);
              }),
              const SizedBox(height: 24,)
            ],),
        ),
      ):null,

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [


          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Passport Image",style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black),),
              const SizedBox(height: 16,),

             frontImage!=null? Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,

                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.check,color: Colors.white,),
                ),
              ):SizedBox(height: 0,width: 0,),
              SizedBox(height: 8,),
              CustomButtons.filledButton(text:'Passport Image',callback: (){
                showModal('front');

              }),


              const SizedBox(height: 24,)
            ],)


        ],),
      ),




    );
  }
}
