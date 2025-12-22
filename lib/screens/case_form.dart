import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/case.dart';
import '../services/api.dart';
import '../services/firestore.dart';
import '../widgets/primary_button.dart';
import '../widgets/input_field.dart';


class CaseFormScreen extends StatefulWidget {
  const CaseFormScreen({super.key});

  @override
  State<CaseFormScreen> createState() => _CaseFormScreenState();
}

class _CaseFormScreenState extends State<CaseFormScreen> {
  final _form = GlobalKey<FormState>();

  // حقول رقمية (يدخلها المستخدم)
  final ageCtrl     = TextEditingController();
  final trestbpsCtrl= TextEditingController();
  final cholCtrl    = TextEditingController();
  final thalachCtrl = TextEditingController();
  final oldpeakCtrl = TextEditingController();
  final caCtrl      = TextEditingController();

  // حقول اختيارات (dropdown)
  int sex     = 1;
  int cp      = 0;
  int fbs     = 0;
  int restecg = 0;
  int exang   = 0;
  int slope   = 0;
  int thal    = 1;

  bool _loading = false;

  @override
  void dispose() {
    ageCtrl.dispose();
    trestbpsCtrl.dispose();
    cholCtrl.dispose();
    thalachCtrl.dispose();
    oldpeakCtrl.dispose();
    caCtrl.dispose();
    super.dispose();
  }

  // قوائم dropdown
  List<DropdownMenuItem<int>> sexItems() => const [
    DropdownMenuItem(value: 0, child: Text('0- Female')),
    DropdownMenuItem(value: 1, child: Text('1- Male'))
  ];
  List<DropdownMenuItem<int>> cpItems() => const [
    DropdownMenuItem(value: 0, child: Text('0- Typical Angina')),
    DropdownMenuItem(value: 1, child: Text('1- Atypical Angina')),
    DropdownMenuItem(value: 2, child: Text('2- Non-anginal Pain')),
    DropdownMenuItem(value: 3, child: Text('3- Asymptomatic'))
  ];
  List<DropdownMenuItem<int>> fbsItems() => const [
    DropdownMenuItem(value: 0, child: Text('0- False')),
    DropdownMenuItem(value: 1, child: Text('1- True'))
  ];
  List<DropdownMenuItem<int>> restecgItems() => const [
    DropdownMenuItem(value: 0, child: Text('0- Normal')),
    DropdownMenuItem(value: 1, child: Text('1- ST-T Abnormality')),
    DropdownMenuItem(value: 2, child: Text('2- LV Hypertrophy'))
  ];
  List<DropdownMenuItem<int>> exangItems() => const [
    DropdownMenuItem(value: 0, child: Text('0- No')),
    DropdownMenuItem(value: 1, child: Text('1- Yes'))
  ];
  List<DropdownMenuItem<int>> slopeItems() => const [
    DropdownMenuItem(value: 0, child: Text('0- Upsloping')),
    DropdownMenuItem(value: 1, child: Text('1- Flat')),
    DropdownMenuItem(value: 2, child: Text('2- Downsloping'))
  ];
  List<DropdownMenuItem<int>> thalItems() => const [
    DropdownMenuItem(value: 1, child: Text('1- Normal')),
    DropdownMenuItem(value: 2, child: Text('2- Fixed Defect')),
    DropdownMenuItem(value: 3, child: Text('3- Reversible Defect'))
  ];

  Future _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // قراءة الأرقام
      final map = <String, dynamic>{
        'age': double.parse(ageCtrl.text),
        'sex': sex,
        'cp': cp,
        'trestbps': double.parse(trestbpsCtrl.text),
        'chol': double.parse(cholCtrl.text),
        'fbs': fbs,
        'restecg': restecg,
        'thalach': double.parse(thalachCtrl.text),
        'exang': exang,
        'oldpeak': double.parse(oldpeakCtrl.text),
        'slope': slope,
        'ca': double.parse(caCtrl.text),
        'thal': thal,
      };

      final resp = await ApiService.predict(map);  // ← امسح 'features'
      final pred = resp['prediction'] as int;
      final prob = (resp['probability'] as num).toDouble();
      final displayedProb = prob;   // لأن Flask أرسلها مضروبة ×100
      //final correctedProb = prob > 100 ? prob / 100 : prob;

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final countSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cases')
          .count()
          .get();
      final caseName = "Case ${(countSnap.count ?? 0) + 1}";

      final newCase = HeartCase(
        id: "case_${Random().nextInt(900000)}",
        name: caseName,
        features: map,
        prediction: pred,
        probability: displayedProb,
        timestamp: DateTime.now(),
      );
      await FirestoreService(uid).saveCase(newCase);
      if (mounted) {
        Fluttertoast.showToast(msg: "Saved");
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Case")),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // حقول رقمية
            // داخل build(...) بدل الأسطر القديمة
            InputField(
              label: 'Age',
              controller: ageCtrl,
              keyboard: TextInputType.number,
              hint: 'Enter age (e.g., 63)',                       // ← الـ hint
            ),
            InputField(
              label: 'Resting Blood Pressure (mmHg)',
              controller: trestbpsCtrl,
              keyboard: TextInputType.number,
              hint: 'e.g., 145 mmHg',                              // ← الـ hint
            ),
            InputField(
              label: 'Cholesterol (mg/dl)',
              controller: cholCtrl,
              keyboard: TextInputType.number,
              hint: 'e.g., 233 mg/dl',                             // ← الـ hint
            ),
            InputField(
              label: 'Max Heart Rate (bpm)',
              controller: thalachCtrl,
              keyboard: TextInputType.number,
              hint: 'e.g., 150 bpm',                               // ← الـ hint
            ),
            InputField(
              label: 'ST Depression (mm)',
              controller: oldpeakCtrl,
              keyboard: TextInputType.number,
              hint: 'e.g., 2.3',                                   // ← الـ hint
            ),
            InputField(
              label: 'Major Vessels (0-3)',
              controller: caCtrl,
              keyboard: TextInputType.number,
              hint: '0,1,2,3',                                     // ← الـ hint
            ),

            const SizedBox(height: 16),

            // حقول اختيارات
            dropdown('Sex', sex, sexItems(), (v) => setState(() => sex = v!)),
            dropdown('Chest Pain Type', cp, cpItems(), (v) => setState(() => cp = v!)),
            dropdown('Fasting Blood Sugar > 120', fbs, fbsItems(), (v) => setState(() => fbs = v!)),
            dropdown('Resting ECG', restecg, restecgItems(), (v) => setState(() => restecg = v!)),
            dropdown('Exercise Induced Angina', exang, exangItems(), (v) => setState(() => exang = v!)),
            dropdown('Slope of Peak ST', slope, slopeItems(), (v) => setState(() => slope = v!)),
            dropdown('Thalassemia', thal, thalItems(), (v) => setState(() => thal = v!)),

            const SizedBox(height: 24),

            _loading
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(text: "Save & Predict", onPressed: _save),
          ],
        ),
      ),
    );
  }

  Widget dropdown(String label, int val, List<DropdownMenuItem<int>> items, void Function(int?) onCh) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<int>(
        value: val,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items,
        onChanged: onCh,
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }
}