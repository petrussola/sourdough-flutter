import 'package:flutter/material.dart';
import 'package:sourdough_app/datamanager.dart';
import 'package:sourdough_app/theme/app_spacing.dart';
import 'package:sourdough_app/widgets/error_state.dart';
import 'package:sourdough_app/widgets/loading_state.dart';
import 'package:sourdough_app/widgets/recipe_step_card.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class RecipePage extends StatelessWidget {
  const RecipePage({
    super.key,
    required this.dataManager,
    required this.routeIndex,
  });

  final DataManager dataManager;
  final int routeIndex;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: dataManager.getRecipes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final recipes = snapshot.data!;
          final steps = recipes[routeIndex].steps;

          if (steps.isEmpty) {
            return const Center(
              child: Text('No recipe steps available.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return RecipeStepCard(
                step: steps[index],
                isStarter: routeIndex == 0,
                isLastStep: index == steps.length - 1,
              );
            },
          );
        } else if (snapshot.hasError) {
          developer.log(
            'Failed to fetch recipe data',
            error: jsonEncode(snapshot.error.toString()),
          );
          return ErrorState(
            message: 'Failed to load recipe',
            onRetry: () {
              // Force rebuild by navigating
            },
          );
        } else {
          return const LoadingState(message: 'Loading recipe...');
        }
      },
    );
  }
}
