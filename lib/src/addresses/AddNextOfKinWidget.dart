import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/addresses/NextOfKinModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../helpers/Validator.dart';
import '../models/constants.dart';
import '../widgets/CustomButtons.dart';
import 'controller/AddressController.dart';

class AddNextOfKinWidget extends StatefulWidget {


  NextOfKinModel? nextOfKinModel;
   AddNextOfKinWidget({Key? key,this.nextOfKinModel}) : super(key: key);

  @override
  _AddNextOfKinWidgetState createState() => _AddNextOfKinWidgetState();
}

class _AddNextOfKinWidgetState extends StateMVC<AddNextOfKinWidget> {

  late AddressController _con;

  _AddNextOfKinWidgetState() : super(AddressController()) {
    _con = controller as AddressController;
  }
  final _formKey = GlobalKey<FormState>();

String nextOfKinName="";
  String nextOfKinSurname="";
  String nextOfKinCellNumber="";
  String nextOfKinEmailAddress="";
  String nextOfKinAddress="";


  TextEditingController nextOfKinNameController=TextEditingController();
  TextEditingController nextOfKinSurnameController=TextEditingController();
  TextEditingController nextOfKinCellNumberController=TextEditingController();
  TextEditingController nextOfKinAddressController=TextEditingController();
  TextEditingController nextOfKinEmailAddressController=TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.nextOfKinModel!=null){
      nextOfKinNameController.text=widget.nextOfKinModel?.nextOfKinName??"";
      nextOfKinSurnameController.text=widget.nextOfKinModel?.nextOfKinSurname??"";
      nextOfKinCellNumberController.text=widget.nextOfKinModel?.nextOfKinCellNumber??"";
      nextOfKinAddressController.text=widget.nextOfKinModel?.nextOfKinAddress??"";
      nextOfKinEmailAddressController.text=widget.nextOfKinModel?.nextOfKinEmailAddress??"";
    }
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

              child: const Text("Add next of kin",style: TextStyle(color: Colors.black),)),
        ),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(

            child: Form(
              key: _formKey,
              child: Column(children: [


                const SizedBox(height: 12,),

                TextFormField(
                  controller: nextOfKinNameController,
                  onSaved: (value){

                    nextOfKinName=value!;
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
                    hintText: "First name",
                    fillColor: Constants.textFieldColor,
                  ),
                ),
                const SizedBox(height: 12,),

                TextFormField(
                  controller: nextOfKinSurnameController,
                  onSaved: (value){

                    nextOfKinSurname=value!;
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
                    hintText: "Last name",
                    fillColor: Constants.textFieldColor,
                  ),
                ),
                const SizedBox(height: 12,),

                TextFormField(
                  controller: nextOfKinCellNumberController,
                  onSaved: (value){

                    nextOfKinCellNumber=value!;
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
                    hintText: "Cell number",
                    fillColor: Constants.textFieldColor,
                  ),
                ),
                const SizedBox(height: 12,),
                TextFormField(
                  controller: nextOfKinEmailAddressController,
                  onSaved: (value){

                    nextOfKinEmailAddress=value!;
                  },
                  validator: (value){
                    return Validator.validateEmail(value);
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
                    hintText: "Email address",
                    fillColor: Constants.textFieldColor,
                  ),
                ),
                const SizedBox(height: 12,),

                TextFormField(
                  controller: nextOfKinAddressController,
                  onSaved: (value){

                    nextOfKinAddress=value!;
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
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      CustomButtons.filledButton(text:'Save information',callback: (){

                        if(_formKey.currentState!.validate()){
                          _formKey.currentState!.save();

                          Map map=  {
                            "id": widget.nextOfKinModel?.id,
                            "nextOfKinName": nextOfKinName,
                            "nextOfKinSurname":nextOfKinSurname,
                            "nextOfKinCellNumber": nextOfKinCellNumber,
                            "nextOfKinEmailAddress": nextOfKinEmailAddress,
                            "nextOfKinAddress":nextOfKinAddress,
                            "userId": currentuser.value.user?.id
                          };
                          if(widget.nextOfKinModel==null){
                            _con.addNextOfKin(
                                map
                            );
                          }
                          else{
                            _con.updateNextOfKin(
                                map
                            );
                          }
                        }




                      }),
                      const SizedBox(height: 16,),

                      const SizedBox(height: 24,)
                    ],),
                ),


              ],),
            ),
          ),
        ),
      ),
    );
  }
}
