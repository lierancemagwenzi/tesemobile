import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';

class EmployerDetailsWidget extends StatefulWidget {
  CustomerEmployerModel customerEmployerModel;
  EmployerDetailsWidget({Key? key, required this.customerEmployerModel})
    : super(key: key);

  @override
  _EmployerDetailsWidgetState createState() => _EmployerDetailsWidgetState();
}

class _EmployerDetailsWidgetState extends State<EmployerDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Employer details",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Employment name",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "${widget.customerEmployerModel.employerName}",
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.black),
            ),
            SizedBox(height: 5),
            Divider(color: Colors.grey),

            SizedBox(height: 5),

            Text(
              "Employment type",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "${widget.customerEmployerModel.employmentType}",
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.black),
            ),
            SizedBox(height: 5),
            Divider(color: Colors.grey),

            SizedBox(height: 5),

            Text(
              "Position",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "${widget.customerEmployerModel.employerCurrentPosition}",
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.black),
            ),
            SizedBox(height: 5),
            Divider(color: Colors.grey),

            SizedBox(height: 5),

            Text(
              "Gross income",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "${widget.customerEmployerModel.employerGrossMonthlyIncome}",
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.black),
            ),
            SizedBox(height: 5),
            Divider(color: Colors.grey),

            SizedBox(height: 5),

            Text(
              "Net income",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "${widget.customerEmployerModel.employerNetMonthlyIncome}",
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: Colors.black),
            ),
            SizedBox(height: 5),
            Divider(color: Colors.grey),

            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
