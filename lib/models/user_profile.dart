enum WeightUnit { kg, lb }

class UserProfile {
  String name;
  double height; // in cm
  double targetWeight;
  WeightUnit unit;

  UserProfile({
    required this.name,
    required this.height,
    required this.targetWeight,
    required this.unit,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'height': height,
        'targetWeight': targetWeight,
        'unit': unit.index,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        name: map['name'] ?? '',
        height: map['height']?.toDouble() ?? 0.0,
        targetWeight: map['targetWeight']?.toDouble() ?? 0.0,
        unit: WeightUnit.values[map['unit'] ?? 0],
      );
}
