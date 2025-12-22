import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  FirestoreService(this.uid);

  Future<List<HeartCase>> getCases() async {
    if (uid.isEmpty) return [];
    final snap = await _db.collection('users').doc(uid).collection('cases').get();
    return snap.docs.map((d) => HeartCase.fromFirestore(d.id, d.data())).toList();
  }

  Future<void> saveCase(HeartCase heartCase) async {
    if (uid.isEmpty) throw Exception('User not logged in');
    await _db.collection('users').doc(uid).collection('cases').doc(heartCase.id).set(heartCase.toMap());
  }

  Future<void> deleteCase(String caseId) async {
    if (uid.isEmpty) throw Exception('User not logged in');
    await _db.collection('users').doc(uid).collection('cases').doc(caseId).delete();
  }
}