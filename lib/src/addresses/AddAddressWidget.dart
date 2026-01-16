import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';
// import 'package:file_picker/file_picker.dart';
import '../helpers/Validator.dart';
import '../models/constants.dart';
import '../widgets/CustomButtons.dart';
import 'controller/AddressController.dart';

class AddAddressWidget extends StatefulWidget {

  const AddAddressWidget({Key? key}) : super(key: key);

  @override
  _AddAddressWidgetState createState() => _AddAddressWidgetState();
}

class _AddAddressWidgetState extends StateMVC<AddAddressWidget> {


  late AddressController _con;

  _AddAddressWidgetState() : super(AddressController()) {
    _con = controller as AddressController;
  }

  final _formKey = GlobalKey<FormState>();
String address_line2="";
String address_1="";

File? file;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.listenForCustomerAddresses();
    _con.listenForCustomerDocuments();
    _con.listenForDocumentTypes();
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black,),
          title:  InkWell(

              onTap: (){
                // Navigator.pushNamed(context, '/Personal');
              },

              child: const Text("Personal information",style: TextStyle(color: Colors.black),)),
        ),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(

            child: Form(
              key: _formKey,
              child: Column(children: [


                const SizedBox(height: 12,),

                TextFormField(
                  controller: _con.address1Controller,
                  onSaved: (value){

                    address_1=value!;
                  },
                  validator: (value){
                    return Validator.validateRequired(value);
                  },
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),

                      borderSide: const BorderSide(
                        color: Constants.greyColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),

                      borderSide: const BorderSide(
                        color: Constants.greyColor,
                      ),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey[800],fontWeight: FontWeight.w500),
                    hintText: "Address",
                    fillColor: Constants.textFieldColor,
                  ),
                ),
                const SizedBox(height: 12,),

                TextFormField(
                  controller: _con.address2Controller,
                  onSaved: (value){

                    address_line2=value!;
                  },
                  validator: (value){
                    return Validator.validateRequired(value);
                  },
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),

                      borderSide: const BorderSide(
                        color: Constants.greyColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),

                      borderSide: const BorderSide(
                        color: Constants.greyColor,
                      ),
                    ),
                    filled: true,
                    hintStyle: TextStyle(color: Colors.grey[800],fontWeight: FontWeight.w500),
                    hintText: "Address line 2",
                    fillColor: Constants.textFieldColor,
                  ),
                ),

                const SizedBox(height: 12,),

                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      CustomButtons.filledButton(text:'Save information',callback: (){

                        if(_formKey.currentState!.validate()){
                          _formKey.currentState!.save();

                          Map map=  {
                            "id": _con.addressModel?.id,
                            "addressLineOne": address_1,
                            "addressLineTwo": address_line2,
                            "userId": currentuser.value.user?.id
                          };


                          if(_con.addressModel==null){
                            _con.addAddress(
                                map
                            );
                          }
                          else{
                            _con.updateAddress(
                                map
                            );
                          }
                        }




                      }),
                      const SizedBox(height: 16,),

                      const SizedBox(height: 24,)
                    ],),
                ),

                const SizedBox(height: 12,),

                InkWell(

                  onTap: () async {

                    // FilePickerResult? result = await FilePicker.platform.pickFiles(
                    //   allowMultiple: false,
                    //   type: FileType.custom,
                    //   allowedExtensions: ['jpg', 'pdf', 'doc'],
                    // );
                    //
                    // if(result!=null){
                    //   try{
                    //     file=File(result.files.first.path??"");
                    //     setState(() {
                    //
                    //     });
                    //   }
                    //
                    //   catch(e){}
                    // }

                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),

                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(children: [
                          const Icon(Icons.attach_file),
                          const SizedBox(width: 10,),
                          Text("Attach proof of residence",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),)
                        ],),
                      )
                  ),
                ),
                const SizedBox(height: 12,),
                file!=null?Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButtons.filledButton(text:'Upload',callback: (){
                        if(file!=null){
                          _con.uploadDocument(_con.documentType!,file!);
                        }
                      }),
                      const SizedBox(height: 16,),

                      const SizedBox(height: 24,)
                    ],),
                ):const SizedBox(height: 0,width: 0,),
              ],),
            ),
          ),
        ),

      ),
    );
  }
}
