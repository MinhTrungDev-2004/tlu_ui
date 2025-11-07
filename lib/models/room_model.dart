import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // 🆕 THÊM IMPORT NÀY
import '../../services/firestore_service.dart';

class RoomModel implements HasId {
  final String id;
  final String code; // "P001", "P002", "P003"
  final String name; // "Phòng 101-A1", "Phòng 203-A1"
  final String building; // "Nhà A1", "Nhà C2"
  final int capacity; // 100, 80, 60
  final RoomType type; // Lý thuyết, Thực hành, Hội trường
  final String? description;
  final List<String>? facilities; // ["máy chiếu", "máy lạnh", "máy tính"]
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoomModel({
    required this.id,
    required this.code,
    required this.name,
    required this.building,
    required this.capacity,
    required this.type,
    this.description,
    this.facilities,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RoomModel.fromMap(Map<String, dynamic> data, String id) {
    return RoomModel(
      id: id,
      code: data['code']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      building: data['building']?.toString() ?? '',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      type: _parseRoomType(data['type']),
      description: data['description']?.toString(),
      facilities: _parseStringList(data['facilities']),
      isAvailable: data['isAvailable'] ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'building': building,
      'capacity': capacity,
      'type': type.name,
      if (description != null) 'description': description,
      if (facilities != null) 'facilities': facilities,
      'isAvailable': isAvailable,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // Helper methods
  static List<String>? _parseStringList(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return null;
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    if (timestamp is Timestamp) return timestamp.toDate();
    return null;
  }

  static RoomType _parseRoomType(dynamic type) {
    if (type == null) return RoomType.lecture;
    if (type is String) {
      return RoomType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => RoomType.lecture,
      );
    }
    return RoomType.lecture;
  }

  RoomModel copyWith({
    String? id,
    String? code,
    String? name,
    String? building,
    int? capacity,
    RoomType? type,
    String? description,
    List<String>? facilities,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      building: building ?? this.building,
      capacity: capacity ?? this.capacity,
      type: type ?? this.type,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Business logic methods
  bool get isLectureRoom => type == RoomType.lecture;
  bool get isLabRoom => type == RoomType.lab;
  bool get isHallRoom => type == RoomType.hall;
  
  String get displayName => '$code - $name';
  
  String get typeDisplay {
    switch (type) {
      case RoomType.lecture:
        return 'Lý thuyết';
      case RoomType.lab:
        return 'Thực hành';
      case RoomType.hall:
        return 'Hội trường';
    }
  }

  /// Kiểm tra phòng có đủ sức chứa không
  bool hasSufficientCapacity(int requiredCapacity) {
    return capacity >= requiredCapacity;
  }

  /// Kiểm tra phòng có tiện nghi cần thiết không
  bool hasFacilities(List<String> requiredFacilities) {
    if (facilities == null) return false;
    return requiredFacilities.every((facility) => facilities!.contains(facility));
  }

  @override
  String toString() {
    return 'RoomModel(id: $id, code: $code, name: $name, building: $building, capacity: $capacity, type: $type)';
  }
}

enum RoomType {
  lecture, // Lý thuyết
  lab,     // Thực hành
  hall,    // Hội trường
}

// Extension for Vietnamese display
extension RoomTypeExtension on RoomType {
  String get vietnameseName {
    switch (this) {
      case RoomType.lecture:
        return 'Lý thuyết';
      case RoomType.lab:
        return 'Thực hành';
      case RoomType.hall:
        return 'Hội trường';
    }
  }

  IconData get icon {
    switch (this) {
      case RoomType.lecture:
        return Icons.school;
      case RoomType.lab:
        return Icons.computer;
      case RoomType.hall:
        return Icons.people;
    }
  }

  Color get color {
    switch (this) {
      case RoomType.lecture:
        return Colors.blue;
      case RoomType.lab:
        return Colors.green;
      case RoomType.hall:
        return Colors.orange;
    }
  }
}