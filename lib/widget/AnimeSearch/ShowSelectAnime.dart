import 'package:flutter/material.dart';

import 'package:anicat/api/AnimeList.dart';

Future<void> showSelected(
    BuildContext context, List<AnimeValue> selectedAnimes) {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "已選擇清單",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: selectedAnimes.length,
                itemBuilder: (context, index) {
                  AnimeValue select = selectedAnimes[index];
                  return ListTile(
                    title: Text(
                      select.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      "${select.year} ${select.season} ${select.status}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text("關閉"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
