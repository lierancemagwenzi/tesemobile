import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:smacredit/src/content-creator/widgets/channels_widget.dart';
import 'package:smacredit/src/credit/controller/credit_controller.dart';
import 'package:smacredit/src/employment/models/ConfirmOTPResult.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/home/controller/HomeController.dart';
import 'package:smacredit/src/payments/widgets/paymentLinks.dart';
import 'package:smacredit/src/payments/widgets/payments_widget.dart';
import 'package:smacredit/src/home/widgets/dashboard.dart';
import 'package:smacredit/src/profile/widgets/profile.dart';

import '../addresses/AddAddressWidget.dart';
import '../addresses/AddressesWidget.dart';
import '../credit/CreditApplicationWidget.dart';
import '../employment/EmploymentHistoryWidget.dart';
import '../expenses/CustomerExpensesWidget.dart';
import '../models/constants.dart';
import '../scanner/IDScanner.dart';
import 'DashboardWidget.dart';

class HomeWidget extends StatefulWidget {
  final int? index;
  const HomeWidget({Key? key, this.index}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  late HomeController _con;

  _HomeWidgetState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  List<Widget> screens = [
    // Dashboard(),
    // PaymentsScreen(onPop: (){
    //   _setHome();
    // },),
    // ProfileScreen(
    //   onPop: () {
    //     _setHome();
    //   }
    // ),
    // Container(),
  ];
  int activeIndex = 0;

  // late CreditController _con;
  // String? imgPath;
  // _HomeWidgetState() : super(CreditController()) {
  //   _con = controller as CreditController;
  // }
  void _setHome() {
    setState(() {
      activeIndex = 0;
    });
  }

  void _goToProfile() {
    setState(() {
      activeIndex = 2;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      activeIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.index != null) {
      activeIndex = widget.index ?? 0;
    }
    // _con.listenForProfileInfo();

   
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _con.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        key: _con.scaffoldKey,
        bottomNavigationBar: _buildBottomNavBar(),
        backgroundColor: Constants.primaryColor,
        body: [
          Dashboard(
            onProfileTap: () {
              _goToProfile();
            },
          ),
          PaymentsScreen(
            onPop: () {
              _setHome();
            },
          ),

          ChannelListScreen(

               onPop: () {
              _setHome();
            },
          ),
          ProfileScreen(
            onPop: () {
              _setHome();
            },
          ),
          // Container(),
        ][activeIndex],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: activeIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Content',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
