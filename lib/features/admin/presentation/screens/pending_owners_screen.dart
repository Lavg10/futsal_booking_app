import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_empty_state.dart';
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
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: AsyncStateView<List<OwnerApplication>>(
        value: applications,
        builder: (items) {
          if (items.isEmpty) {
            return const AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'All caught up',
              message: 'There are no pending owner applications right now.',
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Review queue',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${items.length} waiting for review',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warningTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length} pending',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final application = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          leading: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.storefront_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(application.businessName),
                          subtitle: Text(application.ownerName),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.go(
                            '/admin/applications/${application.uid}',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
