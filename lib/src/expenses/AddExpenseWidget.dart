import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/expenses/models/ExpenseModel.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../helpers/Validator.dart';
import '../models/constants.dart';
import '../widgets/CustomButtons.dart';
import 'controller/ExpenseController.dart';

class AddExpenseWidget extends StatefulWidget {
  ExpenseModel?
  expenseModel;

  String target;

   AddExpenseWidget({Key? key, this.expenseModel,required this.target}) : super(key: key);

  @override
  _AddExpenseWidgetState createState() => _AddExpenseWidgetState();
}

class _AddExpenseWidgetState extends StateMVC<AddExpenseWidget> {

  late ExpenseController _con;

  _AddExpenseWidgetState() : super(ExpenseController()) {
    _con = controller as ExpenseController;
  }

  String amount="";

  TextEditingController textEditingController=TextEditingController();



 getTitle(){


    if(widget.target=="userExpenseHousingCosts"){
      return "Housing costs";
    }

    else if(widget.target=="userExpenseUtilitiesCosts"){
      return "Utilities";
    }
    else if(widget.target=="userExpenseDebtPaymentsCosts"){
      return "Debt payments";
    }
    else if(widget.target=="userExpenseLivingExpensesCosts"){
      return "Living expenses";
    }
    else if(widget.target=="userExpenseSavingInvestmentsCosts"){
      return "Savings and investments";
    }
    else if(widget.target=="userExpenseOtherCosts"){
      return "Other expenses";
    }


    return widget.target;
  }

  getBody(){

    if(widget.target=="userExpenseHousingCosts"){
      return "Please enter your monthly housing costs here. This information will be used to calculate your monthly housing expenses. These may include mortgages and rentals";
    }

    else if(widget.target=="userExpenseUtilitiesCosts"){
      return "Please enter your monthly utilities here. This information will be used to calculate your monthly housing expenses. These may include electricity ,water and internet bills";
    }
    else if(widget.target=="userExpenseDebtPaymentsCosts"){
      return "Please enter your monthly housing costs here. This information will be used to calculate your monthly housing expenses. These may include child care ,healthcare and other expenses";
    }
    else if(widget.target=="userExpenseLivingExpensesCosts"){
      return "Please enter your monthly living expenses here. This information will be used to calculate your monthly housing expenses. These may include mortgages and rentals";
    }
    else if(widget.target=="userExpenseSavingInvestmentsCosts"){
      return "Please enter your monthly Savings and investments here. This information will be used to calculate your monthly housing expenses. These may include savings, retirement plans,investment accounts and others";
    }

    else if(widget.target=="userExpenseOtherCosts"){
      return "Please enter your  other monthly expenses";
    }
    return widget.target;
  }

  final _formKey = GlobalKey<FormState>();
  num getAmount(){

    if(widget.target=="userExpenseHousingCosts"){
      return  widget.expenseModel?.userExpenseHousingCosts??0;
    }

    else if(widget.target=="userExpenseUtilitiesCosts"){
      return  widget.expenseModel?.userExpenseUtilitiesCosts??0;
    }
    else if(widget.target=="userExpenseDebtPaymentsCosts"){
      return  widget.expenseModel?.userExpenseDebtPaymentsCosts??0;
    }
    else if(widget.target=="userExpenseLivingExpensesCosts"){
      return  widget.expenseModel?.userExpenseLivingExpensesCosts??0;
    }
    else if(widget.target=="userExpenseSavingInvestmentsCosts"){
      return  widget.expenseModel?.userExpenseSavingInvestmentsCosts??0;
    }

    else if(widget.target=="userExpenseOtherCosts"){
      return  widget.expenseModel?.userExpenseOtherCosts??0;
    }
    return 0;
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    textEditingController=TextEditingController(text: getAmount().toStringAsFixed(2));
  }

  doAction(){

    Map map={
      "id": widget.expenseModel?.id,
      "userId": currentuser.value.user?.id,
      "userExpenseHousingCosts": widget.expenseModel?.userExpenseHousingCosts??0,
      "userExpenseUtilitiesCosts":  widget.expenseModel?.userExpenseUtilitiesCosts??0,
      "userExpenseDebtPaymentsCosts":  widget.expenseModel?.userExpenseDebtPaymentsCosts??0,
      "userExpenseLivingExpensesCosts":  widget.expenseModel?.userExpenseLivingExpensesCosts??0,
      "userExpenseSavingInvestmentsCosts":  widget.expenseModel?.userExpenseSavingInvestmentsCosts??0,
      "userExpenseOtherCosts":  widget.expenseModel?.userExpenseOtherCosts??0

    };
    map[widget.target]=amount;
    if(widget.expenseModel!=null){



      _con.updateExpense(map);
    }
    else{
      _con.addExpense(map);
    }

  }
  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,

        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                CustomButtons.filledButton(text:'Save Expense',callback: (){

                  if(_formKey.currentState!.validate()){
                    _formKey.currentState!.save();
                    doAction();
                  }

                }),
                const SizedBox(height: 16,),

                const SizedBox(height: 24,)
              ],),
          ),
        ),
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black,),
          title:  const Text("Expenses",style: TextStyle(color: Colors.black),),
        ),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(getTitle(),style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black,fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Text(getBody(),style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black,fontWeight: FontWeight.normal),), SizedBox(height: 10,),
                const SizedBox(height: 12,),
                TextFormField(
                  controller: textEditingController,
                  onSaved: (value){

                    amount=value!;
                  },
                  validator: (value){
                    return Validator.validateNum(value);
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
                    hintText: "Amount",
                    fillColor: Constants.textFieldColor,
                  ),
                ),
                const SizedBox(height: 12,),

              ],),
          ),
        ),
      ),
    );
  }
}
