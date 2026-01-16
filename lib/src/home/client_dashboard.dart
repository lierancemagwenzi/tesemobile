import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/src/home/controller/client_controller.dart';
import 'package:smacredit/src/models/UserModel.dart';
import 'package:smacredit/src/widgets/CustomOverlay.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  StateMVC<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends StateMVC<ClientDashboard> {
  final Color brandGreen = const Color(0xFF00D285);
  final Color brandRed = const Color(0xFFFF4B2B);

  late ClientController _con;

  _ClientDashboardState() : super(ClientController()) {
    _con = controller as ClientController;
  }
  final Color textSecondary = const Color(0xFF757575);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _con.listenForCreators();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _con.filteredCreators = _con.creators
          .where(
            (link) =>
                (link.name ?? "").toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                (link.lastname ?? "").toLowerCase().contains(
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
    return CustomOverlay(
      loading: _con.loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Image.asset('assets/images/logo.png', height: 40), //
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Colors.black87),
              onPressed: () {
                Navigator.pushNamed(context, '/ClientProfile');
              },
            ),
          ],
        ),
        // bottomNavigationBar: _buildBottomNav(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Featured Creators"),
              const SizedBox(height: 15),
              _buildFeaturedCreatorsRow(),
              const SizedBox(height: 30),
              _buildSectionHeader("All Content Creators"),

              if (_con.creators.isNotEmpty) ...[
                const SizedBox(height: 30),
                _buildSearchBox(),
              ],

              const SizedBox(height: 15),
              _buildCreatorList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search creators...",
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.mic_none, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // Text(
        //   "See All",
        //   style: TextStyle(color: brandGreen, fontWeight: FontWeight.w600),
        // ),
      ],
    );
  }

  List<User> getRandomCreators(List<User> allUsers) {
    // 1. Create a copy of the list to avoid modifying the original data
    List<User> shuffledList = List.from(allUsers);

    // 2. Randomly reorder the elements
    shuffledList.shuffle();

    // 3. Take the first 3 elements (or fewer if the list is smaller than 3)
    // and convert back to a List
    return shuffledList.take(3).toList();
  }

  Widget _buildFeaturedCreatorsRow() {
    List<User> data = getRandomCreators(_con.creators);
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/CreatorPaymentLinks',
                arguments: data[index],
              );
            },
            child: Container(
              width: 130,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(data[index].selfie ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: brandGreen, size: 14),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${data[index].name} ${data[index].lastname}",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Text(
                    //   "${data[index].username}",
                    //   style: TextStyle(color: Colors.white70, fontSize: 10),
                    // ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageErrorWidget(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    final Color brandRed = const Color(0xFFFF4B2B);

    return Container(
      // Match the size of your intended image
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, color: brandRed.withOpacity(0.8), size: 30),
              const SizedBox(height: 8),
              Text(
                "Preview Unavailable",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _con.filteredCreators.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CircleAvatar(
              //   radius: 30,
              //   backgroundColor: brandGreen.withOpacity(0.1),
              //   child: Text(
              //     _con.creators[index].name != null
              //         ? "${((_con.creators[index].name ?? "T")[0].toUpperCase() ?? "T")} ${((_con.creators[index].lastname ?? "A")[0].toUpperCase() ?? "T")}"
              //         : "T",
              //     style: TextStyle(
              //       color: brandGreen,
              //       fontSize: 24,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_con.filteredCreators[index].name} ${_con.filteredCreators[index].lastname}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.verified, color: brandGreen, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Verified Tese Creator",
                          style: TextStyle(color: textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Row(
                    //   children: [
                    //     Icon(Icons.star, color: Colors.orange[400], size: 14),
                    //     const Text(
                    //       " 4.9 (1.2k Supporters)",
                    //       style: TextStyle(fontSize: 11, color: Colors.grey),
                    //     ), // [cite: 11]
                    //   ],
                    // ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/CreatorPaymentLinks',
                    arguments: _con.filteredCreators[index],
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                ),
                child: const Text(
                  "View",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.home_filled, color: Colors.black87, size: 28),
          const Icon(Icons.search, color: Colors.grey, size: 28),
          _buildCenterLiveButton(),
          const Icon(
            Icons.video_library_outlined,
            color: Colors.grey,
            size: 28,
          ),
          const Icon(Icons.person_outline, color: Colors.grey, size: 28),
        ],
      ),
    );
  }

  Widget _buildCenterLiveButton() {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        color: brandRed,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: brandRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(Icons.sensors, color: Colors.white, size: 30),
    );
  }
}
