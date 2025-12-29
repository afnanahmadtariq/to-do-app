class Tag {
  final String id;
  final String name;
  final int colorValue;

  Tag({
    required this.id,
    required this.name,
    this.colorValue = 0xFF9E9E9E, // Default grey
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF9E9E9E,
    );
  }
}
