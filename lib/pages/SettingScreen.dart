import 'package:flutter/material.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/config/StoragePermission.dart';
import 'package:anicat/functions/behavior/PathLoad.dart';
import 'package:anicat/functions/behavior/SettingScreenonPress.dart';

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
          child: ListView(children: [
            ExpansionTile(
              title: Text("Basic Settings"),
              children: [
                GestureDetector(
                  onTap: () => onChangeColoronPress(context, selectedColor),
                  child: ListTile(
                    title: Text("Change Theme Color"),
                    trailing: Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.color_lens),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: getDownloadPath(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return GestureDetector(
                          child: ListTile(
                            title: const Text("Change Download Path"),
                            subtitle: Text(snapshot.data!.path),
                            trailing: Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: Icon(Icons.folder)),
                          ),
                          onTap: () async {
                            var changeDownloadPath =
                                await checkPermission(context);
                            if (changeDownloadPath != null) {
                              await SharedPreferencesHelper.setString(
                                  "Anime.DownloadPath", changeDownloadPath);
                              setState(() {});
                            }
                          });
                    } else {
                      return GestureDetector(
                        child: ListTile(
                          title: const Text("Change Download Path"),
                          subtitle: const Text("Loading..."),
                          trailing: Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: Icon(Icons.folder)),
                        ),
                      );
                    }
                  },
                ),
                GestureDetector(
                    child: ListTile(
                      title: const Text("Reset Shared Preferences"),
                      trailing: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.delete),
                      ),
                    ),
                    onTap: () => onResetSharedPreferences(context)),
                GestureDetector(
                    child: ListTile(
                      title: const Text("Clear Cache"),
                      trailing: Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(Icons.delete),
                      ),
                    ),
                    onTap: () => onClearCache(context)),
              ],
            ),
            ExpansionTile(title: Text("Video Settings"), children: [
              ListTile(
                  title: Text("Auto Play"),
                  trailing: Switch(
                    value: SharedPreferencesHelper.getBool("Video.AutoPlay") ??
                        false,
                    onChanged: (value) async {
                      await SharedPreferencesHelper.setBool(
                          "Video.AutoPlay", value);
                      setState(() {});
                    },
                  )),
              ListTile(
                  title: Text("Fullscreen by Default"),
                  trailing: Switch(
                    value:
                        SharedPreferencesHelper.getBool("Video.FullScreen") ??
                            false,
                    onChanged: (value) async {
                      await SharedPreferencesHelper.setBool(
                          "Video.FullScreen", value);
                      setState(() {});
                    },
                  )),
              ListTile(
                title: Text("Playback Speed"),
                trailing: DropdownButton(
                  value: SharedPreferencesHelper.getDouble(
                          "Video.PlaybackSpeed") ??
                      1,
                  items: const [
                    DropdownMenuItem(value: 0.5, child: Text("0.5")),
                    DropdownMenuItem(value: 1.0, child: Text("1")),
                    DropdownMenuItem(value: 1.5, child: Text("1.5")),
                    DropdownMenuItem(value: 2.0, child: Text("2")),
                    DropdownMenuItem(value: 4.0, child: Text("4")),
                  ],
                  onChanged: (value) async {
                    await SharedPreferencesHelper.setDouble(
                        "Video.PlaybackSpeed", value?.toDouble() ?? 1.0);
                    setState(() {});
                  },
                ),
              ),
            ])
          ])),
    );
  }
}
