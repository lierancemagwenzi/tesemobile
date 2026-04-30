import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/channels/empty_widget.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/src/models/UserModel.dart';

class FollowingCreators extends StatefulWidget {
  const FollowingCreators({super.key});

  @override
  StateMVC<FollowingCreators> createState() => _FollowingCreatorsState();
}

class _FollowingCreatorsState extends StateMVC<FollowingCreators> {
  late ClientUserController _con;

  _FollowingCreatorsState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForFollowingCreators();
  }

  bool _isGridView = true;
  String _searchQuery = "";

  // Mock Data

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCreators = _con.creators
        .where(
          (c) => c.fullname.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Following Creators"),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search creators...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: filteredCreators.isEmpty
                ? const TeseEmptyWidget(
                    title: "No Creators Found",
                    icon: Icons.person_search,
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isGridView
                        ? _buildGrid(filteredCreators)
                        : _buildList(filteredCreators),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<User> creators) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: creators.length,
      itemBuilder: (context, index) =>
          _CreatorCard(creator: creators[index], isGrid: true),
    );
  }

  Widget _buildList(List<User> creators) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: creators.length,
      itemBuilder: (context, index) =>
          _CreatorCard(creator: creators[index], isGrid: false),
    );
  }
}

class _CreatorCard extends StatelessWidget {
  final User creator;
  final bool isGrid;

  const _CreatorCard({required this.creator, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: isGrid
          ? _buildGridContent(theme, context)
          : _buildListContent(theme, context),
    );
  }

  Widget _buildGridContent(ThemeData theme, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/CreatorProfile', arguments: creator);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(creator.selfie ?? ""),
          ),
          const SizedBox(height: 12),
          Text(
            creator.fullname,
            style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16),
          ),
          Text(creator.description ?? "", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            "${creator.videoCount ?? 0} videos",
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(ThemeData theme, BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, '/CreatorProfile', arguments: creator);
      },
      leading: CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(creator.selfie ?? ""),
      ),
      title: Text(
        creator.fullname,
        style: theme.textTheme.headlineSmall?.copyWith(fontSize: 16),
      ),
      subtitle: Text(creator.description ?? ""),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
    );
  }
}
