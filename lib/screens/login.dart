import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../screens/home.dart';
import '../services/auth.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      await context.read<AuthService>().loginWithEmail(_email.text.trim(), _pass.text.trim());
      messenger.showSnackBar(SnackBar(content: Text('✅ Login success')));

      // ← الانتقال للـ HomeScreen بعد النجاح
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('❌ Error: $e')));
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _form,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              Text("Heart Predictor",
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 40),
              InputField(
                  label: "Email",
                  controller: _email,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              InputField(
                  label: "Password", controller: _pass, obscureText: true),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RegisterScreen())),
                child: const Text("Create Account"),
              ),
              const SizedBox(height: 12),
              const Text(
                "After registration, check your email (including Spam) for verification.",
                style: TextStyle(fontSize: 10, color: Colors.grey),
                textAlign: TextAlign.center,
              ),


              const SizedBox(height: 12),
              _loading
                  ? const CircularProgressIndicator()
                  : DefaultTextStyle(
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05, // حجم خط نسبي للشاشة
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // تأكد من وضوح النص داخل الزر
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8, // 80% من عرض الشاشة
                  height: MediaQuery.of(context).size.height * 0.07, // 7% من ارتفاع الشاشة
                  child: PrimaryButton(
                    text: "Login",
                    onPressed: _submit,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}