import 'package:flutter/material.dart';

import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/config/StoragePermission.dart';
import 'package:anicat/functions/behavior/PathHandle.dart';
import 'package:anicat/widget/SettingScreen/onChangeColoronPress.dart';
import 'package:anicat/widget/SettingScreen/onResetSharedPreferences.dart';
import 'package:anicat/widget/SettingScreen/onClearCache.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with PathHandle, StoragePermission {
  int? selectedColor;
  bool? autoPlay;
  bool? fullScreen;
  double? playbackSpeed;

  @override
  void initState() {
    super.initState();
    autoPlay = SharedPreferencesHelper.getBool("Video.AutoPlay");
    fullScreen = SharedPreferencesHelper.getBool("Video.FullScreen");
    playbackSpeed = SharedPreferencesHelper.getDouble("Video.PlaybackSpeed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => Future.value(),
        child: ListView(
          children: [
            ExpansionTile(
              title: Text("Basic Settings"),
              initiallyExpanded: true,
              children: [
                ListTile(
                  title: Text("Change Theme Color"),
                  trailing: const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.color_lens),
                  ),
                  onTap: () => onChangeColoronPress(context, selectedColor),
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return FutureBuilder(
                      future: PathHandle.getDownloadPath(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          );
                        }
                        return ListTile(
                          title: const Text("Change Download Path"),
                          subtitle: Text(snapshot.data!.path),
                          trailing: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(Icons.folder),
                          ),
                          onTap: () async {
                            String? path = await checkPermission(context);
                            if (path != null) {
                              await SharedPreferencesHelper.setString(
                                "Anime.DownloadPath",
                                path,
                              );
                              setState(() {});
                            }
                          },
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: const Text("Reset Shared Preferences"),
                  trailing: const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.delete),
                  ),
                  onTap: () => onResetSharedPreferences(context),
                ),
                ListTile(
                  title: const Text("Clear Cache"),
                  trailing: const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.delete),
                  ),
                  onTap: () => onClearCache(context),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("Video Settings"),
              initiallyExpanded: true,
              children: [
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        ListTile(
                          title: const Text("Auto Play"),
                          trailing: Switch(
                            value: autoPlay ?? false,
                            onChanged: (value) async {
                              await SharedPreferencesHelper.setBool(
                                  "Video.AutoPlay", value);
                              if (!value) {
                                await SharedPreferencesHelper.setBool(
                                    "Video.FullScreen", false);
                                fullScreen = false;
                              }
                              setState(() {
                                autoPlay = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text("Fullscreen by Default"),
                          trailing: Switch(
                            value: fullScreen ?? false,
                            onChanged: autoPlay == true
                                ? (value) async {
                                    await SharedPreferencesHelper.setBool(
                                        "Video.FullScreen", value);
                                    setState(() {
                                      fullScreen = value;
                                    });
                                  }
                                : null,
                          ),
                        ),
                        ListTile(
                          title: const Text("Playback Speed"),
                          trailing: DropdownButton<double>(
                            value: playbackSpeed ?? 1.0,
                            items: const [
                              DropdownMenuItem(
                                value: 0.5,
                                child: Text("0.5x"),
                              ),
                              DropdownMenuItem(
                                value: 1.0,
                                child: Text("1.0x"),
                              ),
                              DropdownMenuItem(
                                value: 1.5,
                                child: Text("1.5x"),
                              ),
                              DropdownMenuItem(
                                value: 2.0,
                                child: Text("2.0x"),
                              ),
                              DropdownMenuItem(
                                value: 4.0,
                                child: Text("4.0x"),
                              ),
                            ],
                            onChanged: (value) async {
                              final speed = value ?? 1.0;
                              await SharedPreferencesHelper.setDouble(
                                  "Video.PlaybackSpeed", speed);
                              setState(() {
                                playbackSpeed = speed;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
