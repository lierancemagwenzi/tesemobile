import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TesePaymentWebView extends StatefulWidget {
  final String initialUrl;
  final String successUrl;
  final VoidCallback onPaymentSuccess;

  const TesePaymentWebView({
    super.key,
    required this.initialUrl,
    required this.successUrl,
    required this.onPaymentSuccess,
  });

  @override
  State<TesePaymentWebView> createState() => _TesePaymentWebViewState();
}

class _TesePaymentWebViewState extends State<TesePaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onNavigationRequest: (NavigationRequest request) {
            // Detect if the payment was successful based on the URL
            if (request.url.contains(widget.successUrl)) {
              widget.onPaymentSuccess();
              return NavigationDecision
                  .prevent; // Stop loading the success page
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Payment"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B5E20)),
            ),
        ],
      ),
    );
  }
}
