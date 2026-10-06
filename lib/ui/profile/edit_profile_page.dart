import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../services/account_repository.dart';
import '../../state/app_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late int _grade;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _grade = user?.grade ?? 4;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final navigator = Navigator.of(context);
    try {
      await context.read<AppState>().updateProfile(
        name: _name.text,
        grade: _grade,
      );
      navigator.pop();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Gap.lg),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Your name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => AccountRepository.validateName(value ?? ''),
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
                  DropdownMenuItem(value: grade, child: Text('Grade $grade')),
              ],
              onChanged: (value) => setState(() => _grade = value ?? _grade),
            ),
            const SizedBox(height: Gap.xl),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
