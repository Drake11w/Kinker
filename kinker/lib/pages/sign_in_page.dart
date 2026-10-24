import 'package:flutter/material.dart';

import '../common_widgets/platform_alert_dialog.dart';
import '../services/auth.dart';
import '../services/services.dart';

enum FormType { login, register }

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  FormType _formType = FormType.login;
  bool _submitting = false;

  bool get _isLogin => _formType == FormType.login;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static String? validateEmail(String? input) {
    final value = input?.trim() ?? '';
    if (value.isEmpty) return 'Please type an email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'That doesn\'t look like an email address';
    }
    return null;
  }

  static String? validatePassword(String? input) {
    if ((input ?? '').length < 6) {
      return 'Passwords need at least 6 characters';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Services.of(context).auth;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    setState(() => _submitting = true);
    String? error;
    try {
      if (_isLogin) {
        await auth.signInWithEmailAndPassword(email, password);
      } else {
        await auth.createUserWithEmailAndPassword(email, password);
      }
    } on AuthException catch (e) {
      error = e.message;
    }
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error != null) {
      await _showMessage(_isLogin ? 'Login error' : 'Sign-up error', error);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (validateEmail(email) != null) {
      await _showMessage(
          'Reset password', 'Enter your email above, then tap "Forgot password?" again.');
      return;
    }
    try {
      await Services.of(context).auth.sendPasswordResetEmail(email);
      if (mounted) {
        await _showMessage('Reset password', 'Check $email for a reset link.');
      }
    } on AuthException catch (e) {
      if (mounted) await _showMessage('Reset password', e.message);
    }
  }

  Future<void> _showMessage(String title, String message) {
    return PlatformAlertDialog(
      title: title,
      content: message,
      confirmText: 'Okay',
    ).show(context);
  }

  void _toggleFormType() {
    _formKey.currentState!.reset();
    setState(() {
      _formType = _isLogin ? FormType.register : FormType.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = Services.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.favorite, size: 64, color: theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(
                      'Kinker',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (services.isDemo) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Demo mode: accounts and data live only on this device.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 32),
                    TextFormField(
                      key: const Key('email'),
                      controller: _emailController,
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('password'),
                      controller: _passwordController,
                      validator: validatePassword,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const Key('submit'),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isLogin ? 'Sign in' : 'Create an account'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _submitting ? null : _toggleFormType,
                      child: Text(_isLogin
                          ? 'Create an account'
                          : 'Have an account? Sign in'),
                    ),
                    if (_isLogin && !services.isDemo)
                      TextButton(
                        onPressed: _submitting ? null : _resetPassword,
                        child: const Text('Forgot password?'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
