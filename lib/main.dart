import 'package:flutter/material.dart';
import 'package:anicat/parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniCat Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 183, 58, 156)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AniCat'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _onAddButtonPressed() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController textController = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Anime1 URL'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter URL here',
            ),
            maxLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final inputUrl = textController.text;
                Navigator.of(context).pop();
                Future<List<String>> list = parse(inputUrl);
                debugPrint(list.toString());
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: Text(widget.title),
      ),
      body: const Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddButtonPressed,
        tooltip: 'Add Anime1 URL',
        child: const Icon(Icons.add),
      ),
    );
  }
}
