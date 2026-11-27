import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/location_fields.dart';
import '../../providers/auth_providers.dart';

class UserRegisterScreen extends ConsumerStatefulWidget {
  const UserRegisterScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends ConsumerState<UserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).registerUser(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            latitude: double.tryParse(_latitudeController.text),
            longitude: double.tryParse(_longitudeController.text),
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.embedded)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Find and book grounds close to you.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else ...[
            Text(
              'Create your player account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Find and book grounds close to you.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
          ],
          AppSection(
            title: 'Account details',
            icon: Icons.person_outline,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Full name',
                prefixIcon: Icons.badge_outlined,
                validator: (value) => Validators.required(value, 'Name'),
              ),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: Validators.password,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSection(
            title: 'Your location',
            icon: Icons.location_on_outlined,
            subtitle: 'Used to show nearby grounds',
            children: [
              LocationFields(
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Create account',
            icon: Icons.check,
            loading: _loading,
            onPressed: _submit,
          ),
          if (!widget.embedded) ...[
            const SizedBox(height: 12),
            AppButton(
              label: 'Back to sign in',
              variant: AppButtonVariant.outlined,
              onPressed: () => context.go('/login'),
            ),
          ],
        ],
      ),
    );

    if (widget.embedded) return form;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: form,
        ),
      ),
    );
  }
}
