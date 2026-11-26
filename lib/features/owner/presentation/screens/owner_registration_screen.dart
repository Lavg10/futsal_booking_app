import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/image_picker_field.dart';
import '../../../../shared/widgets/location_fields.dart';
import '../../data/owner_repository.dart';
import '../../providers/owner_providers.dart';

class OwnerRegistrationScreen extends ConsumerStatefulWidget {
  const OwnerRegistrationScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(title: const Text('Futsal owner registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Owner details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _ownerNameController,
                  label: 'Owner name',
                  validator: (value) => Validators.required(value, 'Owner name'),
                ),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                AppTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  keyboardType: TextInputType.phone,
                  validator: (value) => Validators.required(value, 'Phone number'),
                ),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: Validators.password,
                ),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm password',
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Business details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _businessNameController,
                  label: 'Business name',
                  validator: (value) => Validators.required(value, 'Business name'),
                ),
                AppTextField(
                  controller: _registrationNumberController,
                  label: 'Business registration number',
                  validator: (value) =>
                      Validators.required(value, 'Registration number'),
                ),
                AppTextField(
                  controller: _addressController,
                  label: 'Address',
                  maxLines: 2,
                  validator: (value) => Validators.required(value, 'Address'),
                ),
                LocationFields(
                  latitudeController: _latitudeController,
                  longitudeController: _longitudeController,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Documents (images)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ImagePickerField(
                  label: 'Identity proof',
                  maxImages: 1,
                  onChanged: (files) => _idProof = files.isEmpty ? null : files.first,
                ),
                ImagePickerField(
                  label: 'Business registration document',
                  maxImages: 1,
                  onChanged: (files) => _businessRegistration =
                      files.isEmpty ? null : files.first,
                ),
                ImagePickerField(
                  label: 'Venue ownership / rental proof',
                  maxImages: 1,
                  onChanged: (files) =>
                      _venueProof = files.isEmpty ? null : files.first,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit for approval'),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
