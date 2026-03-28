import 'package:flutter/material.dart';
import 'package:sourdough_app/theme/app_spacing.dart';
import 'package:sourdough_app/widgets/ingredient_row.dart';

class StarterCalculator extends StatefulWidget {
  const StarterCalculator({super.key});

  @override
  State<StarterCalculator> createState() => _StarterCalculatorState();
}

class _StarterCalculatorState extends State<StarterCalculator> {
  var _grams = 40.0;

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
                Icon(Icons.science, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Starter Proportions',
                    style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                '${_grams.round()}g of starter',
                style: theme.textTheme.headlineMedium,
              ),
            ),
            Semantics(
              label: 'Starter grams: ${_grams.round()}',
              child: Slider(
                value: _grams,
                min: 0,
                max: 250,
                divisions: 250,
                label: '${_grams.round()}g',
                onChanged: (v) => setState(() => _grams = v),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            IngredientRow(
              name: 'Flour',
              amount: _grams * 1.0,
              unit: 'g',
              icon: Icons.grain,
            ),
            IngredientRow(
              name: 'Water',
              amount: _grams * 1.0,
              unit: 'g',
              icon: Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }
}
