import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String _webClientId = '861792777675-h57k0qrh9j0qlm3nkj56p4v948q7kh7h.apps.googleusercontent.com';
  // Define your scopes in a list
  final List<String> _scopes = ['email', 'profile'];

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> handleGoogleSignIn() async {
    try {
      // 1. Initialize exactly once (only basic config here)
      await _googleSignIn.initialize(serverClientId: _webClientId);

      // 2. Sign in and request scopes using 'scopeHint'
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: _scopes,
      );

      if (googleUser == null) return;

      // 3. Get the authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        // Send this to your Node.js backend
        print("Success! Token found: $idToken");
      }
    } catch (error) {
      print('Google Sign-In Error: $error');
    }
  }
}
