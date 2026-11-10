import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuthException, User;
import 'package:flutter/material.dart';

import '../movie_catalog/movie_storage.dart';
import '../movie_catalog/movies_screen.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;

  Future<void> createAccount({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String phone,
    required int avatar,
  }) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      User user = await AuthService.createAccount(
        name: name,
        email: email,
        password: password,
      );
      await MovieStorage.saveProfile(user.uid, name, phone, avatar);
      if (!context.mounted) return;
      _show(context, 'Check your email to verify your account.');
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.routeName,
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      _show(context, error.message ?? 'Could not create your account.');
    } catch (_) {
      _show(
        context,
        'Could not save your profile. Check your email to sign in.',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      User user = await AuthService.login(email: email, password: password);
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        if (!context.mounted) return;
        _show(context, 'Verify your email before signing in.');
        return;
      }

      try {
        await MovieStorage.openUser(user.uid, user.displayName ?? email);
      } catch (_) {
        await AuthService.signOut();
        rethrow;
      }
      if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) {
        MovieStorage.userId = null;
        await AuthService.signOut();
        return;
      }
      Navigator.pushReplacementNamed(context, MoviesScreen.routeName);
    } on FirebaseAuthException catch (error) {
      _show(context, error.message ?? 'Could not sign in.');
    } catch (_) {
      _show(context, 'Could not open your profile.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required BuildContext context,
    required String email,
  }) async {
    if (isLoading) return;
    const String sentMessage = 'Check your email for a password reset link.';
    isLoading = true;
    notifyListeners();
    try {
      await AuthService.resetPassword(email: email);
      if (!context.mounted) return;
      _show(context, sentMessage);
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      _show(
        context,
        error.code == 'user-not-found'
            ? sentMessage
            : error.message ?? 'Could not send the password reset link.',
      );
    } catch (_) {
      _show(context, 'Could not send the password reset link.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _show(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
