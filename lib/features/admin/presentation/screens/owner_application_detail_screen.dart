import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/async_state_view.dart';
import '../../../owner/domain/owner_application.dart';
import '../../data/admin_repository.dart';
import '../../providers/admin_providers.dart';

class OwnerApplicationDetailScreen extends ConsumerWidget {
  const OwnerApplicationDetailScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationAsync =
        ref.watch(ownerApplicationDetailProvider(applicationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Application details')),
      body: AsyncStateView<OwnerApplication?>(
        value: applicationAsync,
        builder: (application) {
          if (application == null) {
            return const AppEmptyState(
              icon: Icons.search_off,
              title: 'Application not found',
              message: 'This application may have already been reviewed.',
            );
          }
          return _ApplicationBody(application: application);
        },
      ),
    );
  }
}

class _ApplicationBody extends ConsumerWidget {
  const _ApplicationBody({required this.application});

  final OwnerApplication application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(adminReviewControllerProvider);

    Future<void> review({String? rejectionReason}) async {
      final controller = ref.read(adminReviewControllerProvider.notifier);
      if (rejectionReason == null) {
        await controller.approve(application);
      } else {
        await controller.reject(
          uid: application.uid,
          reason: rejectionReason,
        );
      }
      if (!context.mounted) return;
      final result = ref.read(adminReviewControllerProvider);
      if (result.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review failed: ${result.error}')),
        );
        return;
      }
      ref.invalidate(pendingOwnerApplicationsProvider);
      context.go('/admin');
    }

    Future<void> askRejectionReason() async {
      final reasonController = TextEditingController();
      try {
        final reason = await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Reject application'),
            content: TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                prefixIcon: Icon(Icons.report_outlined, size: 20),
              ),
              maxLines: 3,
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              AppButton(
                label: 'Reject',
                variant: AppButtonVariant.danger,
                expanded: false,
                onPressed: () {
                  final text = reasonController.text.trim();
                  if (text.isEmpty) return;
                  Navigator.pop(dialogContext, text);
                },
              ),
            ],
          ),
        );
        if (reason != null) await review(rejectionReason: reason);
      } finally {
        reasonController.dispose();
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fact_check_outlined,
                    color: AppColors.surfaceBright,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application review',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Text(
                        'Check the details and documents below.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppSection(
            title: 'Applicant details',
            icon: Icons.person_outline,
            children: [
              _row('Owner', application.ownerName),
              _row('Email', application.email),
              _row('Phone', application.phoneNumber),
              _row('Business', application.businessName),
              _row('Registration no.', application.registrationNumber),
              _row('Address', application.address),
              _row(
                'Location',
                '${application.latitude.toStringAsFixed(6)}, '
                    '${application.longitude.toStringAsFixed(6)}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSection(
            title: 'Documents',
            icon: Icons.description_outlined,
            subtitle: 'Tap a document to view it',
            children: [
              _documentCard(
                context,
                'Identity proof',
                application.documents.idProofUrl,
              ),
              const SizedBox(height: 10),
              _documentCard(
                context,
                'Business registration',
                application.documents.businessRegistrationUrl,
              ),
              const SizedBox(height: 10),
              _documentCard(
                context,
                'Venue proof',
                application.documents.venueProofUrl,
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Approve owner',
            icon: Icons.check_circle_outline,
            loading: reviewState.isLoading,
            onPressed: () => review(),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Reject application',
            icon: Icons.cancel_outlined,
            variant: AppButtonVariant.danger,
            loading: reviewState.isLoading,
            onPressed: askRejectionReason,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentCard(BuildContext context, String label, String url) {
    return Container(
      decoration: BoxDecoration(
        color: url.isEmpty ? AppColors.surface : AppColors.surfaceBright,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(label),
        subtitle: Text(url.isEmpty ? 'Not uploaded' : 'Tap to view'),
        trailing: url.isEmpty
            ? const Icon(Icons.close, color: AppColors.textSecondary)
            : const Icon(Icons.open_in_new, color: AppColors.primary),
        onTap: url.isEmpty
            ? null
            : () {
                showDialog<void>(
                  context: context,
                  builder: (_) => Dialog(
                    child: InteractiveViewer(child: Image.network(url)),
                  ),
                );
              },
      ),
    );
  }
}
