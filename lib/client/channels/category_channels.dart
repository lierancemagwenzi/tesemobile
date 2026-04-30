import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/home/home.dart';
import 'package:smacredit/src/content-creator/models/channel_model.dart';
import 'package:smacredit/src/repositories/user_repository.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

import '../models/dashboard_model.dart';

class ChannelsDirectoryScreen extends StatefulWidget {
  final Category category;
  const ChannelsDirectoryScreen({super.key, required this.category});

  @override
  StateMVC<ChannelsDirectoryScreen> createState() =>
      _ChannelsDirectoryScreenState();
}

class _ChannelsDirectoryScreenState extends StateMVC<ChannelsDirectoryScreen> {
  bool _isGridView = false;
  String _searchQuery = "";

  // Branding Colors
  static const Color teseGreen = Color(0xFF1B5E20);

  late ClientUserController _con;

  _ChannelsDirectoryScreenState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForCategoryChannels(widget.category.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter logic placeholder (Assuming you pass a list from a controller)
    // final filteredChannels = _con.channels.where((c) => c.name!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "${widget.category.name} Channels",
            style: theme.textTheme.titleLarge,
          ),
          actions: [
            // IconButton(
            //   icon: Icon(
            //     _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            //   ),
            //   onPressed: () => setState(() => _isGridView = !_isGridView),
            // ),
          ],
        ),
        body: _con.channels.isEmpty
            ? TeseEmptyWidget()
            : Column(
                children: [
                  _buildSearchBar(theme),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isGridView ? _buildGrid() : _buildList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Search channels...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      key: const ValueKey("grid"),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _con.channels.length, // Replace with your list length
      itemBuilder: (context, index) =>
          _ChannelCard(isGrid: true, channel: _con.channels[index]),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      key: const ValueKey("list"),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _con.channels.length, // Replace with your list length
      itemBuilder: (context, index) =>
          _ChannelCard(isGrid: false, channel: _con.channels[index]),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final bool isGrid;
  final Channel channel; // Pass your model here

  const _ChannelCard({required this.isGrid, required this.channel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: isGrid ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      child: isGrid
          ? _buildGridItem(theme, isDark, context)
          : _buildListItem(theme, isDark, context),
    );
  }

  Widget _buildGridItem(ThemeData theme, bool isDark, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/CreatorChannelView', arguments: channel);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: CachedNetworkImageProvider(
              channel.logoUrl ?? "",
              headers: {'Cookie': cloudFrontCookieNotifier.value},
            ),
            backgroundColor: Colors.grey[800],
            // backgroundImage: NetworkImage(channel.logoUrl ?? ""),
          ),
          const SizedBox(height: 12),
          Text(
            channel.name ?? "",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "${channel.playlistCount ?? 0} Playlists",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          _buildPriceTag(theme),
        ],
      ),
    );
  }

  Widget _buildListItem(ThemeData theme, bool isDark, BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, '/CreatorChannelView', arguments: channel);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: CachedNetworkImageProvider(
          channel.logoUrl ?? "",
          headers: {'Cookie': cloudFrontCookieNotifier.value},
        ),
        backgroundColor: Colors.grey[800],
        // backgroundImage: NetworkImage(channel.logoUrl ?? ""),
      ),
      title: Text(
        "${channel.name}",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "${channel.videoCount ?? 0} Videos • ${channel.playlistCount ?? 0} Playlists",
      ),
      trailing: _buildPriceTag(theme),
    );
  }

  Widget _buildPriceTag(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        channel.subscriptionEnabled == true
            ? "${channel.subscriptionCurrency}${channel.subscriptionPrice}"
            : "Free", // Use channel.subscriptionPrice
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
