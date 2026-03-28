class RecipeType {
  String name;
  List<RecipeStep> steps;

  RecipeType({
    required this.name,
    required this.steps,
  });

  factory RecipeType.fromJson(Map<String, dynamic> json) {
    var stepsJson = json['steps'] as Iterable<dynamic>;
    var steps = stepsJson.map((step) => RecipeStep.fromJson(step)).toList();
    
    return RecipeType(
      name: json['name'] as String,
      steps: steps,
    );
  }
}

class RecipeStep {
  int id;
  String step;
  String description;

  RecipeStep({
    required this.id,
    required this.step,
    required this.description,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'] as int,
      step: json['step'] as String,
      description: json['description'] as String,
    );
  }
}
