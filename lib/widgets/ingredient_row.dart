import 'package:flutter/material.dart';
import 'package:sourdough_app/theme/app_spacing.dart';

class IngredientRow extends StatelessWidget {
  final String name;
  final double amount;
  final String unit;
  final IconData icon;

  const IngredientRow({
    super.key,
    required this.name,
    required this.amount,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$name: ${amount.round()} $unit',
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.secondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$name: ',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${amount.round()} $unit',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
