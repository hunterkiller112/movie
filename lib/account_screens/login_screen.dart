import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import 'auth_provider.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (formKey.currentState?.validate() ?? false) {
      context.read<AuthProvider>().login(
        context: context,
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(19, 64, 19, 24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/movies_logo.png',
                    width: 121,
                    height: 118,
                  ),
                ),
                const SizedBox(height: 72),
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
                const SizedBox(height: 22),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      tooltip: hidePassword ? 'Show password' : 'Hide password',
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.yellow,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          ForgotPasswordScreen.routeName,
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    child: Text(isLoading ? 'Signing in...' : 'Login'),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Don’t have an account?'),
                    SizedBox(
                      height: 48,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.yellow,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RegisterScreen.routeName,
                          );
                        },
                        child: const Text(
                          'Create One',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
