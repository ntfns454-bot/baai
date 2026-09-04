import 'package:flutter/material.dart';

// ─── Task Model ───────────────────────────────────────────────
enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { pending, inProgress, completed, overdue }
enum TaskCategory { cleaning, cooking, maintenance, shopping, laundry, gardening, other }

class HouseholdTask {
  final String id;
  String title;
  String description;
  TaskPriority priority;
  TaskStatus status;
  TaskCategory category;
  String assignedTo; // staff ID
  DateTime createdAt;
  DateTime? dueAt;
  DateTime? completedAt;
  bool isRecurring;
  String? recurrenceRule;
  String? voiceNoteText;
  String? linkedRecipeId;

  HouseholdTask({
    required this.id,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.other,
    this.assignedTo = '',
    DateTime? createdAt,
    this.dueAt,
    this.completedAt,
    this.isRecurring = false,
    this.recurrenceRule,
    this.voiceNoteText,
    this.linkedRecipeId,
  }) : createdAt = createdAt ?? DateTime.now();

  IconData get categoryIcon {
    switch (category) {
      case TaskCategory.cleaning: return Icons.cleaning_services;
      case TaskCategory.cooking: return Icons.restaurant;
      case TaskCategory.maintenance: return Icons.build;
      case TaskCategory.shopping: return Icons.shopping_cart;
      case TaskCategory.laundry: return Icons.local_laundry_service;
      case TaskCategory.gardening: return Icons.yard;
      case TaskCategory.other: return Icons.task_alt;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low: return const Color(0xFF4CAF50);
      case TaskPriority.medium: return const Color(0xFFFFA726);
      case TaskPriority.high: return const Color(0xFFEF5350);
      case TaskPriority.urgent: return const Color(0xFFD32F2F);
    }
  }
}

// ─── Inventory / Pantry Model ──────────────────────────────────
enum InventoryUnit { kg, g, l, ml, pieces, packets, dozen, cups }

class InventoryItem {
  final String id;
  String name;
  double quantity;
  InventoryUnit unit;
  double reorderThreshold;
  String category; // "dairy", "spices", "vegetables", etc.
  DateTime? expiryDate;
  DateTime lastUpdated;
  bool isLowStock;

  InventoryItem({
    required this.id,
    required this.name,
    this.quantity = 0,
    this.unit = InventoryUnit.pieces,
    this.reorderThreshold = 2,
    this.category = 'General',
    this.expiryDate,
    DateTime? lastUpdated,
  })  : lastUpdated = lastUpdated ?? DateTime.now(),
        isLowStock = quantity <= 2; // default, recalculated

  void updateStock() {
    isLowStock = quantity <= reorderThreshold;
    lastUpdated = DateTime.now();
  }
}

// ─── Recipe Model ──────────────────────────────────────────────
class RecipeIngredient {
  final String inventoryItemId;
  final String name;
  final double quantity;
  final InventoryUnit unit;

  RecipeIngredient({
    required this.inventoryItemId,
    required this.name,
    required this.quantity,
    required this.unit,
  });
}

class Recipe {
  final String id;
  String name;
  String description;
  List<RecipeIngredient> ingredients;
  int servings;
  int prepTimeMinutes;
  String instructions;

  Recipe({
    required this.id,
    required this.name,
    this.description = '',
    this.ingredients = const [],
    this.servings = 4,
    this.prepTimeMinutes = 30,
    this.instructions = '',
  });
}

// ─── Staff Model ───────────────────────────────────────────────
enum StaffRole { cook, cleaner, gardener, driver, nanny, manager }

class StaffMember {
  final String id;
  String name;
  StaffRole role;
  String phone;
  String avatarUrl;
  bool isOnDuty;
  List<String> assignedTaskIds;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    this.phone = '',
    this.avatarUrl = '',
    this.isOnDuty = true,
    this.assignedTaskIds = const [],
  });

  IconData get roleIcon {
    switch (role) {
      case StaffRole.cook: return Icons.restaurant;
      case StaffRole.cleaner: return Icons.cleaning_services;
      case StaffRole.gardener: return Icons.yard;
      case StaffRole.driver: return Icons.directions_car;
      case StaffRole.nanny: return Icons.child_care;
      case StaffRole.manager: return Icons.manage_accounts;
    }
  }

  String get roleLabel {
    return role.name[0].toUpperCase() + role.name.substring(1);
  }
}

// ─── Household Model ──────────────────────────────────────────
class Household {
  final String id;
  String name;
  String address;
  int memberCount;
  String ownerName;

  Household({
    required this.id,
    required this.name,
    this.address = '',
    this.memberCount = 4,
    this.ownerName = 'Admin',
  });
}

// ─── Alert Model ──────────────────────────────────────────────
enum AlertType { lowStock, taskOverdue, reorderTriggered, voiceCommand, system }

class BaaiAlert {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  BaaiAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    DateTime? timestamp,
    this.isRead = false,
  }) : timestamp = timestamp ?? DateTime.now();

  IconData get icon {
    switch (type) {
      case AlertType.lowStock: return Icons.inventory;
      case AlertType.taskOverdue: return Icons.warning_amber;
      case AlertType.reorderTriggered: return Icons.shopping_cart_checkout;
      case AlertType.voiceCommand: return Icons.mic;
      case AlertType.system: return Icons.info_outline;
    }
  }

  Color get color {
    switch (type) {
      case AlertType.lowStock: return const Color(0xFFFF9800);
      case AlertType.taskOverdue: return const Color(0xFFF44336);
      case AlertType.reorderTriggered: return const Color(0xFF2196F3);
      case AlertType.voiceCommand: return const Color(0xFF9C27B0);
      case AlertType.system: return const Color(0xFF607D8B);
    }
  }
}
