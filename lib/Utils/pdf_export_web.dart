import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Future<void> savePdf({
  required String fileName,
  required Uint8List bytes,
  BuildContext? context,   // ← متاح ولا يُستخدم
}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'application/pdf'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..click();
  web.URL.revokeObjectURL(url);
}