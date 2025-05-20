import 'package:flutter/material.dart';
import 'package:anicat/functions/utils.dart';

class OverlayProvider extends ChangeNotifier {
  bool _isOverlayShow = false, _isVideoScreen = false, _isDownloading = false;
  String? _title;
  double _progress = 0;
  int _downloaded = 0, _length = 0;
  OverlayEntry? _overlayEntry;
  void setIsVideoScreen(bool value) => _isVideoScreen = value;

  bool get isDownloading => _isDownloading;
  void setIsDownloading(bool value) => _isDownloading = value;

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

  void showOverlay(BuildContext context, {String? title, int? length}) {
    _title = title ?? _title;
    _length = length ?? _length;
    removeOverlay();
    if (!_isVideoScreen && _isDownloading) {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
      _isOverlayShow = true;
    }
  }

  void removeOverlay() {
    if (_isOverlayShow) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayShow = false;
    }
  }

  void updateOverlayIfNeeded({double? progress, int? downloaded}) {
    _progress = progress ?? _progress;
    _downloaded = downloaded ?? _downloaded;
    _overlayEntry?.markNeedsBuild();
  }
}
