import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:anicat/pages/AnimeList.dart';
import 'package:anicat/pages/AnimeSearch.dart';
import 'package:anicat/pages/SettingScreen.dart';
import 'package:anicat/config/notifier/ThemeProvider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;

  static const List<Widget> _pagesList = <Widget>[
    AnimeList(),
    AnimeSearch(),
    SettingScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode_outlined),
            tooltip: 'Toggle Theme',
            onPressed: context.read<ThemeProvider>().toggleTheme,
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _pagesList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_display),
            label: '影片列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '新增',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: '設置',
          ),
        ],
        currentIndex: _index,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
