import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sourdough_app/datamanager.dart';
import 'package:sourdough_app/services/ad_service.dart';
import 'package:sourdough_app/theme/app_spacing.dart';
import 'package:sourdough_app/widgets/error_state.dart';
import 'package:sourdough_app/widgets/loading_state.dart';
import 'package:sourdough_app/widgets/recipe_step_card.dart';
import 'dart:developer' as developer;
import 'dart:convert';

/// Insert a native ad after every [_adInterval]th recipe step.
const _adInterval = 3;

class RecipePage extends StatefulWidget {
  const RecipePage({
    super.key,
    required this.dataManager,
    required this.routeIndex,
  });

  final DataManager dataManager;
  final int routeIndex;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final List<NativeAd> _activeNativeAds = [];
  List<_ListItem>? _cachedItems;
  int? _cachedStepCount;

  @override
  void dispose() {
    for (final ad in _activeNativeAds) {
      ad.dispose();
    }
    super.dispose();
  }

  List<_ListItem> _buildItems(int stepCount) {
    // Return cached list if step count hasn't changed (avoids duplicate ad
    // requests on FutureBuilder rebuilds).
    if (_cachedItems != null && _cachedStepCount == stepCount) {
      return _cachedItems!;
    }

    final items = <_ListItem>[];
    for (var i = 0; i < stepCount; i++) {
      items.add(_StepItem(i));
      if ((i + 1) % _adInterval == 0 && i < stepCount - 1 && !kIsWeb) {
        items.add(_NativeAdItem());
      }
    }
    _cachedStepCount = stepCount;
    _cachedItems = items;
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.dataManager.getRecipes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final recipes = snapshot.data!;
          final steps = recipes[widget.routeIndex].steps;

          if (steps.isEmpty) {
            return const Center(
              child: Text('No recipe steps available.'),
            );
          }

          final items = _buildItems(steps.length);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.sm,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item is _StepItem) {
                return RecipeStepCard(
                  step: steps[item.stepIndex],
                  isStarter: widget.routeIndex == 0,
                  isLastStep: item.stepIndex == steps.length - 1,
                );
              } else {
                return _NativeAdWidget(
                  onAdObtained: (ad) => _activeNativeAds.add(ad),
                );
              }
            },
          );
        } else if (snapshot.hasError) {
          developer.log(
            'Failed to fetch recipe data',
            error: jsonEncode(snapshot.error.toString()),
          );
          return ErrorState(
            message: 'Failed to load recipe',
            onRetry: () {},
          );
        } else {
          return const LoadingState(message: 'Loading recipe...');
        }
      },
    );
  }
}

// ── List item types ──

sealed class _ListItem {}

class _StepItem extends _ListItem {
  final int stepIndex;
  _StepItem(this.stepIndex);
}

class _NativeAdItem extends _ListItem {}

// ── Native ad widget ──

class _NativeAdWidget extends StatefulWidget {
  final void Function(NativeAd ad) onAdObtained;

  const _NativeAdWidget({required this.onAdObtained});

  @override
  State<_NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<_NativeAdWidget> {
  NativeAd? _ad;

  @override
  void initState() {
    super.initState();
    _ad = AdService.instance.getNativeAd();
    if (_ad != null) {
      widget.onAdObtained(_ad!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 320,
          minHeight: 90,
          maxHeight: 200,
        ),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
