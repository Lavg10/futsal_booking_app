import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/async_state_view.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../data/ground_repository.dart';
import '../../domain/ground.dart';
import '../../providers/owner_providers.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grounds = ref.watch(myGroundsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My grounds'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/owner/grounds/new'),
        child: const Icon(Icons.add),
      ),
      body: AsyncStateView<List<Ground>>(
        value: grounds,
        builder: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No grounds yet. Tap + to add your first futsal ground.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: items.length,
            itemBuilder: (context, index) => _GroundCard(ground: items[index]),
          );
        },
      ),
    );
  }
}

class _GroundCard extends ConsumerWidget {
  const _GroundCard({required this.ground});

  final Ground ground;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> confirmDelete() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete ground'),
          content: Text('Delete ${ground.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref
          .read(groundDeleteControllerProvider.notifier)
          .delete(ground.id);
      if (!context.mounted) return;
      final result = ref.read(groundDeleteControllerProvider);
      if (result.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: ${result.error}')),
        );
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ground.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                ground.imageUrls.first,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(height: 0),
              ),
            ),
          ListTile(
            title: Text(ground.name),
            subtitle: Text(
              '${ground.address}\nBase price: ${ground.basePrice.toStringAsFixed(0)} '
              '· ${ground.slots.length} slots',
            ),
            isThreeLine: true,
            trailing: Switch(
              value: ground.isActive,
              onChanged: (value) => ref
                  .read(groundRepositoryProvider)
                  .setActive(ground.id, value),
            ),
          ),
          OverflowBar(
            children: [
              TextButton.icon(
                onPressed: () =>
                    context.go('/owner/grounds/${ground.id}/edit'),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              TextButton.icon(
                onPressed: confirmDelete,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
