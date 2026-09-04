import 'package:flutter/material.dart';
import 'package:baai/models/models.dart';
import 'package:baai/data/dummy_data.dart';

class AppState extends ChangeNotifier {
  // ─── View Mode ──────────────────────────────────────────────
  bool _isKioskMode = false;
  bool get isKioskMode => _isKioskMode;
  void toggleViewMode() { _isKioskMode = !_isKioskMode; notifyListeners(); }
  void setKioskMode(bool v) { _isKioskMode = v; notifyListeners(); }

  // ─── Household ──────────────────────────────────────────────
  late Household household;

  // ─── Staff ──────────────────────────────────────────────────
  List<StaffMember> staff = [];

  // ─── Tasks ──────────────────────────────────────────────────
  List<HouseholdTask> tasks = [];
  int _taskCounter = 100;

  // ─── Inventory (Smart Pantry) ───────────────────────────────
  List<InventoryItem> inventory = [];

  // ─── Recipes ────────────────────────────────────────────────
  List<Recipe> recipes = [];

  // ─── Alerts ─────────────────────────────────────────────────
  List<BaaiAlert> alerts = [];
  int _alertCounter = 100;

  // ─── Voice Recording State ──────────────────────────────────
  bool _isRecording = false;
  bool get isRecording => _isRecording;
  void setRecording(bool v) { _isRecording = v; notifyListeners(); }

  // ─── Active Navigation ──────────────────────────────────────
  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;
  void setNavIndex(int i) { _selectedNavIndex = i; notifyListeners(); }

  // ─── Init with Dummy Data ──────────────────────────────────
  AppState() {
    _loadDummyData();
  }

  void _loadDummyData() {
    household = DummyData.defaultHousehold;
    staff = List.from(DummyData.staffProfiles);
    tasks = List.from(DummyData.dailyTasks);
    inventory = List.from(DummyData.inventoryItems);
    recipes = List.from(DummyData.recipes);
    _generateInitialAlerts();
  }

  void resetToDefaults() {
    _loadDummyData();
    _selectedNavIndex = 0;
    notifyListeners();
  }

  // ─── Task Operations ───────────────────────────────────────
  void addTask(HouseholdTask task) {
    tasks.insert(0, task);
    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus status) {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    tasks[idx].status = status;
    if (status == TaskStatus.completed) {
      tasks[idx].completedAt = DateTime.now();
      // Smart Pantry: auto-deduct ingredients if linked to recipe
      if (tasks[idx].linkedRecipeId != null) {
        _deductRecipeIngredients(tasks[idx].linkedRecipeId!);
      }
    }
    notifyListeners();
  }

  String generateTaskId() => 't-${++_taskCounter}';
  String generateAlertId() => 'a-${++_alertCounter}';

  // ─── Smart Pantry: Deduct & Alert ──────────────────────────
  void _deductRecipeIngredients(String recipeId) {
    final recipe = recipes.firstWhere((r) => r.id == recipeId, orElse: () => Recipe(id: '', name: ''));
    if (recipe.id.isEmpty) return;

    for (final ingredient in recipe.ingredients) {
      final invIdx = inventory.indexWhere((i) => i.id == ingredient.inventoryItemId);
      if (invIdx == -1) continue;
      inventory[invIdx].quantity = (inventory[invIdx].quantity - ingredient.quantity).clamp(0, double.infinity);
      inventory[invIdx].updateStock();

      if (inventory[invIdx].isLowStock) {
        _addAlert(BaaiAlert(
          id: generateAlertId(),
          type: AlertType.lowStock,
          title: 'Low Stock: ${inventory[invIdx].name}',
          message: '${inventory[invIdx].name} is at ${inventory[invIdx].quantity.toStringAsFixed(2)} ${inventory[invIdx].unit.name}. Reorder threshold: ${inventory[invIdx].reorderThreshold} ${inventory[invIdx].unit.name}.',
        ));
        // Trigger auto-reorder alert
        _addAlert(BaaiAlert(
          id: generateAlertId(),
          type: AlertType.reorderTriggered,
          title: 'Reorder Triggered: ${inventory[invIdx].name}',
          message: 'Auto-reorder initiated for ${inventory[invIdx].name}. Please confirm with vendor.',
        ));
      }
    }
  }

  void manualDeductItem(String itemId, double qty) {
    final idx = inventory.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    inventory[idx].quantity = (inventory[idx].quantity - qty).clamp(0, double.infinity);
    inventory[idx].updateStock();
    if (inventory[idx].isLowStock) {
      _addAlert(BaaiAlert(
        id: generateAlertId(),
        type: AlertType.lowStock,
        title: 'Low Stock: ${inventory[idx].name}',
        message: '${inventory[idx].name} dropped to ${inventory[idx].quantity.toStringAsFixed(2)} ${inventory[idx].unit.name}.',
      ));
    }
    notifyListeners();
  }

  void restockItem(String itemId, double qty) {
    final idx = inventory.indexWhere((i) => i.id == itemId);
    if (idx == -1) return;
    inventory[idx].quantity += qty;
    inventory[idx].updateStock();
    notifyListeners();
  }

  // ─── Alert Operations ──────────────────────────────────────
  void _addAlert(BaaiAlert alert) {
    alerts.insert(0, alert);
  }

  void addAlert(BaaiAlert alert) {
    alerts.insert(0, alert);
    notifyListeners();
  }

  void markAlertRead(String id) {
    final idx = alerts.indexWhere((a) => a.id == id);
    if (idx != -1) { alerts[idx].isRead = true; notifyListeners(); }
  }

  void clearAlerts() { alerts.clear(); notifyListeners(); }

  int get unreadAlertCount => alerts.where((a) => !a.isRead).length;

  // ─── Helpers ────────────────────────────────────────────────
  List<HouseholdTask> get pendingTasks => tasks.where((t) => t.status == TaskStatus.pending).toList();
  List<HouseholdTask> get inProgressTasks => tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<HouseholdTask> get completedTasks => tasks.where((t) => t.status == TaskStatus.completed).toList();
  List<HouseholdTask> get overdueTasks => tasks.where((t) => t.status == TaskStatus.overdue).toList();
  List<InventoryItem> get lowStockItems => inventory.where((i) => i.isLowStock).toList();

  Map<String, double> get currentStockLevels {
    return { for (var item in inventory) item.id: item.quantity };
  }

  String generateReorderLink(InventoryItem item) {
    // Generate a deep link for Swiggy Instamart / Blinkit
    final query = Uri.encodeComponent(item.name);
    return 'https://blinkit.com/s/?q=$query';
  }

  StaffMember? getStaffById(String id) {
    try { return staff.firstWhere((s) => s.id == id); }
    catch (_) { return null; }
  }

  void _generateInitialAlerts() {
    alerts = [
      BaaiAlert(id: 'a-001', type: AlertType.system, title: 'Welcome to BAAI', message: 'Project BAAI is running with sandbox data. Use the testing dashboard to switch views.'),
      BaaiAlert(id: 'a-002', type: AlertType.taskOverdue, title: 'Overdue: Grocery Restock', message: 'Vegetable & dairy restock was due this morning. Please action immediately.'),
      BaaiAlert(id: 'a-003', type: AlertType.lowStock, title: 'Low Stock: Green Chillies', message: 'Green chillies at 100g – approaching minimum threshold.'),
    ];
  }
}
