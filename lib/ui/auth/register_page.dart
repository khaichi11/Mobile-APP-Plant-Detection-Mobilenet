import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/account_repository.dart';
import '../../state/app_state.dart';

/// Creates an account, or a guest profile when [asGuest] is true.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.asGuest = false});

  final bool asGuest;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  int _grade = 4;
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    try {
      if (widget.asGuest) {
        await state.continueAsGuest(name: _name.text, grade: _grade);
      } else {
        await state.register(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          grade: _grade,
        );
      }
      navigator.popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guest = widget.asGuest;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  guest ? 'Explore as a guest' : 'Create your account',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: Gap.sm),
                Text(
                  guest
                      ? 'Start right away. Guest progress is deleted when you '
                          'sign out.'
                      : 'Your progress is saved on this device.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: Gap.xxl),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator:
                      (value) => AccountRepository.validateName(value ?? ''),
                ),
                const SizedBox(height: Gap.lg),
                DropdownButtonFormField<int>(
                  initialValue: _grade,
                  decoration: const InputDecoration(
                    labelText: 'Grade',
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: [
                    for (var grade = 1; grade <= 6; grade++)
                      DropdownMenuItem(
                        value: grade,
                        child: Text('Grade $grade'),
                      ),
                  ],
                  onChanged: (value) => setState(() => _grade = value ?? 4),
                ),
                if (!guest) ...[
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                    validator:
                        (value) => AccountRepository.validateEmail(value ?? ''),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      helperText:
                          'At least ${AccountRepository.minPasswordLength} '
                          'characters',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip:
                            _hidePassword ? 'Show password' : 'Hide password',
                        onPressed:
                            () =>
                                setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator:
                        (value) =>
                            AccountRepository.validatePassword(value ?? ''),
                  ),
                ],
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
                  onPressed: _busy ? null : _submit,
                  child: Text(guest ? 'Start exploring' : 'Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
