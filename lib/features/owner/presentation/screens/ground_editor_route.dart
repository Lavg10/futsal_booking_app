import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/async_state_view.dart';
import '../../data/ground_repository.dart';
import '../../domain/ground.dart';
import 'ground_editor_screen.dart';

class GroundEditorRoute extends ConsumerWidget {
  const GroundEditorRoute({super.key, required this.groundId});

  final String groundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groundAsync = ref.watch(groundDetailProvider(groundId));
    return AsyncStateView<Ground?>(
      value: groundAsync,
      builder: (ground) {
        if (ground == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Ground not found')),
            body: const Center(child: Text('This ground no longer exists.')),
          );
        }
        return GroundEditorScreen(ground: ground);
      },
    );
  }
}
