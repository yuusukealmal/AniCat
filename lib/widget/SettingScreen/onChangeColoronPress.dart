import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:anicat/config/notifier/HomeColorProvider.dart';

Future<dynamic> onChangeColoronPress(BuildContext context, int? selectedColor) {
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
                Text(
                  "Change Theme Color",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: Color(
                      selectedColor ??
                          Theme.of(context).colorScheme.primary.value,
                    ),
                    onColorChanged: (Color color) {
                      selectedColor = color.value;
                    },
                  ),
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
                        final colorProvider =
                            Provider.of<ColorProvider>(context, listen: false);
                        colorProvider.setColor(Color(selectedColor!));
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "OK",
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
