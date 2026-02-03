import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:smacredit/src/auth/widgets/models/page.dart';
import 'package:smacredit/src/widgets/CustomButtons.dart';

class OnBoardingWidget extends StatefulWidget {
  const OnBoardingWidget({super.key});

  @override
  _OnBoardingWidgetState createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  List<PageViewModel> pages = [];

  List<Widget> rawPages = [];

  @override
  initState() {
    loadPages();
    super.initState();
  }

  loadPages() async {
    await Future.delayed(Duration.zero);
    rawPages.add(
      OnBoardingPage(
        body:
            'Instant notifications for every transaction. Transfer funds to your bank instantly',
        title: "Get Paid.",
        showSkip: true,

        image: "assets/images/image1.png",
        onNext: () {
          return _introKey.currentState?.next();
        },
      ),
    );
    rawPages.add(
      OnBoardingPage(
        body:
            'Create pofessional payment links in seconds. Simply enter the amount and description.',
        title: "Generate your payment link now",
        showSkip: true,

        image: "assets/images/image2.png",
        onNext: () {
          return _introKey.currentState?.next();
        },
      ),
    );

    rawPages.add(
      OnBoardingPage(
        body:
            'Share your payment link on Youtube, Instagram, Facebook and X. Get paid from any social platform',
        title: "Share on all social media platforms.",

        image: "assets/images/image3.png",
        onNext: () {
          Navigator.pushNamed(context, '/Login');
        },
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: rawPages.isEmpty
            ? const SizedBox.shrink()
            : IntroductionScreen(
                rawPages: rawPages,
                key: _introKey,
                showDoneButton: false,
                showNextButton: false,
                showSkipButton: false,
                dotsDecorator: const DotsDecorator(
                  size: Size.square(10.0),
                  activeSize: Size(20.0, 10.0),
                  activeColor: Colors.white,
                  color: Colors.white10,
                  spacing: EdgeInsets.symmetric(horizontal: 3.0),
                ),
              ),
      ),
    );
  }
}
