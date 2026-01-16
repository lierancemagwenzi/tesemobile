import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/expenses/AddExpenseWidget.dart';
import 'package:smacredit/src/expenses/controller/ExpenseController.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../helpers/Message.dart';
import '../models/constants.dart';

class CustomerExpensesWidget extends StatefulWidget {

  const CustomerExpensesWidget({Key? key}) : super(key: key);

  @override
  _CustomerExpensesWidgetState createState() => _CustomerExpensesWidgetState();
}

class _CustomerExpensesWidgetState extends StateMVC<CustomerExpensesWidget> {

  late ExpenseController _con;

  _CustomerExpensesWidgetState() : super(ExpenseController()) {
    _con = controller as ExpenseController;
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForEmployerList();
    // _con.addExpense(
    //
    //     {
    //
    //       "id": null,
    //
    //       "userId": currentuser.value.user?.id,
    //
    //       "userExpenseHousingCosts": 1.00,
    //
    //       "userExpenseUtilitiesCosts": 1.00,
    //
    //       "userExpenseDebtPaymentsCosts": 1.00,
    //
    //       "userExpenseLivingExpensesCosts": 1.00,
    //
    //       "userExpenseSavingInvestmentsCosts": 1.00
    //
    //     }
    // );
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
          title:  const Text("Expenses",style: TextStyle(color: Colors.black),),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children:  [


            Row(children: [


              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient:  const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[
                        Constants.primaryColor,
                        Constants.secondaryColor,
                      ],
                    ),
                    // color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),

                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10,),
                        Text("\$1200",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),

                        Text("Total income",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),textAlign: TextAlign.center,),

                      ],),
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),

                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10,),
                        Text("\$300",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),

                        Text("Total expenses",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),textAlign: TextAlign.center,),

                      ],),
                  ),
                ),
              ),

            ],),

SizedBox(height: 20,),
Container(

  decoration: BoxDecoration(
      color: Colors.green,
      border: Border.all(
        color: Colors.green,
      ),
      borderRadius: BorderRadius.circular(10),
  ),

  child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
Icon(Icons.check_circle_outline,color: Colors.white,),
        Expanded(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            Text("\$300",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.bold),),
            const SizedBox(height: 5,),
            Text("Disposable income",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white,fontWeight: FontWeight.w600),),

          ],),
        )
      ],),
  ),
),
            const SizedBox(height: 12,),

            InkWell(

              onTap: (){
                // Navigator.pushNamed(context, '/Expenses');
              },
              child: Container(

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),

                  ),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [


                    Text("Expenses",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.w600),),
                    const SizedBox(height: 5,),
                    Text("Click to add your expenses",style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),
                    const SizedBox(height: 12,),

                    Row(children: [

                   Expanded(child:    expenseWidget(Colors.blueAccent,"Housing costs",(_con.expenseModel?.userExpenseHousingCosts??0.0).toStringAsFixed(2),Icons.house,"userExpenseHousingCosts"),),
                      Expanded(child:    expenseWidget(Colors.pinkAccent,"Utilities",(_con.expenseModel?.userExpenseUtilitiesCosts??0.0).toStringAsFixed(2),Icons.water_drop,"userExpenseUtilitiesCosts"),),

                      Expanded(child:    expenseWidget(Colors.red,"Debt payments",(_con.expenseModel?.userExpenseDebtPaymentsCosts??0.0).toStringAsFixed(2),Icons.email,"userExpenseDebtPaymentsCosts"),)



                    ],),

                      const SizedBox(height: 12,),

                      Row(

                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          Expanded(child:   expenseWidget(Colors.blueAccent,"Living expenses",(_con.expenseModel?.userExpenseLivingExpensesCosts??0.0).toStringAsFixed(2),Icons.settings_input_antenna,"userExpenseLivingExpensesCosts")),
                      Expanded(child:   expenseWidget(Colors.pinkAccent,"Investment costs",(_con.expenseModel?.userExpenseSavingInvestmentsCosts??0.0).toStringAsFixed(2),Icons.money_rounded,"userExpenseSavingInvestmentsCosts")),
                        Expanded(child:   expenseWidget(Colors.pinkAccent,"Other expenses",(_con.expenseModel?.userExpenseOtherCosts??0.0).toStringAsFixed(2),Icons.money_rounded,"userExpenseOtherCosts")),


SizedBox(width: 10,)

                      ],)
                  ],),
                ),
              ),
            )


          ],),
        ),
      ),
    );
  }


  expenseWidget(Color color,String title,String amounnt,IconData icons,String target){


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(

        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  AddExpenseWidget(expenseModel: _con.expenseModel, target: target)),

          ).then((value) {

            if(value!=null){


              CustomMessageHandler().showSuccessSnakeBar(context, value as String);
              _con.listenForEmployerList();

            }

          });

        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
            ),

            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Container(

                  decoration: BoxDecoration(
                    color: color.withOpacity(0.3),

                shape: BoxShape.circle
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(icons,color: color,size: 30,),
                  )),
              SizedBox(height: 10,),
              Text(amounnt,style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),

              AutoSizeText(title,style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),textAlign: TextAlign.center,maxLines: 1,),

            ],),
          ),
        ),
      ),
    );
  }
}
