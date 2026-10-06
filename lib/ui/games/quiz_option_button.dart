import 'package:flutter/material.dart';

import '../../core/theme.dart';

enum OptionState { idle, correct, wrong, disabled }

/// A large answer button used by the story, the quiz and Build a Plant.
class QuizOptionButton extends StatelessWidget {
  const QuizOptionButton({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (
      Color bg,
      Color border,
      IconData? icon,
      Color iconColor,
    ) = switch (state) {
      OptionState.correct => (
        AppColors.mint,
        AppColors.leaf,
        Icons.check_circle_rounded,
        AppColors.leaf,
      ),
      OptionState.wrong => (
        AppColors.berrySoft,
        AppColors.berry,
        Icons.cancel_rounded,
        AppColors.berry,
      ),
      _ => (AppColors.surface, AppColors.line, null, AppColors.inkMuted),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: border, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: state == OptionState.idle ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Gap.lg,
              vertical: Gap.md + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                          state == OptionState.disabled
                              ? AppColors.inkMuted
                              : AppColors.ink,
                    ),
                  ),
                ),
                if (icon != null) Icon(icon, color: iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
