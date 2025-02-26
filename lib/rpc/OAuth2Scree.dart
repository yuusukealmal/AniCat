import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuth2Screen extends StatefulWidget {
  const OAuth2Screen({super.key});

  @override
  State<OAuth2Screen> createState() => _OAuth2ScreenState();
}

class _OAuth2ScreenState extends State<OAuth2Screen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    String clientId = dotenv.env['CLIENT_ID']!;
    String redirectUri = dotenv.env['REDIRECT_URI']!;
    const scopes = 'rpc identify';

    final url = Uri.parse(
      'https://discord.com/oauth2/authorize?'
      'client_id=$clientId&'
      'response_type=code&'
      'redirect_uri=$redirectUri&'
      'scope=${Uri.encodeComponent(scopes)}',
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(redirectUri)) {
              final uri = Uri.parse(request.url);
              final code = uri.queryParameters['code'];

              if (code != null) {
                debugPrint('Authorization Code: $code');
                Navigator.pop(context, code);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Error:${uri.queryParameters['error_description']}'),
                  ),
                );
                Navigator.pop(context);
              }

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discord OAuth2'),
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
