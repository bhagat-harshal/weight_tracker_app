class WeightEntry {
  final DateTime dateTime;
  final double weight;

  WeightEntry({
    required this.dateTime,
    required this.weight,
  });

  // For storage (toMap/fromMap)
  Map<String, dynamic> toMap() => {
        'dateTime': dateTime.toIso8601String(),
        'weight': weight,
      };

  factory WeightEntry.fromMap(Map<String, dynamic> map) => WeightEntry(
        dateTime: DateTime.parse(map['dateTime']),
        weight: map['weight']?.toDouble() ?? 0.0,
      );
}
