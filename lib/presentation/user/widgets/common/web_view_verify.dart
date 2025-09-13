import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewVerificationPage extends StatefulWidget {
  final String url;
  const WebViewVerificationPage({super.key, required this.url});

  @override
  State<WebViewVerificationPage> createState() => _WebViewVerificationPageState();
}

class _WebViewVerificationPageState extends State<WebViewVerificationPage> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _shouldShowLoader = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _shouldShowLoader = false;
        });
      }
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => _progress = progress / 100.0);
          },
          onPageStarted: (url) {
            if (url.contains("code=")) {
              Navigator.pop(context, url);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      "жеке басын растау",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            if (_shouldShowLoader || _progress < 1)
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0, end: _progress),
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    color: const Color(0xFF01bc41),
                    backgroundColor: const Color(0xFFE0F4E6),
                    minHeight: 2,
                  );
                },
              ),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
