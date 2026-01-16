import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../helpers/Message.dart';
import '../widgets/CustomButtons.dart';
import 'controller/AddressController.dart';

class AddressesWidget extends StatefulWidget {


  const AddressesWidget({Key? key}) : super(key: key);

  @override
  _AddressesWidgetState createState() => _AddressesWidgetState();
}

class _AddressesWidgetState extends StateMVC<AddressesWidget> {

  late AddressController _con;

  _AddressesWidgetState() : super(AddressController()) {
    _con = controller as AddressController;
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForCustomerAddresses();
    _con.listenForProfileInfo();
    _con.listenForNextKin();
    _con.listenForDocumentTypes();
    _con.listenForCustomerDocuments();

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
          leading:  BackButton(color: Colors.black,onPressed: (){
            Navigator.pushNamed(context, '/Dashboard');


          },),
          title:  Text("Profile",style: TextStyle(color: Colors.black),),
        ),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [

              SizedBox(height: 12,),

            Center(
              child: Container(
                height: 90,width: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    image :_con.profileModel?.capturePhotoUrl==null?null: DecorationImage(image: NetworkImage(_con.profileModel?.capturePhotoUrl??""),fit: BoxFit.cover),
                    border: Border.all(
                      width: 3,
                      color: Constants.primaryColor,
                    ),
                  ),

              ),
            ),

              SizedBox(height: 12,),

              Row(children: [

                Expanded(
                  child: InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/Employment');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                            Icon(Icons.work,color: Constants.primaryColor,),
                              SizedBox(height: 5,),
                              AutoSizeText("Employment",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),maxLines: 1,)
                          ],),
                        )
                    ),
                  ),
                ),
SizedBox(width: 5,),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, '/Expenses');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Icon(Icons.money,color: Constants.primaryColor,),
                              const SizedBox(height: 5,),
                              AutoSizeText("Expenses",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),maxLines: 1,)
                            ],),
                        )
                    ),
                  ),
                ),

                SizedBox(width: 5,),
                Expanded(
                  child: InkWell(
                    onTap: (){
                      // Navigator.pushNamed(context, '/PaymentProfile');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Icon(Icons.credit_card,color: Constants.primaryColor,),
                              SizedBox(height: 5,),
                              AutoSizeText("Payment profiles",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),maxLines: 1,)
                            ],),
                        )
                    ),
                  ),
                )
              ],),

              SizedBox(height: 10,),
              Divider(color: Colors.grey.withOpacity(0.4),),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text("Personal information",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
                1==1?              Container(
                  width: 100,

                  child: CustomButtons.filledButton(text:_con.nextOfKinModel!=null?"Edit":"Add",callback: (){


                    Navigator.pushNamed(context, '/Personal').then((value) {


                      if(value!=null){
                        CustomMessageHandler().showSuccessSnakeBar(context, value as String);
                        _con.listenForCustomerAddresses();
                        _con.listenForProfileInfo();

                      }
                    });

                  }),
                ): Text("Edit",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,decoration: TextDecoration.underline),)


              ],),
              SizedBox(height: 10,),

              Row(
                children: [
                  Expanded(

                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text("Residential address",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
                              const SizedBox(height: 5,),
                            _con.addressModel!=null?  Text("${_con.addressModel?.addressLineOne} ${_con.addressModel?.addressLineTwo}",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),):   Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.grey.withOpacity(0.3),

                            )
                            ],),
                        )
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(

                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Next of Kin details",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
                                  1==1?              Container(
                                    width: 100,

                                    child: CustomButtons.filledButton(text:_con.nextOfKinModel!=null?"Edit":"Add",callback: (){


                                      Navigator.pushNamed(context, '/AddNextKin',arguments: _con.nextOfKinModel).then((value) {
                                        if(value!=null){
                                          CustomMessageHandler().showSuccessSnakeBar(context, value as String);
                                          _con.listenForNextKin();

                                        }
                                      });

                                    }),
                                  ): Text(_con.nextOfKinModel!=null?"Edit":"Add",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,decoration: TextDecoration.underline),)
                                ],
                              ),
                              const SizedBox(height: 5,),
                           _con.nextOfKinModel!=null? Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                             Text("${_con.nextOfKinModel?.nextOfKinName??""} ${_con.nextOfKinModel?.nextOfKinSurname}",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.w500),),
                             const SizedBox(height: 6,),

                             Text("${_con.nextOfKinModel?.nextOfKinCellNumber??""}. ${_con.nextOfKinModel?.nextOfKinEmailAddress}",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),

                           ],):  Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.grey.withOpacity(0.3),

                              )],),
                        )
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(

                    child: InkWell(

                      onTap: (){

                        if(_con.signatureDocumentTypeModel!=null&& _con.signature==null){

                          Navigator.pushNamed(context, '/Signature',arguments: _con.signatureDocumentTypeModel).then((value) {

                            if(value!=null){

                              CustomMessageHandler().showSuccessSnakeBar(context, value as String);

                            }
                          });


                        }
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text("Signature",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
                                const SizedBox(height: 5,),
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,


                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3),

                                    image:_con.signature==null?null: DecorationImage(

                                    image: NetworkImage(_con.signature?.fileUrl??""),fit: BoxFit.contain
                                  )
                                ),

                              )],),
                          )
                      ),
                    ),
                  ),
                ],
              )


            ],),
        ),
      ),
    );
  }
}
