import 'dart:math';

String convertMB(int length) {
  double mb = length / 1024 / 1024;
  double fix = double.parse(mb.toStringAsFixed(2));
  return '$fix MB';
}

String getFileSize(int length) {
  if (length <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(length) / log(1024)).floor();
  return "${(length / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}";
}
