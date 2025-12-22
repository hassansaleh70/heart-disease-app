import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../models/case.dart';
import '../services/auth.dart';
import '../services/firestore.dart';
import '../widgets/risk_card.dart';
import 'case_detail.dart';
import 'case_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirestoreService _db =
  FirestoreService(FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cases"),
        actions: [
          IconButton(
              onPressed: () =>
                  context.read<AuthService>()
                      .logout()
                      .then((_) => Fluttertoast.showToast(msg: "Signed out")),
              icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CaseFormScreen())),
        tooltip: "New Case",
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_db.uid)
            .collection('cases')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text(snap.error.toString()));
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          final list = docs
              .map((d) => HeartCase.fromFirestore(d.id, d.data()))
              .toList();
          final total = list.length;
          final diseaseCount = list
              .where((c) => c.prediction == 1)
              .length;
          final avgProb = total == 0
              ? 0.0
              : list.map((c) => c.probability).reduce((a, b) => a + b) / total;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                        child: RiskCard(
                            title: "Total",
                            value: "$total",
                            color: Colors.blue)),
                    Expanded(
                        child: RiskCard(
                            title: "Disease",
                            value: "$diseaseCount",
                            color: Colors.red)),
                    Expanded(
                        child: RiskCard(
                            title: "Avg Prob",
                            value: "${avgProb.toStringAsFixed(1)}%",
                            color: Colors.orange)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final c = list[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          c.prediction == 0 ? Icons.check_circle : Icons.warning,
                          color: c.prediction == 0 ? Colors.green : Colors.red,
                        ),
                        title: Text(c.name),
                        subtitle: Text(
                          "${c.prediction == 0 ? 'No Disease' : 'Disease Detected'}  •  "
                              "${c.probability.toStringAsFixed(1)}%",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${c.timestamp.day}/${c.timestamp.month}/${c.timestamp.year}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_db.uid)
                                    .collection('cases')
                                    .doc(c.id)
                                    .delete();

                                Fluttertoast.showToast(msg: "Case deleted");
                              },
                            ),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaseDetailScreen(heartCase: c),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}