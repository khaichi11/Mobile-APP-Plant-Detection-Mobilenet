import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/account_repository.dart';
import '../../state/app_state.dart';
import '../art/logo.dart';
import 'register_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<AppState>().signIn(
        email: _email.text,
        password: _password.text,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.forest,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.forest, AppColors.brandDeep],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Gap.xl,
                        Gap.xxl,
                        Gap.xl,
                        Gap.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const PandaiLogo(size: 52),
                          ),
                          const SizedBox(height: Gap.xl),
                          Text(
                            'WELCOME BACK!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: Gap.xs),
                          Text(
                            'We\'re so happy to see you again!',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(
                          Gap.xl,
                          Gap.xxl,
                          Gap.xl,
                          Gap.xl,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _email,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                    ),
                                  ),
                                  validator:
                                      (value) =>
                                          AccountRepository.validateEmail(
                                            value ?? '',
                                          ),
                                ),
                                const SizedBox(height: Gap.lg),
                                TextFormField(
                                  controller: _password,
                                  obscureText: _hidePassword,
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _signIn(),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip:
                                          _hidePassword
                                              ? 'Show password'
                                              : 'Hide password',
                                      onPressed:
                                          () => setState(
                                            () =>
                                                _hidePassword = !_hidePassword,
                                          ),
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                                  validator:
                                      (value) =>
                                          (value ?? '').isEmpty
                                              ? 'Please enter your password.'
                                              : null,
                                ),
                                if (_error != null) ...[
                                  const SizedBox(height: Gap.md),
                                  Text(
                                    _error!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.berry,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: Gap.xl),
                                FilledButton(
                                  onPressed: _busy ? null : _signIn,
                                  child:
                                      _busy
                                          ? const SizedBox.square(
                                            dimension: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Text('Sign In'),
                                ),
                                const SizedBox(height: Gap.md),
                                OutlinedButton(
                                  onPressed:
                                      _busy
                                          ? null
                                          : () => Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder:
                                                  (_) => const RegisterPage(),
                                            ),
                                          ),
                                  child: const Text('Create an account'),
                                ),
                                TextButton(
                                  onPressed:
                                      _busy
                                          ? null
                                          : () => Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder:
                                                  (_) => const RegisterPage(
                                                    asGuest: true,
                                                  ),
                                            ),
                                          ),
                                  child: const Text('Explore as a guest'),
                                ),
                                const Spacer(),
                                Text(
                                  'Your account and progress are stored only '
                                  'on this device.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
