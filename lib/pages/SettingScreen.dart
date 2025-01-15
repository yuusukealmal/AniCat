import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:anicat/config/SharedPreferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
        child: ListView.builder(
            itemCount: 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: Text("Change Theme Color"),
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
                                setState(() {
                                  selectedColor = color.value;
                                });
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
                                await SharedPreferencesHelper.setInt(
                                    "Home.Color",
                                    selectedColor ??
                                        Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .value);
                                setState(() {
                                  final ThemeData themeData = ThemeData(
                                    colorScheme: ColorScheme.fromSeed(
                                      seedColor: Color(selectedColor ??
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .value),
                                    ),
                                  );
                                  Theme.of(super.context).copyWith(
                                    colorScheme: themeData.colorScheme,
                                  );
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
              if (index == 1) {
                return ListTile(
                    title: Text("Clear Shared Preferences"),
                    trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                    title:
                                        const Text("Clear Shared Preferences"),
                                    content: const Text(
                                        "Are you sure you want to clear shared preferences?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      TextButton(
                                        child: const Text("Clear"),
                                        onPressed: () async {
                                          await SharedPreferencesHelper
                                              .delete();
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ]))));
              }
              return const SizedBox.shrink();
            }),
      ),
    );
  }
}
              // return ListTile(
              //     title: Text("Clear Cache"),
              //     trailing: IconButton(
              //         icon: const Icon(Icons.delete),
              //         onPressed: () => showDialog(
              //             context: context,
              //             builder: (BuildContext context) => AlertDialog(
              //                   title: const Text("Clear Cache"),
              //                   content: const Text(
              //                       "Are you sure you want to clear cache?"),
              //                   actions: [
              //                     TextButton(
              //                       child: const Text("Cancel"),
              //                       onPressed: () =>
              //                           Navigator.of(context).pop(),
              //                     ),
              //                     TextButton(
              //                       child: const Text("Clear"),
              //                       onPressed: () =>
              //                           Navigator.of(context).pop(),
              //                     )
              //                   ],
              //                 ))));