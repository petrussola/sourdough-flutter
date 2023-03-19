import 'package:flutter/material.dart';
import 'package:sourdough_app/datamanager.dart';
import 'package:sourdough_app/datamodel.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class ReceipePage extends StatelessWidget {
  const ReceipePage({
    super.key,
    required this.dataManager,
    required this.routeIndex,
  });

  final DataManager dataManager;
  final int routeIndex;

  @override
  Widget build(BuildContext context) {
    return Receipe(
      dataManager: dataManager,
      routeIndex: routeIndex,
    );
  }
}

class Receipe extends StatelessWidget {
  const Receipe({
    super.key,
    required this.dataManager,
    required this.routeIndex,
  });

  final DataManager dataManager;
  final int routeIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
          future: dataManager.getReceipes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var receipes = snapshot.data!;

              return ListView.builder(
                  itemCount: receipes[routeIndex].steps.length,
                  itemBuilder: ((context, index) {
                    return ReceipeItem(
                      step: receipes[routeIndex].steps[index],
                      isLastStep:
                          receipes[routeIndex].steps.length - 1 == index,
                      isStarter: routeIndex == 0,
                    );
                  }));
            } else {
              if (snapshot.hasError) {
                developer.log(
                  'Failed to fetch receipe data',
                  error: jsonEncode(snapshot.error),
                );
                return const Text('There was an error');
              } else {
                return const CircularProgressIndicator();
              }
            }
          }),
    );
  }
}

class ReceipeItem extends StatelessWidget {
  const ReceipeItem({
    super.key,
    required this.step,
    required this.isLastStep,
    required this.isStarter,
  });

  final ReceipeStep step;
  final bool isLastStep;
  final bool isStarter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: isStarter
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        isLastStep ? step.step : 'Day ${step.step}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    Text(
                      step.description,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                )
              : Text(
                  "${step.step}. ${step.description}",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
        ),
        if (!isLastStep) const Divider()
      ],
    );
  }
}
