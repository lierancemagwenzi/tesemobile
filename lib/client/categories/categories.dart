import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/controller/client_user_controller.dart';
import 'package:smacredit/client/models/dashboard_model.dart';

class TeseCategoryExplorer extends StatefulWidget {
  const TeseCategoryExplorer({super.key});

  @override
  StateMVC<TeseCategoryExplorer> createState() => _TeseCategoryExplorerState();
}

class _TeseCategoryExplorerState extends StateMVC<TeseCategoryExplorer> {
  bool _isGridView = true;
  String _searchQuery = "";
  final Color teseRed = const Color(0xFFFF3B30);

  late ClientUserController _con;

  _TeseCategoryExplorerState() : super(ClientUserController()) {
    _con = controller as ClientUserController;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _con.listenForCategories();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _con.categories
        .where(
          (c) =>
              (c.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Explore Categories",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isGridView ? _buildGrid(filtered) : _buildList(filtered),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE IMAGE LOADER & ERROR HANDLER ---
  Widget _buildNetworkImage(String url, {double? width, double? height}) {
    return 1 == 1
        ? CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            width: width,
            height: height,
            // 1. Placeholder shown while downloading
            placeholder: (context, url) => Container(
              color: Colors.grey[900], // Matches Tese Navy
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            // 2. Error widget shown if the link is broken
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[800],
              child: const Icon(Icons.broken_image, color: Colors.white24),
            ),
          )
        : Image.network(
            url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            // 1. LOADING STATE
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null)
                return child; // Image is fully loaded
              return Container(
                width: width,
                height: height,
                color: Colors.grey[200], // Slight tint during load
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: teseRed,
                    strokeWidth: 2,
                  ),
                ),
              );
            },
            // 2. ERROR STATE (Grey Background as requested)
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300], // Grey background for errors
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 30,
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Unavailable",
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          );
  }

  // --- UI BUILDING METHODS ---
  Widget _buildGrid(List<Category> list) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => _buildImageCard(list[i]),
    );
  }

  Widget _buildImageCard(Category cat) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/Cat', arguments: cat);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(child: _buildNetworkImage(cat.image ?? "")),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  cat.name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Category> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, i) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () {
            Navigator.pushNamed(context, '/Cat', arguments: list[i]);
          },
          contentPadding: const EdgeInsets.all(8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildNetworkImage(
              list[i].image ?? "",
              width: 60,
              height: 60,
            ),
          ),
          title: Text(
            list[i].name ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 14, color: teseRed),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: "Search categories...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
