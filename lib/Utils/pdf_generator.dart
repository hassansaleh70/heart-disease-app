import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html; // للـ Web فقط
import '../models/case.dart';

// ترجمات الأسماء
const _sexMap = {0: 'Female', 1: 'Male'};
const _cpMap = {
  0: 'Typical Angina',
  1: 'Atypical Angina',
  2: 'Non-anginal Pain',
  3: 'Asymptomatic'
};
const _fbsMap = {0: 'False', 1: 'True'};
const _restecgMap = {0: 'Normal', 1: 'ST-T Abnormality', 2: 'LV Hypertrophy'};
const _exangMap = {0: 'No', 1: 'Yes'};
const _slopeMap = {0: 'Upsloping', 1: 'Flat', 2: 'Downsloping'};
const _thalMap = {1: 'Normal', 2: 'Fixed Defect', 3: 'Reversible Defect' // 0 غير موجود
};

Future<void> generateCaseReportPDF(
    BuildContext context, HeartCase heartCase) async {
  final pdf = pw.Document();

  // دالة ترجمة اسم الحقل
  String _featureName(String key) {
    switch (key) {
      case 'age': return 'Age';
      case 'sex': return 'Sex';
      case 'cp': return 'Chest Pain Type';
      case 'trestbps': return 'Resting Blood Pressure';
      case 'chol': return 'Cholesterol';
      case 'fbs': return 'Fasting Blood Sugar';
      case 'restecg': return 'Resting ECG';
      case 'thalach': return 'Max Heart Rate';
      case 'exang': return 'Exercise Induced Angina';
      case 'oldpeak': return 'ST Depression';
      case 'slope': return 'Slope of Peak ST';
      case 'thal': return 'Thalassemia';
      default: return key.toUpperCase();
    }
  }

  // دالة ترجمة القيمة
  String _featureValue(String key, dynamic val) {
    switch (key) {
      case 'sex': return _sexMap[val] ?? val.toString();
      case 'cp': return _cpMap[val] ?? val.toString();
      case 'fbs': return _fbsMap[val] ?? val.toString();
      case 'restecg': return _restecgMap[val] ?? val.toString();
      case 'exang': return _exangMap[val] ?? val.toString();
      case 'slope': return _slopeMap[val] ?? val.toString();
      case 'thal': return _thalMap[val] ?? val.toString();
      default: return val.toString(); // الأرقام كما هي
    }
  }

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // عنوان
            pw.Center(
              child: pw.Text(
                "Heart Disease Report",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // بيانات أساسية
            pw.Text("Name: ${heartCase.name}", style: const pw.TextStyle(fontSize: 18)),
            pw.Text(
              "Prediction: ${heartCase.prediction == 0 ? "No Disease" : "Disease Detected"}",
              style: pw.TextStyle(
                fontSize: 18,
                color: heartCase.prediction == 0 ? PdfColors.green : PdfColors.red,
              ),
            ),
            pw.Text(
              "Probability: ${heartCase.probability.toStringAsFixed(1)}%",
              style: const pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 20),

            // جدول الحقول
            pw.Text("Clinical Features:", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            // جدول منسق
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text("Feature", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text("Value", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                // البيانات
                ...heartCase.features.entries.map(
                      (e) => pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(_featureName(e.key))),
                      pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(_featureValue(e.key, e.value))),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),
            pw.Text("Created: ${heartCase.timestamp}", style: const pw.TextStyle(color: PdfColors.grey)),
          ],
        );
      },
    ),
  );

  // حفظ + فتح
  try {
    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "${heartCase.name}_report.pdf")
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF downloaded in browser")),
      );
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/${heartCase.name}_report.pdf");
      await file.writeAsBytes(pdfBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF Saved: ${file.path}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}