import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/async_state_view.dart';
import '../../../../shared/widgets/image_picker_field.dart';
import '../../../../shared/widgets/location_fields.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../data/owner_repository.dart';
import '../../domain/owner_application.dart';
import '../../providers/owner_providers.dart';

class OwnerPendingScreen extends ConsumerStatefulWidget {
  const OwnerPendingScreen({super.key});

  @override
  ConsumerState<OwnerPendingScreen> createState() => _OwnerPendingScreenState();
}

class _OwnerPendingScreenState extends ConsumerState<OwnerPendingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  XFile? _idProof;
  XFile? _businessRegistration;
  XFile? _venueProof;
  bool _showResubmitForm = false;
  bool _prefilled = false;

  @override
  void dispose() {
    for (final controller in [
      _ownerNameController,
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

  void _prefill(OwnerApplication application) {
    if (_prefilled) return;
    _prefilled = true;
    _ownerNameController.text = application.ownerName;
    _phoneController.text = application.phoneNumber;
    _businessNameController.text = application.businessName;
    _registrationNumberController.text = application.registrationNumber;
    _addressController.text = application.address;
    _latitudeController.text = application.latitude.toString();
    _longitudeController.text = application.longitude.toString();
  }

  Future<void> _resubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idProof == null || _businessRegistration == null || _venueProof == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Re-upload all three documents')),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(ownerResubmitControllerProvider.notifier).submit(
          OwnerRegistrationData(
            ownerName: _ownerNameController.text,
            email: user.email,
            password: '',
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
    final result = ref.read(ownerResubmitControllerProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resubmission failed: ${result.error}')),
      );
      return;
    }
    setState(() => _showResubmitForm = false);
  }

  @override
  Widget build(BuildContext context) {
    final applicationAsync = ref.watch(myOwnerApplicationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval status'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: AsyncStateView<OwnerApplication?>(
        value: applicationAsync,
        builder: (application) {
          if (application == null) {
            return const Center(
              child: Text('No application found. Please register again.'),
            );
          }
          _prefill(application);
          final needsDocuments = !application.isApproved &&
              (application.documents.idProofUrl.isEmpty ||
                  application.documents.businessRegistrationUrl.isEmpty ||
                  application.documents.venueProofUrl.isEmpty);
          final canResubmit = application.isRejected || needsDocuments;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  application.isApproved
                      ? Icons.check_circle
                      : application.isRejected
                          ? Icons.cancel
                          : Icons.hourglass_top,
                  size: 64,
                  color: application.isApproved
                      ? Colors.green
                      : application.isRejected
                          ? Colors.red
                          : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  application.isApproved
                      ? 'Your account is approved'
                      : application.isRejected
                          ? 'Application rejected'
                          : 'Waiting for admin approval',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  application.isApproved
                      ? 'You can now add your futsal grounds.'
                      : needsDocuments
                          ? 'Account created. Upload your documents to continue.'
                          : application.isRejected
                              ? 'Reason: ${application.rejectionReason ?? 'Not provided'}'
                              : 'Admin is reviewing your details and documents.',
                  textAlign: TextAlign.center,
                ),
                if (application.isApproved)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: FilledButton(
                      onPressed: () => context.go('/owner'),
                      child: const Text('Go to owner dashboard'),
                    ),
                  ),
                if (canResubmit)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: FilledButton(
                      onPressed: () =>
                          setState(() => _showResubmitForm = !_showResubmitForm),
                      child: Text(_showResubmitForm
                          ? 'Cancel'
                          : needsDocuments
                              ? 'Upload documents'
                              : 'Update and resubmit'),
                    ),
                  ),
                if (_showResubmitForm && canResubmit)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        AppTextField(
                          controller: _ownerNameController,
                          label: 'Owner name',
                          validator: (value) =>
                              Validators.required(value, 'Owner name'),
                        ),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone number',
                          validator: (value) =>
                              Validators.required(value, 'Phone number'),
                        ),
                        AppTextField(
                          controller: _businessNameController,
                          label: 'Business name',
                          validator: (value) =>
                              Validators.required(value, 'Business name'),
                        ),
                        AppTextField(
                          controller: _registrationNumberController,
                          label: 'Registration number',
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
                        ImagePickerField(
                          label: 'Identity proof',
                          maxImages: 1,
                          onChanged: (files) =>
                              _idProof = files.isEmpty ? null : files.first,
                        ),
                        ImagePickerField(
                          label: 'Business registration document',
                          maxImages: 1,
                          onChanged: (files) => _businessRegistration =
                              files.isEmpty ? null : files.first,
                        ),
                        ImagePickerField(
                          label: 'Venue proof',
                          maxImages: 1,
                          onChanged: (files) =>
                              _venueProof = files.isEmpty ? null : files.first,
                        ),
                        FilledButton(
                          onPressed: _resubmit,
                          child: const Text('Resubmit application'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
