
import 'package:flutter/material.dart';

class OnBoardingPage extends StatelessWidget {
  final String image;
  final Widget button;
  final String title;
  final String body;
  final bool showSkip;
  const OnBoardingPage(
      {super.key,
      required this.body,
      required this.title,
      required this.button,
      required this.image,
      this.showSkip = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          image,
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          alignment: Alignment.center,
        ),
        showSkip
            ? Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                    onTap: () {
                     Navigator.pushNamed(context, '/Login');
                    },
                    child: SafeArea(
                      child: Text('Skip',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white70)),
                    )))
            : const SizedBox.shrink(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ignore: use_build_context_synchronously
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  body,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(
                  height: 20,
                ),
                button,

                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
