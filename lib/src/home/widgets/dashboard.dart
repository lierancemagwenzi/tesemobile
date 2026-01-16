import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/home/controller/HomeController.dart';
import 'package:smacredit/src/home/models/earnings_stats_model.dart';
import 'package:smacredit/src/home/models/user_stats.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/payments/models/transaction_model.dart';
import 'package:smacredit/src/payments/widgets/transactions.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:badges/badges.dart' as badges;
import 'package:smacredit/src/widgets/CustomOverlay.dart';

// --- Placeholder for the Earnings Metric Component ---
class EarningsMetric extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;

  const EarningsMetric({
    Key? key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(icon, color: iconColor, size: 24),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            // const Text(
            //   '+12%', // Static for example
            //   style: TextStyle(
            //     fontSize: 12,
            //     color: Colors.green,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// --- Placeholder for the Simple Chart Component ---
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a static representation to mimic the structure and look.
    // In a real app, you would use a dedicated charting library (e.g., fl_chart, charts_flutter).
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: const [
                  _TimePeriodTab(text: 'Today', isSelected: true),
                  _TimePeriodTab(text: 'Weekly', isSelected: false),
                  _TimePeriodTab(text: 'Monthly', isSelected: false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Placeholder for the actual chart drawing area
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _YAxisLabel(label: '340'),
              _YAxisLabel(label: '290'),
              _YAxisLabel(label: '200'),
              _YAxisLabel(label: '150'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              _BarSet(height1: 100, height2: 150, label: 'Week 1'),
              _BarSet(height1: 150, height2: 180, label: 'Week 2'),
              _BarSet(height1: 180, height2: 210, label: 'Week 3'),
              _BarSet(height1: 190, height2: 60, label: 'Week 4'),
            ],
          ),
        ],
      ),
    );
  }
}

// Sub-component for the chart's time period tabs
class _TimePeriodTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _TimePeriodTab({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Sub-component for a single set of bars in the chart
class _BarSet extends StatelessWidget {
  final double height1;
  final double height2;
  final String label;

  const _BarSet({
    required this.height1,
    required this.height2,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 15, height: height1, color: Colors.green.shade700),
            const SizedBox(width: 4),
            Container(width: 15, height: height2, color: Colors.red.shade700),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}

// Sub-component for Y-Axis labels (mimicking the image layout)
class _YAxisLabel extends StatelessWidget {
  final String label;

  const _YAxisLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}

// --- Main Dashboard Widget ---

class Dashboard extends StatefulWidget {
  final VoidCallback onProfileTap;
  const Dashboard({super.key, required this.onProfileTap});

  @override
  StateMVC<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends StateMVC<Dashboard> {
  late HomeController _con;

  _DashboardState() : super(HomeController()) {
    _con = controller as HomeController;
  }

  String? get selectedCurrency {
    return _con.selectedCurrency;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _con.listenForDashboardInfo();

    Future.delayed(Duration(seconds: 1)).then((value) {
      _con.init(context);
      _con.local();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Light background color
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight:
              0, // Hides the AppBar itself, relying on the custom header
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Custom Header (Time, Notification, Profile)
                _buildHeader(context),
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<AmountStatsModel>(
                    // 1. Set the currently selected OBJECT as the value
                    value: _con.data,

                    // Optional: Hints the user what the dropdown is for
                    hint: const Text(
                      'Select currency',
                      style: TextStyle(color: Colors.black54),
                    ),

                    // 2. Map the list of objects to DropdownMenuItem widgets
                    items: (_con.dashboardModel?.amountStats ?? []).map((
                      statsModel,
                    ) {
                      return DropdownMenuItem<AmountStatsModel>(
                        // Set the entire object as the internal value
                        value: statsModel,

                        // Display the currency property as the user-facing text
                        child: Text(
                          statsModel.currency ??
                              'N/A', // Use the currency as the label
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),

                    // 3. Handle the selection change
                    onChanged: (AmountStatsModel? newValue) {
                      setState(() {
                        _con.data = newValue;
                      });
                      // Call the external callback function to notify the parent
                    },
                  ),
                ),

                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: Container(
                //     // 2. Wrap in a Container/SizedBox to explicitly limit the button's width
                //     width: 80, // Adjust this width to be small (e.g., 60-100)
                //     padding: const EdgeInsets.only(
                //       right: 16.0,
                //     ), // Optional: Add some padding from the screen edge
                //     // 3. Use ButtonTheme to ensure the dropdown menu width matches the button width
                //     child: ButtonTheme(
                //       alignedDropdown:
                //           true, // This is crucial for matching menu width to button width
                //       child: DropdownButton<String>(
                //         value: selectedCurrency,
                //         isDense:
                //             true, // Shrinks the button's height/padding slightly
                //         // 4. Align the selected value text to the right inside the button
                //         alignment: Alignment.centerRight,

                //         // 5. Remove the default underline
                //         underline: Container(),

                //         // 6. Define the items from your list
                //         items: (_con.dashboardModel?.uniqueCurrencies ?? []).map((
                //           String currency,
                //         ) {
                //           return DropdownMenuItem<String>(
                //             value: currency,
                //             child: Text(
                //               currency,
                //               textAlign: TextAlign.right,
                //               style: TextStyle(
                //                 color: Colors.red,
                //               ), // Optional: Align menu item text to the right
                //             ),
                //           );
                //         }).toList(),

                //         // 7. Handle the selection change
                //         onChanged: (String? newValue) {
                //           setState(() {
                //             _con.selectedCurrency = newValue;
                //           });
                //           // You can call a function here to refresh your stats based on the new currency
                //           print('Selected currency: $newValue');
                //         },
                //       ),
                //     ),
                //   ),
                // ),
                Row(
                  children: [
                    EarningsMetric(
                      title: 'Total Earnings',
                      amount:
                          '${(_con.data?.totalAmount ?? 0).toStringAsFixed(2)}',
                      icon: Icons.stacked_line_chart,
                      iconColor: Colors.green,
                    ),
                    EarningsMetric(
                      title: "Today's Earnings",
                      amount:
                          '${(_con.data?.todayAmount ?? 0).toStringAsFixed(2)}',
                      icon: Icons.folder_open,
                      iconColor: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Earnings Metrics (Row 2: Weekly & Monthly)
                Row(
                  children: [
                    EarningsMetric(
                      title: 'Weekly Earnings',
                      amount:
                          '${(_con.data?.weeklyAmount ?? 0).toStringAsFixed(2)}',
                      icon: Icons.calendar_today,
                      iconColor: Colors.grey,
                    ),
                    EarningsMetric(
                      title: 'Monthly Earnings',
                      amount:
                          '${(_con.data?.monthlyAmount ?? 0).toStringAsFixed(2)}',
                      icon: Icons.calendar_month,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                if ((_con.dashboardModel?.balances ?? []).isNotEmpty)
                  ...(_con.dashboardModel?.balances ?? []).map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: BalanceCard(
                        totalBalance: e.amount,
                        currencySymbol: e.currency,
                        priceModel: e,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: BalanceCard(
                      totalBalance: 0.0,
                      currencySymbol: 'USD',
                      priceModel: PriceModel(amount: 0, currency: '\$'),
                    ),
                  ),

                const SizedBox(height: 30),

                // 6. Create Payment Link Button
                _buildPaymentLinkButton(context),
                const SizedBox(height: 30),

                if (_con.dashboardModel?.transactions?.isNotEmpty == true) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Recent transactions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _con.dashboardModel?.transactions?.length ?? 0,
                    itemBuilder: (context, index) {
                      // Add a Divider except after the last item

                      TransactionModel transactionModel =
                          _con.dashboardModel!.transactions![index];
                      return Column(
                        children: [
                          TransactionListItem(transaction: transactionModel),
                          if (index <
                              _con.dashboardModel!.transactions!.length - 1)
                            Divider(
                              indent: 75,
                              height: 1,
                              thickness: 0.5,
                              color: Colors.grey.shade200,
                            ),
                        ],
                      );
                    },
                  ),
                ],
                // _buildWithdrawButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        // 7. Bottom Navigation Bar
        // bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        // Gradient color similar to the screenshot
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.lightGreen.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          // Handle withdrawal action
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.send, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Withdraw',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // This is the top section containing the bell icon and profile picture
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/Notifications').then((_) {
              _con.listenForDashboardInfo();
            });
          },

          child: badges.Badge(
            badgeContent: Text(
              '${_con.dashboardModel?.notificationCount ?? 0}',
              style: TextStyle(color: Colors.white),
            ),

            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                // borderRadius: BorderRadius.circular(15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade600),
              ),
              child: const Icon(Icons.notifications_none, color: Colors.black),
            ),
          ),
        ),
        _buildGreeting(),
        InkWell(
          onTap: widget.onProfileTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(
                  currentuser.value.user?.selfie ?? '',
                ), // Placeholder profile image
                fit: BoxFit.cover,
              ),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          'Hello ${currentuser.value.user?.name ?? ''}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentLinkButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        // Gradient color similar to the screenshot
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.lightGreen.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/CreatePaymentLink');
        },
        child: const Text(
          'Create Payment Link',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class WeeklyEarningsVsWithdrawalsChart extends StatelessWidget {
  final List<double> earnings; // e.g. [100, 200, 150, 300, 250, 400, 350]
  final List<double> withdrawals; // e.g. [50, 20, 100, 80, 30, 150, 120]

  const WeeklyEarningsVsWithdrawalsChart({
    super.key,
    required this.earnings,
    required this.withdrawals,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Earnings Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 3, // 7 days: 0–6
              minY: 0,
              maxY: _getMaxY(),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: _bottomTitles,
                  ),
                ),
              ),
              lineBarsData: [
                // Earnings (Green)
                LineChartBarData(
                  spots: _toSpots(earnings),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 4,
                  dotData: FlDotData(show: false),
                ),

                // Withdrawals (Red)
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _toSpots(List<double> values) {
    return List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
  }

  Widget _bottomTitles(double value, TitleMeta meta) {
    const days = ['1', '2', '3', '4'];
    if (value < 0 || value > 6) return Container();
    return Text(days[value.toInt()]);
  }

  double _getMaxY() {
    final maxE = earnings.isEmpty
        ? 0
        : earnings.reduce((a, b) => a > b ? a : b);
    final maxW = withdrawals.isEmpty
        ? 0
        : withdrawals.reduce((a, b) => a > b ? a : b);
    return (maxE > maxW ? maxE : maxW) + 20; // lil padding
  }
}

class FourMonthEarningsChart extends StatelessWidget {
  final List<double> earnings;

  const FourMonthEarningsChart({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    final monthLabels = _getLastFourMonthLabels();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Earnings Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 3,
              minY: 0,
              maxY: _getMaxY(earnings),
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(reservedSize: 30, showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      if (value < 0 || value > 3)
                        return const SizedBox.shrink();
                      return Text(monthLabels[value.toInt()]);
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: _toSpots(earnings),
                  isCurved: true,
                  barWidth: 2,
                  color: Colors.green,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getLastFourMonthLabels() {
    final now = DateTime.now();
    final format = DateFormat('MMM');

    return List.generate(4, (i) {
      final date = DateTime(now.year, now.month - (3 - i), 1);
      return format.format(date);
    });
  }

  List<FlSpot> _toSpots(List<double> values) {
    return List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));
  }

  double _getMaxY(List<double> e) {
    if (e.isEmpty) return 100;
    final m = e.reduce((a, b) => a > b ? a : b);
    return m + (m * 0.1);
  }
}

class BalanceCard extends StatelessWidget {
  // Use data types appropriate for a balance display
  final double totalBalance;
  final PriceModel priceModel;
  final String currencySymbol;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.priceModel,
    this.currencySymbol = '\$', // Default to dollar sign
  });

  @override
  Widget build(BuildContext context) {
    // Determine the color for the percentage/change text (e.g., green for positive)

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        // Match the deep blue background color and soft rounded corners
        decoration: BoxDecoration(
          color: Constants.greenColor, // A deep blue color approximation
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- 1. Total Balance Label ---
            const Text(
              'Payout balance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 8),

            // --- 2. Balance Amount ---
            Text(
              // Format the string with the currency symbol and two decimal places
              '$currencySymbol${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
                height: 1.1, // Adjust line height for better visual spacing
              ),
            ),

            const SizedBox(height: 30),

            // --- 3. Bottom Row: Percentage/Change and Button ---
            totalBalance > 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: 7.0% ($20)

                      // Right side: Add Funds Button
                      SizedBox(
                        height: 36, // Match the height from the image
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/RequestPayout',
                              arguments: priceModel,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            // White background, rounded corners
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(
                              0xFF193275,
                            ), // Text color is the card color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text(
                            'Request Payout',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(height: 0, width: 0),

            // --- 3. Bottom Row: Percentage/Change and Button ---
          ],
        ),
      ),
    );
  }
}
