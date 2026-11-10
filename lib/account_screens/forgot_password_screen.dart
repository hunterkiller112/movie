import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void resetPassword() {
    if (formKey.currentState?.validate() ?? false) {
      context.read<AuthProvider>().resetPassword(
        context: context,
        email: emailController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/reset_password.png', height: 420),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  String address = value?.trim() ?? '';
                  if (address.isEmpty) {
                    return 'Enter your email';
                  }
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                      .hasMatch(address)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : resetPassword,
                  child: Text(isLoading ? 'Sending...' : 'Reset Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
