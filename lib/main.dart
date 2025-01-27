import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/config/notifier/HomeColorNotifier.dart';
import 'package:anicat/pages/MyHomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            final colorNotifier = ColorNotifier();
            colorNotifier.init();
            return colorNotifier;
          }),
        ],
        builder: (context, child) {
          final color = Provider.of<ColorNotifier>(context);
          return MaterialApp(
            title: "AniCat Downloader",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: color.color ?? Color.fromARGB(255, 183, 58, 156)),
              useMaterial3: true,
            ),
            home: const MyHomePage(title: "AniCat"),
            navigatorObservers: [routeObserver],
          );
        });
  }
}
