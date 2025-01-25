import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:anicat/functions/behavior/PathLoad.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/config/notifier/HomeColorNotifier.dart';

Future<dynamic> onChangeColoronPress(BuildContext context, int? selectedColor) {
  return showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text("Change Theme Color"),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: Color(
              selectedColor ?? Theme.of(context).colorScheme.primary.value),
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
            final colorNotifier =
                Provider.of<ColorNotifier>(context, listen: false);
            colorNotifier.setColor(Color(selectedColor!));
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

Future<dynamic> onResetSharedPreferences(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: const Text("Reset Shared Preferences"),
              content: const Text(
                  "Are you sure you want to Reset shared preferences?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("Reset"),
                  onPressed: () async {
                    await SharedPreferencesHelper.reset();
                    final colorNotifier =
                        Provider.of<ColorNotifier>(context, listen: false);
                    colorNotifier.setColor(
                        Color(SharedPreferencesHelper.getInt("Home.Color")!));
                    Navigator.of(context).pop();
                  },
                )
              ]));
}

Future<dynamic> onClearCache(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: const Text("Clear Cache"),
              content: const Text("Are you sure you want to clear cache?"),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text("Clear"),
                  onPressed: () async {
                    final cache = await Load.getCacheImgFolder();
                    await for (var entity in cache.list()) {
                      await entity.delete(recursive: true);
                    }
                    Navigator.of(context).pop();
                  },
                )
              ]));
}
