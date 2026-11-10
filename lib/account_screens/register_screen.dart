import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import 'auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  bool hideConfirmation = true;
  int selectedAvatar = 8;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void createAccount() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthProvider>().createAccount(
      context: context,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      phone: phoneController.text.trim(),
      avatar: selectedAvatar,
    );
  }

  Widget avatarChoice(int avatar) {
    bool selected = avatar == selectedAvatar;

    return Expanded(
      flex: selected ? 4 : 3,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedAvatar = avatar;
          });
        },
        child: Image.asset(
          'assets/images/avatar_$avatar.png',
          height: selected ? 160 : 94,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [avatarChoice(1), avatarChoice(8), avatarChoice(2)],
              ),
              const SizedBox(height: 8),
              const Text('Avatar', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
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
              TextFormField(
                controller: passwordController,
                obscureText: hidePassword,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password';
                  }
                  if (value.length < 6) {
                    return 'Use at least 6 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                obscureText: hideConfirmation,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hideConfirmation
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hideConfirmation = !hideConfirmation;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : createAccount,
                  child: Text(
                    isLoading ? 'Creating account...' : 'Create Account',
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.yellow,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
