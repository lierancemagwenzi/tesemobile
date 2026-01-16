import 'package:flutter/material.dart';
import 'package:flutter_liveness_detection_randomized_plugin/flutter_liveness_detection_randomized_plugin.dart';
import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:smacredit/src/credit/controller/credit_controller.dart';
import 'package:smacredit/src/credit/models/CreditApplication.dart';
import 'package:smacredit/src/employment/models/ConfirmOTPResult.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class CreditApplicationWidget extends StatefulWidget {
  const CreditApplicationWidget({Key? key}) : super(key: key);

  @override
  _CreditApplicationWidgetState createState() =>
      _CreditApplicationWidgetState();
}

class _CreditApplicationWidgetState extends StateMVC<CreditApplicationWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late CreditController _con;
  String? imgPath;
  _CreditApplicationWidgetState() : super(CreditController()) {
    _con = controller as CreditController;
  }

  final List<Map<String, String>> signedItems = [
    {
      'Product': 'XBox 360',
      'Reference': 'refTestNum',
      'Amount': '\$102',
      'Microfinance': 'Mukuru',
    },
    {
      'Product': 'Rolex Z1',
      'Reference': 'refTestNum',
      'Amount': '\$2050',
      'Microfinance': 'GetBucks',
    },
    {
      'Product': 'Polo Shirt',
      'Reference': 'refTestNum',
      'Amount': '\$80',
      'Microfinance': 'GetBucks',
    },
  ];

  @override
  void initState() {
    super.initState();
    _con.listenForApplications();
    _con.listenForProfileInfo();
    _tabController = TabController(length: 4, vsync: this);
  }

  Widget buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Product",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Reference",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              "Amount",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              "Action",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String text, {
    Color iconColor = Colors.black,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget buildItemRow(CreditApplication item) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/ProductDetails', arguments: item);
      },
      child: 1 == 1
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _detailRow(
                          Icons.info,
                          item.creditApplicationReference ?? "",
                          iconColor: Colors.black,
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _detailRow(
                      Icons.attach_money,
                      "Total Amount:\$${item.totalRepaymentAmount}",
                    ),

                    _detailRow(
                      Icons.account_balance_wallet_outlined,
                      "Monthly repayment: \$${item.monthlyRepaymentAmount}",
                    ),

                    _detailRow(
                      Icons.account_balance_wallet_outlined,
                      "VerificationStatus: ${item.applicationVerified}",
                    ),
                  ],
                ),
              ),
            )
          : Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item.productName ?? '')),
                  Expanded(
                    child: Text(
                      item.creditApplicationReference ?? '',
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "\$${item.totalRepaymentAmount?.toStringAsFixed(2) ?? ''}",
                    ),
                  ),
                  const Expanded(
                    child: Icon(Icons.arrow_forward, color: Colors.black),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTabContent(List<CreditApplication> items) {
    return items.isEmpty
        ? Center(
            child: Text(
              "No applications found",
              style: TextStyle(color: Colors.black),
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [...items.map(buildItemRow)],
          );
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        key: _con.scaffoldKey,
        backgroundColor: const Color(0xfff7f7f7),
        // floatingActionButton: _con.profileModel == null
        //     ? null
        //     : FloatingActionButton(
        //         backgroundColor: Constants.primaryColor,
        //         child: Icon(Icons.qr_code, color: Colors.white),
        //         onPressed: () async {

        //             String? res = await SimpleBarcodeScanner.scanBarcode(
        //               context,
        //               barcodeAppBar: const BarcodeAppBar(
        //                 appBarTitle: 'Scan to Pay',
        //                 centerTitle: false,
        //                 enableBackButton: true,
        //                 backButtonIcon: Icon(Icons.arrow_back_ios),
        //               ),
        //               isShowFlashIcon: true,
        //               delayMillis: 2000,
        //               cameraFace: CameraFace.front,
        //             );

        //             if (res != null && res.isNotEmpty) {
        //               ConfirmOtpResult? result = await _con.scanToPay({
        //                 "encryptedApplicationID": res,
        //                 "idNumber":
        //                     _con.profileModel?.nationalIdentification ?? '',
        //               });

        //               if (result != null) {
        //                 CustomMessageHandler().showSuccessSnakeBar(
        //                   _con.scaffoldKey.currentContext!,
        //                   'Scan Successfull',
        //                 );
        //               } else {
        //                 CustomMessageHandler().showErrorSnakeBar(
        //                   _con.scaffoldKey.currentContext!,
        //                   'Something went wrong.Try again',
        //                 );
        //               }
        //             }

        //         },
        //       ),
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.pushNamed(context, '/Dashboard');
            },
          ),
          title: const Text(
            "Credit information",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 0.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 18.0, // Use your desired horizontal space
                    vertical:
                        0.0, // Drastically reduce vertical padding to center text
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Signed"),
                    Tab(text: "Pending"),
                    Tab(text: "Declined"),
                    Tab(text: "Approved"),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    buildTabContent(
                      _con.applications
                          .where(
                            (element) =>
                                element.creditApplicationStatus ==
                                'UNDER_REVIEW',
                          )
                          .toList(),
                    ),
                    buildTabContent(
                      _con.applications
                          .where(
                            (element) =>
                                element.creditApplicationStatus == 'PENDING',
                          )
                          .toList(),
                    ),
                    buildTabContent(
                      _con.applications
                          .where(
                            (element) =>
                                element.creditApplicationStatus == 'DECLINED',
                          )
                          .toList(),
                    ),
                    buildTabContent(
                      _con.applications
                          .where(
                            (element) =>
                                element.creditApplicationStatus == 'APPROVED',
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build1(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pushNamed(context, '/Dashboard');
          },
        ),
        title: const Text(
          "Credit information",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/ScanToPay');
              },
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Constants.primaryColor),
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff2e3192), // Dark blue
                      Color(0xff6f73d2), // Lighter shade of blue
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Scan to pay",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge!.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 30),
                    const Icon(
                      Icons.qr_code_scanner_outlined,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                "Credit application",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: Constants.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
