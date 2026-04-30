import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/home/controller/HomeController.dart';
import 'package:smacredit/src/home/models/earnings_stats_model.dart';
import 'package:smacredit/src/home/models/user_stats.dart';
import 'package:smacredit/src/home/widgets/perfomance_widget.dart';
import 'package:smacredit/src/models/constants.dart';
import 'package:smacredit/src/payments/models/transaction_model.dart';
import 'package:smacredit/src/payments/widgets/transactions.dart';
import 'package:smacredit/src/profile/models/account_info.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:badges/badges.dart' as badges;
import 'package:smacredit/src/widgets/CustomOverlay.dart';

// --- Earnings Metric with Tese Branding ---
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 12),
            Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  String? get selectedCurrency => _con.selectedCurrency;

  @override
  void initState() {
    super.initState();
    _con.listenForDashboardInfo();
    _con.getAccountInfo();
    Future.delayed(const Duration(seconds: 1)).then((value) {
      if (mounted) {
        _con.init(context);
        _con.local();
      }
    });
  }

  Widget _buildRestrictionNotice(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Transparent amber/red glass effect
        color: Colors.amber.withOpacity(isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Account Restricted",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You currently cannot create payment links or make withdrawals. Your account is in $status status.",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color teseGold = const Color(0xFFFFD700);

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF5F7FA),
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isDark, teseGold),
                const SizedBox(height: 24),

                if (currentuser.value.user?.status?.toLowerCase() != 'active')
                  _buildRestrictionNotice(
                    context,
                    currentuser.value.user?.status?.toLowerCase() ?? 'unknown',
                  ),

                const SizedBox(height: 16),

                // Currency Selector with Styling
                _buildCurrencyDropdown(isDark, teseGold),

                const SizedBox(height: 16),

                // Metrics Row 1
                Row(
                  children: [
                    EarningsMetric(
                      title: 'Total Earnings',
                      amount:
                          '${(_con.data?.totalAmount ?? 0).toStringAsFixed(2)}',
                      icon: Icons.auto_graph_rounded,
                      iconColor: Colors.greenAccent,
                    ),
                    EarningsMetric(
                      title: "Today",
                      amount:
                          '${(_con.data?.todayAmount ?? 0).toStringAsFixed(2)}',
                      icon: Icons.bolt_rounded,
                      iconColor: Colors.orangeAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Metrics Row 2
                Row(
                  children: [
                    EarningsMetric(
                      title: 'Weekly',
                      amount:
                          '${(_con.data?.weeklyAmount ?? 0).toStringAsFixed(2)}',
                      icon: Icons.calendar_view_week_rounded,
                      iconColor: Colors.blueAccent,
                    ),
                    EarningsMetric(
                      title: 'Monthly',
                      amount:
                          '${(_con.data?.monthlyAmount ?? 0).toStringAsFixed(2)}',
                      icon: Icons.calendar_month_rounded,
                      iconColor: Colors.redAccent,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Balance Cards Section
                if ((_con.dashboardModel?.balances ?? []).isNotEmpty)
                  ...(_con.dashboardModel?.balances ?? []).map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: BalanceCard(
                        totalBalance: e.amount,
                        currencySymbol: e.currency ?? '',
                        priceModel: e,
                        voidCallback: () => _con.getAccountInfo(),
                        accountInfo: _con.accountInfo,
                      ),
                    ),
                  )
                else
                  BalanceCard(
                    totalBalance: 0.0,
                    currencySymbol: '\$',
                    voidCallback: () => _con.getAccountInfo(),
                    priceModel: PriceModel(amount: 0, currency: '\$'),
                    accountInfo: _con.accountInfo,
                  ),

                const SizedBox(height: 24),

                if (currentuser.value.user?.status?.toLowerCase() ==
                    'active') ...[
                  _buildTesePaymentButton(context),
                  const SizedBox(height: 30),
                ],

                Row(
                  children: [
                    Text(
                      "Media",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Spacer(),
                    TextActionButton(
                      label: 'Performance',
                      onTap: () {
                        showLeaderboard(
                          context,
                          _con.dashboardModel?.topVideos ?? [],
                          _con.dashboardModel?.topPlaylists ?? [],
                          _con.dashboardModel?.topChannels ?? [],
                        );
                      },
                      icon: Icons.graphic_eq,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    EarningsMetric(
                      title: 'Total Videos',
                      amount: (_con.dashboardModel?.videos ?? 0).toString(),
                      icon: Icons.video_call,
                      iconColor: Colors.greenAccent,
                    ),
                    EarningsMetric(
                      title: "Total Channels",
                      amount: (_con.dashboardModel?.channels ?? 0).toString(),
                      icon: Icons.category_outlined,
                      iconColor: Colors.orangeAccent,
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    EarningsMetric(
                      title: 'Total Playlists',
                      amount: (_con.dashboardModel?.playlists ?? 0).toString(),
                      icon: Icons.list_alt,
                      iconColor: Colors.greenAccent,
                    ),
                    EarningsMetric(
                      title: "Total Views",
                      amount: (_con.dashboardModel?.views ?? 0).toString(),
                      icon: Icons.remove_red_eye,
                      iconColor: Colors.orangeAccent,
                    ),
                  ],
                ),

                // Transactions List
                if (_con.dashboardModel?.transactions?.isNotEmpty == true) ...[
                  _buildTransactionHeader(isDark),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.dashboardModel?.transactions?.length ?? 0,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 70,
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                      ),
                      itemBuilder: (context, index) {
                        return TransactionListItem(
                          transaction:
                              _con.dashboardModel!.transactions![index],
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showLeaderboard(
    BuildContext context,
    List<Video> v,
    List<Playlist> p,
    List<Channel> c,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, _, __) => TopPerformingDialog(
          topVideos: v.take(3).toList(),
          topPlaylists: p.take(3).toList(),
          topChannels: c.take(3).toList(),
        ),
      ),
    );
  }
  // --- Styled Sub-Widgets ---

  Widget _buildHeader(BuildContext context, bool isDark, Color gold) {
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onProfileTap,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: gold, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                currentuser.value.user?.selfie ?? '',
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back,",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                currentuser.value.user?.name ?? '',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        badges.Badge(
          position: badges.BadgePosition.topEnd(top: -2, end: -2),
          badgeContent: Text(
            '${_con.dashboardModel?.notificationCount ?? 0}',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pushNamed(
              context,
              '/Notifications',
            ).then((_) => _con.listenForDashboardInfo()),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(bool isDark, Color gold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AmountStatsModel>(
          value: _con.data,
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          hint: Text(
            'Currency',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
          items: (_con.dashboardModel?.amountStats ?? []).map((statsModel) {
            return DropdownMenuItem<AmountStatsModel>(
              value: statsModel,
              child: Text(
                statsModel.currency ?? 'N/A',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => _con.data = newValue),
        ),
      ),
    );
  }

  Widget _buildTesePaymentButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF444444)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, '/CreatePaymentLink'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'CREATE PAYMENT LINK',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Recent Transactions",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "See All",
            style: TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}

// --- Modified Balance Card for Tese Premium Feel ---
class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final PriceModel priceModel;
  final String currencySymbol;
  final AccountInfo? accountInfo;
  final VoidCallback voidCallback;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    this.accountInfo,
    required this.voidCallback,
    required this.priceModel,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1e3c72), Color(0xFF2a5298)], // Premium Navy Blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payout Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white30,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$currencySymbol${totalBalance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (totalBalance > 0 &&
              currentuser.value.user?.status?.toLowerCase() == 'active')
            SizedBox(
              height: 40,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (accountInfo?.hasBank == true) {
                    /* withdrawal logic */
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'WITHDRAW FUNDS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TextActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isLarge;

  const TextActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isLarge = false,
  });

  final Color brandGreen = const Color(0xFF00D285);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 20 : 12,
          vertical: isLarge ? 12 : 8,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Subtle hover/splash effect
        foregroundColor: brandGreen.withOpacity(0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: brandGreen, size: isLarge ? 20 : 16),
            const SizedBox(width: 8),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: brandGreen,
              fontSize: isLarge ? 14 : 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              shadows: [
                Shadow(color: brandGreen.withOpacity(0.4), blurRadius: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
