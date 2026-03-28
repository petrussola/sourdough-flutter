import 'package:flutter/material.dart';
import 'package:sourdough_app/pages/bread_calculator.dart';
import 'package:sourdough_app/pages/starter_calculator.dart';
import 'package:sourdough_app/theme/app_spacing.dart';

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key});

  static const _wideBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > _wideBreakpoint;

        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(child: StarterCalculator()),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: BreadCalculator()),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: const [
              StarterCalculator(),
              SizedBox(height: AppSpacing.sm),
              BreadCalculator(),
            ],
          ),
        );
      },
    );
  }
}
