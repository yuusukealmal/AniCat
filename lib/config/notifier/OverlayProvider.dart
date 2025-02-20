import 'package:flutter/material.dart';
import 'package:anicat/functions/Calc.dart';

class Overlayprovider extends ChangeNotifier {
  bool _isOverlayShow = false, _isVideoScreen = false;
  String? _title = "";
  double _progress = 0;
  int _downloaded = 0, _length = 0;
  OverlayEntry? _overlayEntry;
  void setIsVideoScreen(bool value) => _isVideoScreen = value;

  OverlayEntry _createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 50,
          left: 20,
          right: 20,
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
                  Text('Downloading $_title'),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Text('${convertMB(_downloaded)}/${convertMB(_length)}'),
                  const SizedBox(height: 8),
                  Text("${(_progress * 100).toStringAsFixed(2)}% Completed"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showOverlay(BuildContext context,
      {String? title, double? progress, int? downloaded, int? length}) {
    _title = title;
    _progress = progress ?? _progress;
    _downloaded = downloaded ?? _downloaded;
    _length = length ?? _length;
    if (!_isOverlayShow) {
      _isOverlayShow = true;
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void updateOverlay(BuildContext context,
      {double? progress, int? downloaded, int? length}) {
    _progress = progress ?? _progress;
    _downloaded = downloaded ?? _downloaded;
    _length = length ?? _length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      removeOverlay();
      if (!_isVideoScreen) {
        _overlayEntry = _createOverlayEntry(context);
        Overlay.of(context).insert(_overlayEntry!);
        _isOverlayShow = true;
      }
    });
  }

  void removeOverlay() {
    if (_isOverlayShow) {
      _isOverlayShow = false;
      _overlayEntry?.remove();
    }
  }
}
