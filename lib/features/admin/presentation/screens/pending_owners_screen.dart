import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/async_state_view.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../owner/domain/owner_application.dart';
import '../../data/admin_repository.dart';

class PendingOwnersScreen extends ConsumerWidget {
  const PendingOwnersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(pendingOwnerApplicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner applications'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: AsyncStateView<List<OwnerApplication>>(
        value: applications,
        builder: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No pending applications'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final application = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.store),
                  title: Text(application.businessName),
                  subtitle: Text(application.ownerName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go(
                    '/admin/applications/${application.uid}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
