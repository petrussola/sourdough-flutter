import 'package:flutter/material.dart';
import 'package:sourdough_app/theme/app_spacing.dart';
import 'package:sourdough_app/widgets/ingredient_row.dart';

class BreadCalculator extends StatefulWidget {
  const BreadCalculator({super.key});

  @override
  State<BreadCalculator> createState() => _BreadCalculatorState();
}

class _BreadCalculatorState extends State<BreadCalculator> {
  var _grams = 100.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bakery_dining, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Bread Proportions',
                    style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                '${_grams.round()}g active sourdough',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            Semantics(
              label: 'Active sourdough grams: ${_grams.round()}',
              child: Slider(
                value: _grams,
                min: 0,
                max: 500,
                divisions: 500,
                label: '${_grams.round()}g',
                onChanged: (v) => setState(() => _grams = v),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            IngredientRow(
              name: 'Flour',
              amount: _grams * 4.5,
              unit: 'g',
              icon: Icons.grain,
            ),
            IngredientRow(
              name: 'Water',
              amount: _grams * 3.25,
              unit: 'g',
              icon: Icons.water_drop,
            ),
            IngredientRow(
              name: 'Salt',
              amount: _grams * 0.11,
              unit: 'g',
              icon: Icons.scatter_plot,
            ),
            IngredientRow(
              name: 'Honey (optional)',
              amount: _grams * 0.10,
              unit: 'g',
              icon: Icons.local_dining,
            ),
          ],
        ),
      ),
    );
  }
}
