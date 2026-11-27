import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_section.dart';
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
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: AsyncStateView<OwnerApplication?>(
        value: applicationAsync,
        builder: (application) {
          if (application == null) {
            return const AppEmptyState(
              icon: Icons.description_outlined,
              title: 'No application found',
              message: 'Please register again to continue.',
            );
          }
          _prefill(application);
          final needsDocuments = !application.isApproved &&
              (application.documents.idProofUrl.isEmpty ||
                  application.documents.businessRegistrationUrl.isEmpty ||
                  application.documents.venueProofUrl.isEmpty);
          final canResubmit = application.isRejected || needsDocuments;

          final statusColor = application.isApproved
              ? AppColors.success
              : application.isRejected
                  ? AppColors.danger
                  : AppColors.warning;
          final statusTint = application.isApproved
              ? AppColors.successTint
              : application.isRejected
                  ? AppColors.dangerTint
                  : AppColors.warningTint;
          final statusIcon = application.isApproved
              ? Icons.check_circle_outline
              : application.isRejected
                  ? Icons.cancel_outlined
                  : Icons.hourglass_top_rounded;
          final statusLabel = application.isApproved
              ? 'Approved'
              : application.isRejected
                  ? 'Rejected'
                  : 'Pending review';
          final title = application.isApproved
              ? 'Your account is approved'
              : application.isRejected
                  ? 'Application rejected'
                  : 'Waiting for admin approval';
          final message = application.isApproved
              ? 'You can now add your futsal grounds.'
              : needsDocuments
                  ? 'Account created. Upload your documents to continue.'
                  : application.isRejected
                      ? 'Reason: ${application.rejectionReason ?? 'Not provided'}'
                      : 'Admin is reviewing your details and documents.';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: statusTint,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, size: 38, color: AppColors.surfaceBright),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBright,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (application.isApproved) ...[
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Go to owner dashboard',
                    icon: Icons.dashboard_outlined,
                    onPressed: () => context.go('/owner'),
                  ),
                ],
                if (canResubmit) ...[
                  const SizedBox(height: 20),
                  AppButton(
                    label: _showResubmitForm
                        ? 'Cancel'
                        : needsDocuments
                            ? 'Upload documents'
                            : 'Update and resubmit',
                    icon: _showResubmitForm ? Icons.close : Icons.edit_outlined,
                    variant: _showResubmitForm
                        ? AppButtonVariant.outlined
                        : AppButtonVariant.filled,
                    onPressed: () =>
                        setState(() => _showResubmitForm = !_showResubmitForm),
                  ),
                ],
                if (_showResubmitForm && canResubmit) ...[
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: AppSection(
                      title: 'Update application',
                      icon: Icons.edit_document,
                      children: [
                        AppTextField(
                          controller: _ownerNameController,
                          label: 'Owner name',
                          prefixIcon: Icons.badge_outlined,
                          validator: (value) =>
                              Validators.required(value, 'Owner name'),
                        ),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone number',
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) =>
                              Validators.required(value, 'Phone number'),
                        ),
                        AppTextField(
                          controller: _businessNameController,
                          label: 'Business name',
                          prefixIcon: Icons.storefront_outlined,
                          validator: (value) =>
                              Validators.required(value, 'Business name'),
                        ),
                        AppTextField(
                          controller: _registrationNumberController,
                          label: 'Registration number',
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
                        const SizedBox(height: 12),
                        ImagePickerField(
                          label: 'Identity proof',
                          maxImages: 1,
                          onChanged: (files) =>
                              _idProof = files.isEmpty ? null : files.first,
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
                          label: 'Venue proof',
                          maxImages: 1,
                          onChanged: (files) =>
                              _venueProof = files.isEmpty ? null : files.first,
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: 'Resubmit application',
                          icon: Icons.send_outlined,
                          onPressed: _resubmit,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
