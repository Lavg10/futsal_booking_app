import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            return const Center(child: Text('Application not found'));
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
      final reason = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reject application'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: 'Reason'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = reasonController.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(dialogContext, text);
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      if (reason != null) await review(rejectionReason: reason);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _infoCard([
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
          ]),
          const SizedBox(height: 16),
          const Text('Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _documentCard(context, 'Identity proof', application.documents.idProofUrl),
          _documentCard(context, 'Business registration',
              application.documents.businessRegistrationUrl),
          _documentCard(context, 'Venue proof', application.documents.venueProofUrl),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: reviewState.isLoading ? null : () => review(),
            child: const Text('Approve owner'),
          ),
          OutlinedButton(
            onPressed: reviewState.isLoading ? null : askRejectionReason,
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _documentCard(BuildContext context, String label, String url) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.description),
        title: Text(label),
        subtitle: const Text('Tap to view'),
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
