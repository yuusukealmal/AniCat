import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/config/StoragePermission.dart';
import 'package:anicat/functions/behavior/PathLoad.dart';
import 'package:anicat/config/notifier/HomeColorNotifier.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with Load, StoragePermission {
  int? selectedColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.keyboard_backspace_sharp),
        ),
      ),
      body: RefreshIndicator(
          onRefresh: () => Future.value(),
          child: ListView(
            children: [
              ListTile(
                title: const Text("Change Theme Color"),
                trailing: IconButton(
                  icon: const Icon(Icons.color_lens),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text("Change Theme Color"),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: Color(selectedColor ??
                                Theme.of(context).colorScheme.primary.value),
                            onColorChanged: (Color color) {
                              selectedColor = color.value;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () async {
                              final colorNotifier = Provider.of<ColorNotifier>(
                                  context,
                                  listen: false);
                              colorNotifier.setColor(Color(selectedColor!));
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              FutureBuilder(
                future: getDownloadPath(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListTile(
                      title: const Text("Change Download Path"),
                      subtitle: Text(snapshot.data!.path),
                      trailing: IconButton(
                        icon: const Icon(Icons.folder),
                        onPressed: () async {
                          var changeDownloadPath =
                              await checkPermission(context);
                          if (changeDownloadPath != null) {
                            await SharedPreferencesHelper.setString(
                                "Anime.DownloadPath", changeDownloadPath);
                            setState(() {});
                          }
                        },
                      ),
                    );
                  } else {
                    return ListTile(
                      title: const Text("Change Download Path"),
                      subtitle: const Text("Loading..."),
                      trailing: IconButton(
                        icon: const Icon(Icons.folder),
                        onPressed: () {},
                      ),
                    );
                  }
                },
              ),
              ListTile(
                  title: const Text("Reset Shared Preferences"),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                  title: const Text("Reset Shared Preferences"),
                                  content: const Text(
                                      "Are you sure you want to Reset shared preferences?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: const Text("Reset"),
                                      onPressed: () async {
                                        await SharedPreferencesHelper.reset();
                                        final colorNotifier =
                                            Provider.of<ColorNotifier>(context,
                                                listen: false);
                                        colorNotifier.setColor(Color(
                                            SharedPreferencesHelper.getInt(
                                                "Home.Color")!));
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ])))),
              ListTile(
                  title: const Text("Clear Cache"),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                  title: const Text("Clear Cache"),
                                  content: const Text(
                                      "Are you sure you want to clear cache?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                    TextButton(
                                      child: const Text("Clear"),
                                      onPressed: () async {
                                        final cache = await getCacheImgFolder();
                                        await for (var entity in cache.list()) {
                                          await entity.delete(recursive: true);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ]))))
            ],
          )),
    );
  }
}
