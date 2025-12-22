import 'package:flutter/material.dart';
import '../Utils/pdf_generator.dart';
import '../models/case.dart';
import '../utils/constants.dart';

class CaseDetailScreen extends StatelessWidget {
  final HeartCase heartCase;
  const CaseDetailScreen({required this.heartCase, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(heartCase.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                heartCase.prediction == 0
                    ? Icons.check_circle
                    : Icons.warning,
                size: 100,
                color:
                heartCase.prediction == 0 ? kSafeGreen : kPrimaryRed,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                heartCase.prediction == 0
                    ? "No Disease"
                    : "Disease Detected",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: heartCase.prediction == 0
                      ? kSafeGreen
                      : kPrimaryRed,
                ),
              ),
            ),
            Center(
              child: Text(
                "Probability ${heartCase.probability.toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Features",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            // Generate feature rows
            ...heartCase.features.entries.map(
                  (e) => ListTile(
                dense: true,
                title: Text(e.key.toUpperCase()),
                trailing: Text(e.value.toString()),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Created: ${heartCase.timestamp}",
              style: const TextStyle(color: Colors.grey),

            ),
            ElevatedButton.icon(
              onPressed: () => generateCaseReportPDF(context, heartCase),
              icon: const Icon(Icons.download),
              label: const Text('Download Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
