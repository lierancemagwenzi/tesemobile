import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smacredit/src/auth/widgets/models/terms_widget.dart';
import 'package:smacredit/src/auth/widgets/models/terms_widget2.dart';
import 'package:smacredit/src/widgets/CustomButtons.dart';

import '../../../models/constants.dart';

class FirstWidget extends StatefulWidget {
  const FirstWidget({Key? key}) : super(key: key);

  @override
  _FirstWidgetState createState() => _FirstWidgetState();
}

class _FirstWidgetState extends State<FirstWidget> {
  bool? installed;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getInatalled();
  }

  getInatalled() async {
    SharedPreferences pres = await SharedPreferences.getInstance();

    bool? result = pres.getBool('installed');

    if (result == true) {
      setState(() {
        installed = true;
      });
    } else {
      setState(() {
        installed = false;
      });
    }
  }

  void _navigateToTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeseTermsScreen(
          shouldAccept: false,
          onAcceptanceChanged: (bool value) {
            // This code runs when the user clicks "Accept and Continue"
            setState(() {
              // _isTermsAccepted = value;
            });

            // OPTIONAL: Call your backend API here to update Sequelize

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Terms accepted successfully!")),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegalFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.black54, fontSize: 13),
          children: [
            const TextSpan(text: "By continuing, you agree to our "),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => _navigateToTerms(),
                child: const Text(
                  "Terms",
                  style: TextStyle(
                    color: Color(0xFF00D285),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const TextSpan(text: " and "),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: GestureDetector(
                onTap: () => _navigateToPrivacy(),
                child: const Text(
                  "Privacy Policy",
                  style: TextStyle(
                    color: Color(0xFF00D285),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },

      child: installed == null
          ? Container(color: Colors.white)
          : Scaffold(
              backgroundColor: Colors.white,
              bottomNavigationBar: buttons(),
              body: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage("assets/images/logo.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  buttons() {
    return installed == true
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegalFooter(),
                  CustomButtons.filledButton(
                    text: 'Sign In',
                    callback: () {
                      Navigator.pushNamed(context, '/ClientLogin');
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomButtons.outlineButton(
                    text: 'Register',
                    callback: () {
                      Navigator.pushNamed(context, '/CheckEmail');
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomButtons.filledButton(
                    text: 'Get Started',
                    callback: () {
                      Navigator.pushNamed(context, '/OnBoarding');
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
  }

  void _navigateToPrivacy() {
    Navigator.pushNamed(context, '/Policy');
  }
}
