// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maktub/core/constants/constants.dart';
import 'package:maktub/presentation/blocs/register/register_bloc.dart';
import 'package:maktub/presentation/blocs/register/register_event.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class WebViewBottomSheet extends StatefulWidget {
  final String url;
  final String webTitle;
  const WebViewBottomSheet({
    super.key,
    required this.url,
    required this.webTitle,
  });

  @override
  State<WebViewBottomSheet> createState() => _WebViewBottomSheetState();
}

class _WebViewBottomSheetState extends State<WebViewBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _sheetController;
  late Animation<Offset> _slideAnimation;
  late final WebViewController _controller;
  double _progress = 0;
  bool _shouldShowLoader = true;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // снизу
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetController, curve: Curves.easeOut));

    _sheetController.forward();

    // Минимум 800мс показываем лоадер, даже если загрузка быстрая
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _shouldShowLoader = false;
        });
      }
    });

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == "close") {
            context.pop();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() => _progress = progress / 100.0);
            }
          },
          onNavigationRequest: (request) async {
            final url = request.url;

            if (url.startsWith("https://maktub.kz/callback?code=")) {
              final uri = Uri.parse(url);

              if (uri.queryParameters.containsKey("error")) {
                final String error = uri.queryParameters["error"]!;
                context.read<RegisterBloc>().add(RegisterFailureEvent(error));
                WebViewCookieManager().clearCookies();
                _controller.clearCache();
                await _controller.runJavaScript('''
  localStorage.clear();
  sessionStorage.clear();
''');
                context.pop();
              } else if (uri.queryParameters.containsKey("code")) {
                final String code = uri.queryParameters["code"]!;
                final url = Uri.parse(
                  'https://zmnbmhkgdhijswyggghx.supabase.co/functions/v1/smart-responder',
                );

                final response = await http.post(
                  url,
                  headers: {
                    'Content-Type': 'application/json',
                 
                  },
                  body: jsonEncode({'code': code}),
                );

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  final String idToken = data['id_token'];

                  var map = extractDataIdToken(idToken);

                  String phone = extractPhoneFromData(map).substring(1);

                  context.read<RegisterBloc>().add(
                    RegisterCheckPhoneExists(phone),
                  );
                }

                _controller.clearCache();

                WebViewCookieManager().clearCookies();
                await _controller.runJavaScript('''
  localStorage.clear();
  sessionStorage.clear();
''');
                context.pop();
              }

              return NavigationDecision.prevent;
            }
            if (url.contains('error')) {

              WebViewCookieManager().clearCookies();
              _controller.clearCache();
              await _controller.runJavaScript('''
  localStorage.clear();
  sessionStorage.clear();
''');

              context.read<RegisterBloc>().add(RegisterFailureEvent('қате'));

              context.pop();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  String extractPhoneFromData(Map map) {
    return map['phone'] as String;
  }

  Map extractDataIdToken(String idToken) {
    final parts = idToken.split('.');
    if (parts.length != 3) {
      throw Exception('Неверный JWT токен');
    }

    final payload = _decodeBase64(parts[1]);

    final payloadMap = json.decode(payload);

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Неверная длина base64 строки');
    }
    return utf8.decode(base64Url.decode(output));
  }

  @override
  void dispose() {
    _controller.clearCache(); // необязательно, но полезно
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (_) => true,
          child: DraggableScrollableSheet(
            initialChildSize: 0.90,
            maxChildSize: 0.93,
            minChildSize: 0.89,

            expand: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(
                              widget.webTitle,
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
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: () async => {
                                context.pop(),
                                await _controller.loadHtmlString(
                                  '<html><body></body></html>',
                                ),
                                await _controller.runJavaScript('''
            localStorage.clear();
            sessionStorage.clear();
          '''),
                                WebViewCookieManager().clearCookies(),
                                _controller.clearCache(),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🟢 Лоадер под заголовком
                    if (_shouldShowLoader || _progress < 1)
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween<double>(begin: 0, end: _progress),
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            color: MaktubConstants.primaryColor,
                            backgroundColor: const Color(0xFFE0F4E6),
                            minHeight: 2,
                          );
                        },
                      ),

                    // 🌐 WebView
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          // Этот слушатель будет получать уведомления о скролле внутри WebView.
                          // Если WebView достигает своих границ, DraggableScrollableSheet должен начать скроллиться.
                          // Этот механизм должен работать автоматически при правильной настройке
                          // DraggableScrollableSheet и Expanded.
                          return false; // Возвращаем false, чтобы уведомление продолжало распространяться.
                        },
                        child: WebViewWidget(controller: _controller),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
