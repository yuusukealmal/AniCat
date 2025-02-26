import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String> getAccessToken(String authorizationCode) async {
  String clientId = dotenv.env['CLIENT_ID']!;
  String clientSecret = dotenv.env['CLIENT_SECRET']!;
  String redirectUri = dotenv.env['REDIRECT_URI']!;

  final response = await http.post(
    Uri.parse('https://discord.com/api/oauth2/token'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'authorization_code',
      'code': authorizationCode,
      'redirect_uri': redirectUri,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['access_token'];
  } else {
    throw 'Failed to get Access Token: ${response.body}';
  }
}
