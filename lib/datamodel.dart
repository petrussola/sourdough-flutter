class ReceipeType {
  String name;
  List<ReceipeStep> steps;

  ReceipeType({
    required this.name,
    required this.steps,
  });

  factory ReceipeType.fromJson(Map<String, dynamic> json) {
    var stepsJson = json['steps'] as Iterable<dynamic>;
    var steps = stepsJson.map((step) => ReceipeStep.fromJson(step)).toList();
    
    return ReceipeType(
      name: json['name'] as String,
      steps: steps,
    );
  }
}

class ReceipeStep {
  int id;
  String step;
  String description;

  ReceipeStep({
    required this.id,
    required this.step,
    required this.description,
  });

  factory ReceipeStep.fromJson(Map<String, dynamic> json) {
    return ReceipeStep(
      id: json['id'] as int,
      step: json['step'] as String,
      description: json['description'] as String,
    );
  }
}
