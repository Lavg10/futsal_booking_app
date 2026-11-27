import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'app_button.dart';
import 'app_empty_state.dart';

class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      error: (error, stack) => AppEmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load data',
        message: '$error',
        action: onRetry == null
            ? null
            : AppButton(
                label: 'Try again',
                icon: Icons.refresh,
                onPressed: onRetry,
                expanded: false,
              ),
      ),
      data: builder,
    );
  }
}
