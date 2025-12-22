import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'pdf_export_web.dart' if (kIsWeb) 'pdf_export_io.dart' as export_impl;

Future<void> savePdf({
  required String fileName,
  required Uint8List bytes,
  BuildContext? context,   // ← نفس التوقيع للملفين
}) =>
    export_impl.savePdf(
      fileName: fileName,
      bytes: bytes,
      context: context,     // الآن متاح للإثنين
    );