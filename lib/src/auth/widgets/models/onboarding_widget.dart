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
            'Cut out the middlemen. We give you instant, secure payment links so fans can tip, support, and pay you for your unique content, passion, and time—no platform fees required',
        title: "Get Paid Directly for Your Talent.",
        showSkip: true,
        button: SizedBox(
          height: 50,
          child: CustomButtons.filledButton(
            text: 'Next',
            callback: () {
              return _introKey.currentState?.next();
            },
          ),
        ),
        image: "assets/images/bg1.png",
      ),
    );
    rawPages.add(
      OnBoardingPage(
        body:
            'From one-time tips for a great video to setting up a custom price for a personalized commission or selling exclusive merch, create the exact payment link you need in seconds.',
        title: "Monetize Every Idea, Effortlessly.",
        showSkip: true,
        button: SizedBox(
          height: 50,
          child: CustomButtons.filledButton(
            text: 'Next',
            callback: () {
              return _introKey.currentState?.next();
            },
          ),
        ),
        image: "assets/images/bg2.png",
      ),
    );

    rawPages.add(
      OnBoardingPage(
        body:
            'Keep 100% of your fan data and leverage powerful insights to grow your paying community. Whether you\'re selling custom goods or accepting support, manage everything in one place.',
        title: "Your Content, Your Business.",
        button: SizedBox(
          height: 50,
          child: CustomButtons.filledButton(
            text: 'Next',
            callback: () {
              Navigator.pushNamed(context, '/Login');
            },
          ),
        ),
        image: "assets/images/bg3.png",
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
