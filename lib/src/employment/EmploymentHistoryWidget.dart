import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/employment/models/CustomerEmployerModel.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../models/constants.dart';
import '../widgets/CustomButtons.dart';
import 'controllers/EmploymentController.dart';

class EmploymentHistoryWidget extends StatefulWidget {
  const EmploymentHistoryWidget({Key? key}) : super(key: key);

  @override
  _EmploymentHistoryWidgetState createState() =>
      _EmploymentHistoryWidgetState();
}

class _EmploymentHistoryWidgetState extends StateMVC<EmploymentHistoryWidget> {
  late EmploymentController _con;

  _EmploymentHistoryWidgetState() : super(EmploymentController()) {
    _con = controller as EmploymentController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForCustomerEmployers();
    // _con.loadCustomEmployers();
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: Color(0xfff5f5f5),
        bottomNavigationBar: 1 == 1 || _con.customers_employers.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButtons.filledButton(
                        text: 'Add employment',
                        callback: () {
                          Navigator.pushNamed(context, '/SelectCompany').then((
                            value,
                          ) {
                            _con.listenForCustomerEmployers();
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              )
            : null,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          leading: const BackButton(color: Colors.black),
          title: InkWell(
            onTap: () {
              // Navigator.pushNamed(context, '/Dashboard');
            },

            child: const Text(
              "Employment history",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _con.customers_employers.isEmpty
              ? Center(
                  child: Text(
                    "No employment details",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.black),
                  ),
                )
              : 1 == 1
              ? Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        10.0,
                        20.0,
                        100.0,
                      ), // Padding above the button
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._con.customers_employers.map(
                            (element) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Column(
                                children: [
                                  _EmploymentDateHeader(
                                    dateRange: '2022 - 2023',
                                  ),
                                  _CompanyCard(
                                    logoAsset:
                                        element.employmentEmployerLogo ??
                                        "", // Replace with your actual asset path
                                    companyName: element.employerName ?? '',
                                    isSelected: false,
                                    employer: element,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // --- FBC Holdings Entry ---
                          // _EmploymentDateHeader(dateRange: '2018 - 2022'),
                          // _CompanyCard(
                          //   logoAsset:
                          //       'assets/fbc_logo.png', // Replace with your actual asset path
                          //   companyName: 'FBC Holdings',
                          //   isSelected: false,
                          // ),

                          // const SizedBox(height: 20),

                          // // --- Old Mutual Entry (Past) ---
                          // _EmploymentDateHeader(dateRange: '2022 - 2023'),
                          // _CompanyCard(
                          //   logoAsset:
                          //       'assets/old_mutual_logo.png', // Replace with your actual asset path
                          //   companyName: 'Old Mutual',
                          //   isSelected: false,
                          // ),

                          // const SizedBox(height: 25),

                          // // --- Current Employment Header ---
                          // const Text(
                          //   'Current Employment',
                          //   style: TextStyle(
                          //     color: Color(0xFF5A40A6), // Deep purple color
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w600,
                          //   ),
                          // ),
                          // const SizedBox(height: 10),

                          // // --- Old Mutual Entry (Current) ---
                          // _CompanyCard(
                          //   logoAsset:
                          //       'assets/old_mutual_logo.png', // Replace with your actual asset path
                          //   companyName: 'Old Mutual',
                          //   isSelected: true, // Apply the purple border/shadow
                          // ),
                        ],
                      ),
                    ),

                    // --- Floating Action Button at the bottom ---
                    // Align(
                    //   alignment: Alignment.bottomCenter,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(
                    //       bottom: 25.0,
                    //       left: 20.0,
                    //       right: 20.0,
                    //     ),
                    //     child: GradientButton(
                    //       text: 'Add Employment',
                    //       onPressed: () {
                    //         print('Add Employment tapped');
                    //         // Add navigation logic here
                    //       },
                    //     ),
                    //   ),
                    // ),
                  ],
                )
              : Column(
                  children: [
                    ..._con.customers_employers.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/Employer',
                              arguments: e,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.3),

                                            image: DecorationImage(
                                              image: NetworkImage(
                                                e.employmentEmployerLogo ?? "",
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 3),
                                        Container(
                                          width: 1,
                                          height: 50,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              left: BorderSide(
                                                //                   <--- left side
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 3),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.employerName ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              e.employerCurrentPosition ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              e.employmentType ?? "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _EmploymentDateHeader extends StatelessWidget {
  final String dateRange;

  const _EmploymentDateHeader({required this.dateRange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            dateRange,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// Reusable widget for the company card
class _CompanyCard extends StatelessWidget {
  final String logoAsset;
  final String companyName;
  final bool isSelected;
  final CustomerEmployerModel employer;
  const _CompanyCard({
    required this.logoAsset,
    required this.companyName,
    required this.isSelected,
    required this.employer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        border: isSelected
            ? Border.all(
                color: const Color(0xFF5A40A6),
                width: 1.5,
              ) // Purple border
            : Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ), // Light grey border
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF5A40A6).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 80, // Space for logo and divider
          child: Row(
            children: [
              // Placeholder for the logo. In a real app, this would be an Image.asset
              SafeNetworkImage(imageUrl: logoAsset, height: 35, width: 35),
              const SizedBox(width: 10),
              // Vertical Divider
              const VerticalDivider(
                color: Colors.grey,
                thickness: 1,
                indent: 5,
                endIndent: 5,
              ),
            ],
          ),
        ),
        title: Text(
          companyName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        onTap: () {
          Navigator.pushNamed(context, '/Employer', arguments: employer);
        },
      ),
    );
  }
}

// --- GRADIENT BUTTON WIDGET (from previous answer) ---
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const List<Color> gradientColors = [
      Color(0xFF5A40A6), // Darker Purple
      Color(0xFF8B5BE3), // Lighter Purple/Violet
    ];

    return Container(
      width: double.infinity,
      height: 56.0,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15.0),
          child: const Center(
            child: Text(
              'Add Employment',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;

  final double width;
  final double height;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      // 1. Specify a loading placeholder (optional, but good practice)
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child; // Image loaded successfully
            }
            // Show a simple spinner while loading
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },

      // 2. The solution: Use errorBuilder to handle failure gracefully
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
            // You can return any widget here.
            // Returning a SizedBox.shrink() or Container() makes it completely invisible.
            // return const SizedBox.shrink(); // Hides the error completely

            // Alternatively, you could show a placeholder icon:

            return Container(
              width: width,
              height: height,
              child: Icon(Icons.broken_image, color: Colors.grey, size: 35),
            );
          },

      // Specify height/width for your image container
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}
