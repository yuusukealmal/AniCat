import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/config/notifier/HomeColorProvider.dart';
import 'package:anicat/config/notifier/ThemeProvider.dart';
import 'package:anicat/pages/MyHomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesHelper.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ColorProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
    final color = Provider.of<ColorProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: "AniCat Downloader",
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color.color ?? const Color.fromARGB(255, 183, 58, 156),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color.color ?? const Color.fromARGB(255, 183, 58, 156),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      home: const MyHomePage(title: "AniCat"),
      navigatorObservers: [routeObserver],
    );
  }
}
