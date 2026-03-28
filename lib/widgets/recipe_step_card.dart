import 'package:flutter/material.dart';
import 'package:sourdough_app/datamodel.dart';
import 'package:sourdough_app/theme/app_spacing.dart';

class RecipeStepCard extends StatelessWidget {
  final RecipeStep step;
  final bool isStarter;
  final bool isLastStep;

  const RecipeStepCard({
    super.key,
    required this.step,
    required this.isStarter,
    required this.isLastStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepLabel = isStarter
        ? (isLastStep ? step.step : 'Day ${step.step}')
        : 'Step ${step.step}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepBadge(
              label: isStarter ? step.step : step.step,
              isLastStep: isLastStep,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stepLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    step.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final String label;
  final bool isLastStep;

  const _StepBadge({required this.label, required this.isLastStep});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isLastStep
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isLastStep
            ? Icon(Icons.check, size: 20, color: theme.colorScheme.onPrimary)
            : Text(
                label.length > 3 ? '!' : label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
