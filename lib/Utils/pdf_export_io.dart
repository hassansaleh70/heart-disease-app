import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:open_file/open_file.dart';

class PdfExportIO {
  static Future<void> savePdf({
    required BuildContext context,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('PDF saved: ${file.path}')),
      );
      //await OpenFile.open(file.path);
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }
}