import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum AppButtonVariant { filled, outlined, tonal, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = AppButtonVariant.filled,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final AppButtonVariant variant;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null && !loading;
    final progressColor = variant == AppButtonVariant.outlined
        ? theme.colorScheme.primary
        : theme.colorScheme.onPrimary;
    final labelWidget = Text(label, overflow: TextOverflow.ellipsis);
    final content = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              color: progressColor,
              strokeWidth: 2.2,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (loading || icon != null) const SizedBox(width: 10),
        if (expanded) Flexible(child: labelWidget) else labelWidget,
      ],
    );

    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: enabled ? onPressed : null,
          child: content,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: enabled ? onPressed : null,
          child: content,
        ),
      AppButtonVariant.tonal => FilledButton.tonal(
          onPressed: enabled ? onPressed : null,
          child: content,
        ),
      AppButtonVariant.danger => FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: content,
        ),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
