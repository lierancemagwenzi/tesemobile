import 'dart:ui';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/src/widgets/CustomButtons.dart';

class RegistrationSelectCountryWidget extends StatefulWidget {
  const RegistrationSelectCountryWidget({Key? key}) : super(key: key);

  @override
  _RegistrationSelectCountryWidgetState createState() =>
      _RegistrationSelectCountryWidgetState();
}

class _RegistrationSelectCountryWidgetState
    extends State<RegistrationSelectCountryWidget> {
  Country? country;

  // Brand Colors
  final Color brandGreen = const Color(0xFF00D285);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false is useful if you had text fields here
      body: Stack(
        children: [
          // 1. FULL BACKGROUND IMAGE (Consistent with Login)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryDark,
                  const Color(0xFF2D1B4E),
                  brandGreen.withOpacity(0.2),
                ],
              ),
              // image: DecorationImage(
              //   image: AssetImage('assets/images/background.png'),
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          // 2. DARK OVERLAY
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.55),
          ),
          // 3. APP BAR (Transparent to show background)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const BackButton(color: Colors.white),
            ),
          ),

          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandGreen.withOpacity(0.15),
              ),
            ),
          ),
          // 4. GLASS CARD CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _buildGlassCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 48),
              _buildCountrySelector(),
              const SizedBox(height: 48),

              CustomButtons.filledButton(
                text: 'Next',
                callback: country != null
                    ? () {
                        showUserTypeSelector(context);
                      }
                    : () {},
              ),
              // _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/images/logo-light.png', height: 70),
        const SizedBox(height: 20),
        const Text(
          "SELECT COUNTRY",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Where are you based?",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCountrySelector() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          countryFilter: ['ZW'], // Filtered as per your requirement
          showPhoneCode: true,
          onSelect: (Country selectedCountry) {
            setState(() {
              country = selectedCountry;
            });
          },
          // Theming the picker itself to match
          countryListTheme: CountryListThemeData(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            inputDecoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: country == null
                ? Colors.white24
                : brandGreen.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.public,
              color: country == null ? Colors.white70 : brandGreen,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                country == null
                    ? "Choose a country"
                    : "${country!.flagEmoji}  ${country!.name}",
                style: TextStyle(
                  color: country == null ? Colors.white54 : Colors.white,
                  fontSize: 16,
                  fontWeight: country == null
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  void showUserTypeSelector(BuildContext context) {
    final Color brandGreen = const Color(0xFF00D285);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Required for the glass effect
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Join Tese Africa",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Choose how you want to use the platform",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // CREATOR OPTION
                  _buildOptionButton(
                    context,
                    title: "I am a Creator",
                    subtitle: "Publish content and earn revenue",
                    icon: Icons.auto_awesome,
                    color: brandGreen,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/RegistrationImages',
                        arguments: country!,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // REGULAR USER OPTION
                  _buildOptionButton(
                    context,
                    title: "I am a Supporter",
                    subtitle: "Follow creators and access content",
                    icon: Icons.favorite_border_rounded,
                    color: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/ClientRegistration',
                        arguments: country!,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    bool isEnabled = country != null;

    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isEnabled
            ? LinearGradient(colors: [brandGreen, const Color(0xFF00B876)])
            : null,
        color: isEnabled ? null : Colors.white.withOpacity(0.1),
        boxShadow: [
          if (isEnabled)
            BoxShadow(
              color: brandGreen.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isEnabled
            ? () {
                Navigator.pushNamed(
                  context,
                  '/RegistrationImages',
                  arguments: country!,
                );
              }
            : null,
        child: Text(
          "NEXT",
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white24,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
