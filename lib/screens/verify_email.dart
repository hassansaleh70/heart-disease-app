import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    // خد الـ Navigator قبل أى await
    final navigator = Navigator.of(context);

    try {
      await context
          .read<AuthService>()
          .registerWithEmail(_email.text.trim(), _pass.text.trim());

      if (!mounted) return;

      // SAVE EMAIL ONLY (NO FAKE OTP)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _email.text.trim());

      // GO TO LOGIN AFTER SUCCESS
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(msg: e.toString());
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              InputField(
                  label: "Email",
                  controller: _email,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              InputField(
                  label: "Password (6+ chars)",
                  controller: _pass,
                  obscureText: true),
              const SizedBox(height: 12),
              const Text(
                'Check your email (including Spam) and click the verification link, then return to the app.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                  text: "Register & Send Verification",
                  onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}