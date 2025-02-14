import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:anicat/config/SharedPreferences.dart';
import 'package:anicat/config/notifier/HomeColorProvider.dart';

Future<dynamic> onResetSharedPreferences(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reset Shared Preferences",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Are you sure you want to Reset shared preferences?",
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "Cancel",
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        await SharedPreferencesHelper.reset();
                        final colorNotifier =
                            Provider.of<ColorNotifier>(context, listen: false);
                        colorNotifier.setColor(Color(
                            SharedPreferencesHelper.getInt("Home.Color")!));
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
