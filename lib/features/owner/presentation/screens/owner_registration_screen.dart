import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/image_picker_field.dart';
import '../../../../shared/widgets/location_fields.dart';
import '../../data/owner_repository.dart';
import '../../providers/owner_providers.dart';

class OwnerRegistrationScreen extends ConsumerStatefulWidget {
  const OwnerRegistrationScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  ConsumerState<OwnerRegistrationScreen> createState() =>
      _OwnerRegistrationScreenState();
}

class _OwnerRegistrationScreenState extends ConsumerState<OwnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  XFile? _idProof;
  XFile? _businessRegistration;
  XFile? _venueProof;

  @override
  void dispose() {
    for (final controller in [
      _ownerNameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
      _phoneController,
      _businessNameController,
      _registrationNumberController,
      _addressController,
      _latitudeController,
      _longitudeController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idProof == null || _businessRegistration == null || _venueProof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload ID, business registration and venue proof')),
      );
      return;
    }

    await ref.read(ownerRegistrationControllerProvider.notifier).submit(
          OwnerRegistrationData(
            ownerName: _ownerNameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            phoneNumber: _phoneController.text,
            businessName: _businessNameController.text,
            registrationNumber: _registrationNumberController.text,
            address: _addressController.text,
            latitude: double.parse(_latitudeController.text),
            longitude: double.parse(_longitudeController.text),
            idProof: _idProof!,
            businessRegistration: _businessRegistration!,
            venueProof: _venueProof!,
          ),
        );

    if (!mounted) return;
    final result = ref.read(ownerRegistrationControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${result.error}')),
      );
      return;
    }
    context.go('/pending');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(ownerRegistrationControllerProvider).isLoading;

    final form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.embedded)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Add your details and documents for admin review.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else ...[
            Text(
              'List your futsal ground',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              'Add your details and documents for admin review.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
          ],
          AppSection(
            title: 'Owner details',
            icon: Icons.person_outline,
            children: [
              AppTextField(
                controller: _ownerNameController,
                label: 'Owner name',
                prefixIcon: Icons.badge_outlined,
                validator: (value) => Validators.required(value, 'Owner name'),
              ),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              AppTextField(
                controller: _phoneController,
                label: 'Phone number',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) => Validators.required(value, 'Phone number'),
              ),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: Validators.password,
              ),
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSection(
            title: 'Business details',
            icon: Icons.storefront_outlined,
            children: [
              AppTextField(
                controller: _businessNameController,
                label: 'Business name',
                prefixIcon: Icons.sports_soccer,
                validator: (value) => Validators.required(value, 'Business name'),
              ),
              AppTextField(
                controller: _registrationNumberController,
                label: 'Business registration number',
                prefixIcon: Icons.confirmation_number_outlined,
                validator: (value) =>
                    Validators.required(value, 'Registration number'),
              ),
              AppTextField(
                controller: _addressController,
                label: 'Address',
                prefixIcon: Icons.home_outlined,
                maxLines: 2,
                validator: (value) => Validators.required(value, 'Address'),
              ),
              const SizedBox(height: 4),
              LocationFields(
                latitudeController: _latitudeController,
                longitudeController: _longitudeController,
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSection(
            title: 'Documents',
            icon: Icons.description_outlined,
            subtitle: 'Upload a clear image of each document',
            children: [
              ImagePickerField(
                label: 'Identity proof',
                maxImages: 1,
                onChanged: (files) => _idProof = files.isEmpty ? null : files.first,
              ),
              const SizedBox(height: 12),
              ImagePickerField(
                label: 'Business registration document',
                maxImages: 1,
                onChanged: (files) => _businessRegistration =
                    files.isEmpty ? null : files.first,
              ),
              const SizedBox(height: 12),
              ImagePickerField(
                label: 'Venue ownership / rental proof',
                maxImages: 1,
                onChanged: (files) =>
                    _venueProof = files.isEmpty ? null : files.first,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Submit for approval',
            icon: Icons.send_outlined,
            loading: isLoading,
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
      appBar: AppBar(title: const Text('Owner registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: form,
        ),
      ),
    );
  }
}
