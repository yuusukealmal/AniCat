import 'package:flutter/material.dart';

Future<void> animeInvalidDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Material(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No Anime1 URL Found',
                ),
                const SizedBox(height: 8),
                const Text(
                  'No valid URL matches were found. Please try again with a different URL.',
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'OK',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
