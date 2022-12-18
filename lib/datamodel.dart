class ReceipeStep {
  late int id;
  late int step;
  late String description;

  ReceipeStep({
    required this.id,
    required this.step,
    required this.description,
  });

  factory ReceipeStep.fromJson(Map<String, dynamic> json) {
    return ReceipeStep(
      id: json['id'] as int,
      step: json['step'] as int,
      description: json['description'] as String,
    );
  }
}
