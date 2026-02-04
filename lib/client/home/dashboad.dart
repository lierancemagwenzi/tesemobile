import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:smacredit/client/downloads/widgets/downloads.dart';
import 'package:smacredit/client/events/events.dart';
import 'package:smacredit/client/home/home.dart';
import 'package:smacredit/client/libary/library_widget.dart';
import 'package:smacredit/client/profile/client_pofile.dart';
import 'package:smacredit/client/search/search_widget.dart';
import 'package:smacredit/src/theme/app_theme.dart';
// Note: Ensure your local paths for these imports are correct
// import 'package:smacredit/src/home/controller/client_controller.dart';
// import 'package:smacredit/src/models/UserModel.dart';

// --- DUMMY MODELS ---

// --- DASHBOARD WIDGET ---

class ClientDashboardWidget extends StatefulWidget {
  final int? index;
  const ClientDashboardWidget({super.key, this.index});

  @override
  _ClientDashboardWidgetState createState() => _ClientDashboardWidgetState();
}

class _ClientDashboardWidgetState extends StateMVC<ClientDashboardWidget> {
  // Dummy data initialization

  int currentIndex = 0;
  _ClientDashboardWidgetState()
    : super(null); // Passing null here since ClientController is external

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.index != null) {
      currentIndex = widget.index!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        bottomNavigationBar: _buildBottomNav(context, isDark),
        // floatingActionButton: _buildFab(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: [
          ClientHomeWidget(),

          // DownloadsScreen(),
          SearchWidget(),
          // LiveEventsWidget(),
          MyLibraryWidget(),
          ClientProfileScreen(),
        ][currentIndex],
      ),
    );
  }

  // 1. FEATURED HERO (Cinematic style - stays dark in both modes)

  // 5. NAVIGATION
  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return BottomAppBar(
      color: isDark ? const Color(0xFF161B22) : Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: currentIndex == 0 ? brandGreen : Colors.grey,
              ),
              onPressed: () {
                changeScreen(0);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.search,
                color: currentIndex == 1 ? brandGreen : Colors.grey,
              ),
              onPressed: () {
                changeScreen(1);
              },
            ),
            // const SizedBox(width: 40),
            IconButton(
              icon: Icon(
                Icons.video_library,
                color: currentIndex == 2 ? brandGreen : Colors.grey,
              ),
              onPressed: () {
                changeScreen(2);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: currentIndex == 3 ? brandGreen : Colors.grey,
              ),
              onPressed: () {
                changeScreen(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  void changeScreen(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        changeScreen(2);
      },
      backgroundColor: brandRed,
      shape: const CircleBorder(),
      child: const Icon(Icons.sensors, color: Colors.white, size: 30),
    );
  }
}
