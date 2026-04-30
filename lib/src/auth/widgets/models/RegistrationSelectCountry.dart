// import 'dart:ui';
// import 'package:country_picker/country_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:smacredit/src/widgets/CustomButtons.dart';

// class RegistrationSelectCountryWidget extends StatefulWidget {
//   const RegistrationSelectCountryWidget({Key? key}) : super(key: key);

//   @override
//   _RegistrationSelectCountryWidgetState createState() =>
//       _RegistrationSelectCountryWidgetState();
// }

// class _RegistrationSelectCountryWidgetState
//     extends State<RegistrationSelectCountryWidget> {
//   Country? country;

//   // Brand Colors
//   final Color brandGreen = const Color(0xFF00D285);
//   final Color primaryDark = const Color(0xFF1A0B2E);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // resizeToAvoidBottomInset: false is useful if you had text fields here
//       body: Stack(
//         children: [
//           // 1. FULL BACKGROUND IMAGE (Consistent with Login)
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   primaryDark,
//                   const Color(0xFF2D1B4E),
//                   brandGreen.withOpacity(0.2),
//                 ],
//               ),
//               // image: DecorationImage(
//               //   image: AssetImage('assets/images/background.png'),
//               //   fit: BoxFit.cover,
//               // ),
//             ),
//           ),
//           // 2. DARK OVERLAY
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             color: Colors.black.withOpacity(0.55),
//           ),
//           // 3. APP BAR (Transparent to show background)
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: AppBar(
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               leading: const BackButton(color: Colors.white),
//             ),
//           ),

//           Positioned(
//             top: -50,
//             right: -50,
//             child: Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: brandGreen.withOpacity(0.15),
//               ),
//             ),
//           ),
//           // 4. GLASS CARD CONTENT
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: _buildGlassCard(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGlassCard() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(30),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//               width: 1.5,
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHeader(),
//               const SizedBox(height: 48),
//               _buildCountrySelector(),
//               const SizedBox(height: 48),

//               CustomButtons.filledButton(
//                 text: 'Next',
//                 callback: country != null
//                     ? () {
//                         Navigator.pushNamed(
//                           context,
//                           '/RegistrationImages',
//                           arguments: selectedCountry!,
//                         );
//                       }
//                     : () {},
//               ),
//               // _buildNextButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Image.asset('assets/images/logo-light.png', height: 70),
//         const SizedBox(height: 20),
//         const Text(
//           "SELECT COUNTRY",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.w900,
//             letterSpacing: 2,
//           ),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           "Where are you based?",
//           style: TextStyle(color: Colors.white70, fontSize: 14),
//         ),
//       ],
//     );
//   }

//   Widget _buildCountrySelector() {
//     return InkWell(
//       onTap: () {
//         showCountryPicker(
//           context: context,
//           countryFilter: ['ZW'], // Filtered as per your requirement
//           showPhoneCode: true,
//           onSelect: (Country selectedCountry) {
//             setState(() {
//               country = selectedCountry;
//             });
//           },
//           // Theming the picker itself to match
//           countryListTheme: CountryListThemeData(
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(30),
//               topRight: Radius.circular(30),
//             ),
//             inputDecoration: InputDecoration(
//               labelText: 'Search',
//               prefixIcon: const Icon(Icons.search),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: country == null
//                 ? Colors.white24
//                 : brandGreen.withOpacity(0.5),
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               Icons.public,
//               color: country == null ? Colors.white70 : brandGreen,
//               size: 24,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 country == null
//                     ? "Choose a country"
//                     : "${country!.flagEmoji}  ${country!.name}",
//                 style: TextStyle(
//                   color: country == null ? Colors.white54 : Colors.white,
//                   fontSize: 16,
//                   fontWeight: country == null
//                       ? FontWeight.normal
//                       : FontWeight.w600,
//                 ),
//               ),
//             ),
//             const Icon(Icons.arrow_drop_down, color: Colors.white70),
//           ],
//         ),
//       ),
//     );
//   }

//   void showUserTypeSelector(BuildContext context) {
//     final Color brandGreen = const Color(0xFF00D285);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent, // Required for the glass effect
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return ClipRRect(
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(30),
//                 ),
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.2),
//                   width: 1.5,
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Handle bar
//                   Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.white24,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     "Join Tese Africa",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "Choose how you want to use the platform",
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                   const SizedBox(height: 32),

//                   // CREATOR OPTION
//                   _buildOptionButton(
//                     context,
//                     title: "I am a Creator",
//                     subtitle: "Publish content and earn revenue",
//                     icon: Icons.auto_awesome,
//                     color: brandGreen,
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(
//                         context,
//                         '/RegistrationImages',
//                         arguments: selectedCountry!,
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 16),

//                   // REGULAR USER OPTION
//                   _buildOptionButton(
//                     context,
//                     title: "I am a Supporter",
//                     subtitle: "Follow creators and access content",
//                     icon: Icons.favorite_border_rounded,
//                     color: Colors.white,
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushNamed(
//                         context,
//                         '/ClientRegistration',
//                         arguments: selectedCountry!,
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildOptionButton(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.white.withOpacity(0.1)),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: color, size: 28),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(color: Colors.white60, fontSize: 13),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios,
//               color: Colors.white24,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNextButton() {
//     bool isEnabled = country != null;

//     return Container(
//       width: double.infinity,
//       height: 58,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: isEnabled
//             ? LinearGradient(colors: [brandGreen, const Color(0xFF00B876)])
//             : null,
//         color: isEnabled ? null : Colors.white.withOpacity(0.1),
//         boxShadow: [
//           if (isEnabled)
//             BoxShadow(
//               color: brandGreen.withOpacity(0.3),
//               blurRadius: 15,
//               offset: const Offset(0, 8),
//             ),
//         ],
//       ),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           shadowColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         onPressed: isEnabled
//             ? () {
//                 Navigator.pushNamed(
//                   context,
//                   '/RegistrationImages',
//                   arguments: selectedCountry!,
//                 );
//               }
//             : null,
//         child: Text(
//           "NEXT",
//           style: TextStyle(
//             color: isEnabled ? Colors.white : Colors.white24,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 2,
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smacredit/src/auth/models/WaitingPeriod.dart';
import 'package:smacredit/src/auth/models/country_model.dart';
import 'package:smacredit/src/auth/models/sign_up_type.dart';
import 'package:smacredit/src/auth/repository/login_repository.dart';
import 'package:smacredit/src/auth/widgets/models/terms_widget2.dart';
import 'package:smacredit/src/helpers/Message.dart';
import 'package:smacredit/src/repositories/settings_repository.dart';
import 'package:smacredit/src/widgets/CustomButtons.dart';

class RegistrationSelectCountryWidget extends StatefulWidget {
  const RegistrationSelectCountryWidget({Key? key}) : super(key: key);

  @override
  _RegistrationSelectCountryWidgetState createState() =>
      _RegistrationSelectCountryWidgetState();
}

class _RegistrationSelectCountryWidgetState
    extends State<RegistrationSelectCountryWidget> {
  CountryModel? selectedCountry;
  List<CountryModel> _countries = [];
  bool _loadingCountries = false;
  bool _isTermsAccepted = false;

  // Standardized Brand Colors
  final Color brandGreen = const Color(0xFF679E4F);
  final Color primaryDark = const Color(0xFF1A0B2E);

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    setState(() => _loadingCountries = true);
    final result = await get_countries();
    if (mounted) {
      setState(() {
        _countries = result;
        _loadingCountries = false;
      });
    }
  }

  void _showCountryPicker(BuildContext context, bool isDark) {
    final TextEditingController searchCtrl = TextEditingController();
    List<CountryModel> filtered = List.from(_countries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF1A0B2E),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      // Handle
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select Country',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: searchCtrl,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: brandGreen,
                          decoration: InputDecoration(
                            hintText: 'Search country...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white38,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (q) {
                            setModalState(() {
                              filtered = _countries
                                  .where(
                                    (c) => c.name.toLowerCase().contains(
                                      q.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final c = filtered[i];
                            final isSelected =
                                selectedCountry?.shortCode == c.shortCode;
                            return ListTile(
                              leading: Text(
                                c.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                              title: Text(
                                c.name,
                                style: TextStyle(
                                  color: isSelected ? brandGreen : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle_rounded,
                                      color: brandGreen,
                                    )
                                  : null,
                              onTap: () {
                                setState(() => selectedCountry = c);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeseTermsScreen(
          shouldAccept: true,
          onAcceptanceChanged: (bool accepted) {
            setState(() {
              _isTermsAccepted = accepted;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLegalSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _navigateToTerms,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isTermsAccepted
                  ? brandGreen
                  : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: _isTermsAccepted ? Colors.transparent : Colors.white24,
              ),
            ),
            child: Icon(
              _isTermsAccepted ? Icons.check_rounded : Icons.gavel_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Legal Agreement",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          _isTermsAccepted
              ? "Terms and Conditions Accepted"
              : "Review and accept terms to proceed",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _isTermsAccepted ? brandGreen : Colors.white54,
            fontSize: 12,
          ),
        ),
        if (!_isTermsAccepted)
          TextButton(
            onPressed: _navigateToTerms,
            child: Text(
              "VIEW TERMS",
              style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Stack(
          children: [

            // App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildGlassCard(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.05 : 0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 48),
              _buildCountrySelector(isDark),
              const SizedBox(height: 48),
              _buildLegalSection(),
              const SizedBox(height: 48),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo-light.png',
          height: 70,
          errorBuilder: (c, e, s) =>
              Icon(Icons.public_rounded, color: brandGreen, size: 60),
        ),
        const SizedBox(height: 20),
        const Text(
          "SELECT COUNTRY",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
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

  Widget _buildCountrySelector(bool isDark) {
    return InkWell(
      onTap: _loadingCountries
          ? null
          : () => _showCountryPicker(context, isDark),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedCountry == null ? Colors.white24 : brandGreen,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (_loadingCountries)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white38,
                ),
              )
            else
              Text(
                selectedCountry == null ? '🌐' : selectedCountry!.flag,
                style: const TextStyle(fontSize: 22),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _loadingCountries
                    ? 'Loading countries...'
                    : selectedCountry == null
                    ? 'Choose a country'
                    : selectedCountry!.name,
                style: TextStyle(
                  color: selectedCountry == null
                      ? Colors.white30
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: selectedCountry == null
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    bool isEnabled = selectedCountry != null && _isTermsAccepted;

    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: isEnabled
            ? LinearGradient(colors: [brandGreen, Colors.yellow.shade700])
            : null,
        color: isEnabled ? null : Colors.white.withOpacity(0.05),
      ),
      child: TextButton(
        onPressed: isEnabled
            ? () async {
                WaitingPeriodModel? result = await check_waiting_period();
                if (result != null) {
                  _showUserTypeSelector(context, result);
                } else {
                  CustomMessageHandler().showErrorSnakeBar(
                    context,
                    "Something went wrong.Try again",
                  );
                }
              }
            : null,
        child: Text(
          "NEXT",
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  void _showUserTypeSelector(
    BuildContext context,
    WaitingPeriodModel waitingPeriodModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF1A0B2E,
                ).withOpacity(0.9), // Deep dark for contrast
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                    "Select your account type to continue",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _buildOptionButton(
                    title: "I am a Creator",
                    subtitle: waitingPeriodModel.status == true
                        ? waitingPeriodModel.message ?? "Join the waiting list"
                        : "Publish content and earn revenue",
                    icon: Icons.auto_awesome,
                    color: brandGreen,
                    onTap: () {
                      waiting_period.value = waitingPeriodModel;
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/CheckEmail',
                        arguments: {
                          'signUpType': SignUpType.creator,
                          'countryModel': selectedCountry,
                        },
                      );
                      // Navigator.pushNamed(
                      //   context,
                      //   '/RegistrationImages',
                      //   arguments: selectedCountry!,
                      // );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildOptionButton(
                    title: "I am a Supporter",
                    subtitle: "Follow creators and access content",
                    icon: Icons.favorite_border_rounded,
                    color: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/SignUpMethod',
                        arguments: selectedCountry!,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
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
}
