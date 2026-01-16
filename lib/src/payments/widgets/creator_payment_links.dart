import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/channels/loading_widget.dart';
import 'package:smacredit/src/home/controller/client_controller.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

// Importing your standardized components
// import 'package:smacredit/client/channels/empty_widget.dart';
// import 'package:smacredit/client/channels/loading_widget.dart';

class CreatorPaymentLinksWidget extends StatefulWidget {
  final User creator;

  const CreatorPaymentLinksWidget({Key? key, required this.creator})
    : super(key: key);

  @override
  _CreatorPaymentLinksWidgetState createState() =>
      _CreatorPaymentLinksWidgetState();
}

class _CreatorPaymentLinksWidgetState
    extends StateMVC<CreatorPaymentLinksWidget> {
  final TextEditingController _searchController = TextEditingController();
  late ClientController _con;

  _CreatorPaymentLinksWidgetState() : super(ClientController()) {
    _con = controller as ClientController;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _con.listenForLinks(widget.creator.id ?? 0);
  }

  void _onSearchChanged() {
    setState(() {
      _con.filteredLinks = _con.paymentLinks
          .where(
            (link) =>
                link.paymentProfileName.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                link.title.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Creator Links",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: BackButton(color: isDark ? Colors.white : Colors.black),
        ),
        body: Column(
          children: [
            _buildCreatorProfileHeader(theme, isDark),
            _buildSearchField(theme, isDark),
            const SizedBox(height: 12),
            Expanded(child: _buildLinksList(theme, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorProfileHeader(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            child: Text(
              widget.creator.name?[0].toUpperCase() ?? "T",
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.creator.name ?? ""} ${widget.creator.lastname ?? ""}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.verified, color: theme.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "Verified Tese Creator",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search content...",
          prefixIcon: Icon(Icons.search, color: theme.hintColor),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinksList(ThemeData theme, bool isDark) {
    if (_con.loading) {
      // Using the TeseShimmer we built earlier
      return TeseShimmer(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      );
    }

    if (_con.filteredLinks.isEmpty) {
      return const TeseEmptyWidget(
        title: "No links found",
        subtitle: "This creator hasn't posted any payment links yet.",
        icon: Icons.link_off,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _con.filteredLinks.length,
      itemBuilder: (context, index) {
        final link = _con.filteredLinks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                link.paymentLinkType.toLowerCase().contains('sub')
                    ? Icons.subscriptions_outlined
                    : Icons.play_lesson_outlined,
                color: theme.primaryColor,
              ),
            ),
            title: Text(
              link.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              link.paymentProfileDescription,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${link.paymentLinkCurrency} ${link.paymentLinkAmount?.toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/ClientPaymentLinkDetails',
                arguments: {'isNew': false, 'link': link},
              );
            },
          ),
        );
      },
    );
  }
}
