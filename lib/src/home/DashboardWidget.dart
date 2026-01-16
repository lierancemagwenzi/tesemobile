import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smacredit/src/home/controller/HomeController.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../models/constants.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends StateMVC<DashboardWidget> {
  late HomeController _con;

  _DashboardWidgetState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // _con.listenForDashboardInfo();
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.notifications, color: Colors.black),
            ),
          ],
          // leading: const BackButton(color: Colors.black,),
          title: InkWell(
            onTap: () {
              // Navigator.pushNamed(context, '/Personal');
            },

            child: Text("Smatpay", style: TextStyle(color: Colors.black)),
          ),
        ),

        //         body: Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child:

        //           Column(children: [

        //             SizedBox(height: 12,),

        //             Row(children: [
        //               CircularPercentIndicator(
        //                 radius: 60.0,
        //                 lineWidth: 5.0,
        //                 percent: 0.6,
        //                 center:  Text("${_con.dashboardModel?.data?.profileCompletionLevel??0} %",style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Constants.primaryColor),),
        //                 progressColor: Constants.primaryColor,
        //               ),

        //               SizedBox(width: 10,),
        //               Expanded(

        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: [

        //                     InkWell(

        //                       onTap: (){
        //                         Navigator.pushNamed(context, '/Profile');
        //                       },
        //                       child: Container(
        //                           decoration: BoxDecoration(
        //                             border: Border.all(
        //                               color: Constants.primaryColor.withOpacity(0.4),

        //                             ),
        //                             borderRadius: BorderRadius.circular(20),
        //                           ),
        //                           child: Padding(
        //                             padding: const EdgeInsets.symmetric(vertical: 4.0,horizontal: 8),
        //                             child: Row(children: [
        //                               Text("Finish registration",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),),

        // SizedBox(width: 5,),
        //                               Icon(Icons.arrow_forward,color: Constants.primaryColor,)
        //                             ],),
        //                           )
        //                       ),
        //                     ),
        //                     const SizedBox(height: 5,),
        //                     AutoSizeText("Please finish the remaining steps to complete your registration",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),maxLines: 2,)
        //                   ],),
        //               ),
        //             ],),
        //             SizedBox(height: 20,),
        //             Row(children: [

        //               Expanded(
        //                 child: InkWell(
        //                   onTap: (){
        //                     // Navigator.pushNamed(context, '/Expenses');
        //                   },
        //                   child: Container(
        //                       decoration: BoxDecoration(
        //                         color: Colors.white,
        //                         border: Border.all(
        //                           color: Colors.transparent,
        //                         ),
        //                         borderRadius: BorderRadius.circular(10),
        //                       ),
        //                       child: Padding(
        //                         padding: const EdgeInsets.all(8.0),
        //                         child: Row(
        //                           crossAxisAlignment: CrossAxisAlignment.center,
        //                           children: [

        //                             Container(
        //                                 decoration: BoxDecoration(
        //                                     color: Constants.secondaryColor,
        //                                     border: Border.all(
        //                                       color: Colors.transparent,
        //                                     ),
        //                                     shape: BoxShape.circle
        //                                 ),
        //                                 child: Padding(
        //                                   padding: const EdgeInsets.all(4.0),
        //                                   child: Icon(Icons.credit_card,color: Colors.white,),
        //                                 )
        //                             ),
        //                             SizedBox(width: 10,),
        //                             Column(
        //                               mainAxisAlignment: MainAxisAlignment.center,
        //                               crossAxisAlignment: CrossAxisAlignment.start,
        //                               children: [

        //                                 Text("${_con.dashboardModel?.data?.creditLines??0}",style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Constants.secondaryColor,fontWeight: FontWeight.bold),),
        //                                 const SizedBox(height: 5,),
        //                                 Text("Credit lines",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),)
        //                               ],),
        //                           ],
        //                         ),
        //                       )
        //                   ),
        //                 ),
        //               ),
        //               SizedBox(width: 5,),
        //               Expanded(
        //                 child: InkWell(
        //                   onTap: (){
        //                     // Navigator.pushNamed(context, '/Expenses');
        //                   },
        //                   child: Container(
        //                       decoration: BoxDecoration(
        //                         color: Colors.white,
        //                         border: Border.all(
        //                           color: Colors.transparent,
        //                         ),
        //                         borderRadius: BorderRadius.circular(10),
        //                       ),
        //                       child: Padding(
        //                         padding: const EdgeInsets.all(8.0),
        //                         child: Row(
        //                           crossAxisAlignment: CrossAxisAlignment.center,
        //                           children: [

        //                             Container(
        //                                 decoration: BoxDecoration(
        //                                   color: Constants.secondaryColor,
        //                                   border: Border.all(
        //                                     color: Colors.transparent,
        //                                   ),
        //                            shape: BoxShape.circle
        //                                 ),
        //                                 child: Padding(
        //                                   padding: const EdgeInsets.all(4.0),
        //                                   child: Icon(Icons.money,color: Colors.white,),
        //                                 )
        //                             ),
        //                             SizedBox(width: 10,),
        //                             Column(
        //                               mainAxisAlignment: MainAxisAlignment.center,
        //                               crossAxisAlignment: CrossAxisAlignment.start,
        //                               children: [

        //                                 Text("${_con.dashboardModel?.data?.totalExposures??0}",style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Constants.secondaryColor,fontWeight: FontWeight.bold),),
        //                                 const SizedBox(height: 5,),
        //                                 Text("Total exposure",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),)
        //                               ],),
        //                           ],
        //                         ),
        //                       )
        //                   ),
        //                 ),
        //               ),

        //             ],),

        //             SizedBox(height: 20,),

        //             Container(
        //                 decoration: BoxDecoration(
        //                   gradient: const LinearGradient(
        //                     begin: Alignment.centerLeft,
        //                     end: Alignment.centerRight,
        //                     colors: <Color>[
        //                       Constants.primaryColor,
        //                       Constants.secondaryColor,
        //                     ],
        //                   ),
        //                   border: Border.all(
        //                     color: Colors.transparent,
        //                   ),
        //                   borderRadius: BorderRadius.circular(10),
        //                 ),
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Column(children: [
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       children: [

        // Icon(Icons.check_circle_outline,color: Colors.white,),
        //                       Icon(Icons.more_horiz,color: Colors.white,),

        //                     ],),

        //                     SizedBox(height: 10,),
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       crossAxisAlignment: CrossAxisAlignment.center,
        //                       children: [
        //                         Column(
        //                           mainAxisAlignment: MainAxisAlignment.center,
        //                           crossAxisAlignment: CrossAxisAlignment.start,
        //                           children: [

        //                             AutoSizeText("Disposable income remaining",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
        //                             const SizedBox(height: 5,),
        //                             Text("\$${_con.dashboardModel?.data?.disposableIncomeRemaining??0}",style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),)
        //                           ],),
        //                         SizedBox(width: 10,),
        //                         Icon(Icons.stacked_line_chart,size: 70,color: Colors.white,)
        //                       ],
        //                     )

        //                   ],),
        //                 )
        //             ),
        //             SizedBox(height: 20,),

        //           _con.dashboardModel?.data?.statusOfProofOfResidence==true?   Container(
        //                 decoration: BoxDecoration(
        //                   color: Colors.green.withOpacity(0.3),

        //                   border: Border.all(
        //                     color: Colors.transparent,
        //                   ),
        //                   borderRadius: BorderRadius.circular(10),
        //                 ),
        //                 child: Padding(
        //                   padding: const EdgeInsets.all(8.0),
        //                   child: Row(
        //                     crossAxisAlignment: CrossAxisAlignment.center,
        //                     children: [

        //                       Container(
        //                           decoration: BoxDecoration(
        //                               color: Colors.green,
        //                               border: Border.all(
        //                                 color: Colors.transparent,
        //                               ),
        //                               shape: BoxShape.circle
        //                           ),
        //                           child: Padding(
        //                             padding: const EdgeInsets.all(4.0),
        //                             child: Icon(Icons.done,color: Colors.white,),
        //                           )
        //                       ),
        //                       SizedBox(width: 10,),
        //                       Column(
        //                         mainAxisAlignment: MainAxisAlignment.center,
        //                         crossAxisAlignment: CrossAxisAlignment.start,
        //                         children: [
        //                           Text("Proof residence approved",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),)
        //                         ],),
        //                     ],
        //                   ),
        //                 )
        //             ): Container(
        //              decoration: BoxDecoration(
        //                color: Colors.red.withOpacity(0.3),

        //                border: Border.all(
        //                  color: Colors.transparent,
        //                ),
        //                borderRadius: BorderRadius.circular(10),
        //              ),
        //              child: Padding(
        //                padding: const EdgeInsets.all(8.0),
        //                child: Row(
        //                  crossAxisAlignment: CrossAxisAlignment.center,
        //                  children: [

        //                    Container(
        //                        decoration: BoxDecoration(
        //                            color: Colors.red,
        //                            border: Border.all(
        //                              color: Colors.transparent,
        //                            ),
        //                            shape: BoxShape.circle
        //                        ),
        //                        child: Padding(
        //                          padding: const EdgeInsets.all(4.0),
        //                          child: Icon(Icons.close,color: Colors.white,),
        //                        )
        //                    ),
        //                    SizedBox(width: 10,),
        //                    Column(
        //                      mainAxisAlignment: MainAxisAlignment.center,
        //                      crossAxisAlignment: CrossAxisAlignment.start,
        //                      children: [
        //                        Text("Proof residence pending",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),)
        //                      ],),
        //                  ],
        //                ),
        //              )
        //          )
        //           ],),
        //         ),
      ),
    );
  }
}
