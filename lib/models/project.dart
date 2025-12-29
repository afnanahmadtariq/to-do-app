import 'package:flutter/material.dart';

class Project {
  final String id;
  final String name;
  final int colorValue;
  final int iconCodePoint;
  final bool isArchived;

  Project({
    required this.id,
    required this.name,
    this.colorValue = 0xFF2196F3, // Default blue
    required this.iconCodePoint,
    this.isArchived = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'isArchived': isArchived,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorValue: map['colorValue'] ?? 0xFF2196F3,
      iconCodePoint: map['iconCodePoint'] ?? Icons.folder.codePoint,
      isArchived: map['isArchived'] ?? false,
    );
  }
}
