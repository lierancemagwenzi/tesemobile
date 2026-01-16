import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smacredit/client/home/login_promt.dart';
import 'package:smacredit/src/repositories/user_repository.dart';

class UtilsHelper {
  static String formatLongDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    // Only show hours if the video is 1 hour or longer
    return duration.inHours > 0
        ? "$hours:$minutes:$seconds"
        : "$minutes:$seconds";
  }

  static String formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      double result = number / 1000;
      // Show one decimal if it's not a whole number (e.g., 4.5K)
      return result % 1 == 0
          ? '${result.toInt()}K'
          : '${result.toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      double result = number / 1000000;
      return result % 1 == 0
          ? '${result.toInt()}M'
          : '${result.toStringAsFixed(1)}M';
    } else {
      double result = number / 1000000000;
      return result % 1 == 0
          ? '${result.toInt()}B'
          : '${result.toStringAsFixed(1)}B';
    }
  }

  static void ensureAuth(
    BuildContext context, {
    required String action,
    required VoidCallback onAuthenticated,
  }) {
    bool isAuthenticated = currentuser.value.user?.id != null;

    if (isAuthenticated) {
      onAuthenticated(); // User is logged in, perform the action
    } else {
      // Show the modal prompt
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent, // Required for rounded corners
        isScrollControlled: true,
        builder: (context) => AuthPromptModal(actionText: action),
      );
    }
  }
}
