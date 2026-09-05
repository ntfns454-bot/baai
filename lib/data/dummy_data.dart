import 'package:baai/models/models.dart';

class DummyData {
  // ─── Default Household ─────────────────────────────────────
  static Household get defaultHousehold => Household(
    id: 'hh-001',
    name: 'Villa Saffron',
    address: '42 Jasmine Lane, Banjara Hills, Hyderabad',
    memberCount: 6,
    ownerName: 'Arjun Mehta',
  );

  // ─── Staff Profiles ────────────────────────────────────────
  static List<StaffMember> get staffProfiles => [
    StaffMember(id: 's-001', name: 'Lakshmi Devi', role: StaffRole.cook, phone: '+91 98765 43210', isOnDuty: true),
    StaffMember(id: 's-002', name: 'Ramu Kumar', role: StaffRole.cleaner, phone: '+91 98765 43211', isOnDuty: true),
    StaffMember(id: 's-003', name: 'Ganesh Rao', role: StaffRole.gardener, phone: '+91 98765 43212', isOnDuty: false),
    StaffMember(id: 's-004', name: 'Suresh Babu', role: StaffRole.driver, phone: '+91 98765 43213', isOnDuty: true),
    StaffMember(id: 's-005', name: 'Priya Sharma', role: StaffRole.nanny, phone: '+91 98765 43214', isOnDuty: true),
    StaffMember(id: 's-006', name: 'Meena Kumari', role: StaffRole.manager, phone: '+91 98765 43215', isOnDuty: true),
  ];

  // ─── Pantry / Inventory ────────────────────────────────────
  static List<InventoryItem> get inventoryItems => [
    // Original items
    InventoryItem(id: 'inv-001', name: 'Basmati Rice', quantity: 5, unit: InventoryUnit.kg, reorderThreshold: 2, category: 'Grains'),
    InventoryItem(id: 'inv-002', name: 'Toor Dal', quantity: 1.5, unit: InventoryUnit.kg, reorderThreshold: 1, category: 'Pulses'),
    InventoryItem(id: 'inv-003', name: 'Whole Milk', quantity: 2, unit: InventoryUnit.l, reorderThreshold: 1, category: 'Dairy'),
    InventoryItem(id: 'inv-004', name: 'Onions', quantity: 3, unit: InventoryUnit.kg, reorderThreshold: 1, category: 'Vegetables'),
    InventoryItem(id: 'inv-005', name: 'Tomatoes', quantity: 2, unit: InventoryUnit.kg, reorderThreshold: 1, category: 'Vegetables'),
    InventoryItem(id: 'inv-006', name: 'Cooking Oil', quantity: 1.5, unit: InventoryUnit.l, reorderThreshold: 0.5, category: 'Oils'),
    InventoryItem(id: 'inv-007', name: 'Turmeric Powder', quantity: 0.3, unit: InventoryUnit.kg, reorderThreshold: 0.1, category: 'Spices'),
    InventoryItem(id: 'inv-008', name: 'Red Chilli Powder', quantity: 0.2, unit: InventoryUnit.kg, reorderThreshold: 0.1, category: 'Spices'),
    InventoryItem(id: 'inv-009', name: 'Cumin Seeds', quantity: 0.15, unit: InventoryUnit.kg, reorderThreshold: 0.05, category: 'Spices'),
    InventoryItem(id: 'inv-010', name: 'Ghee', quantity: 0.5, unit: InventoryUnit.kg, reorderThreshold: 0.25, category: 'Dairy'),
    InventoryItem(id: 'inv-011', name: 'Eggs', quantity: 12, unit: InventoryUnit.pieces, reorderThreshold: 6, category: 'Dairy'),
    InventoryItem(id: 'inv-012', name: 'Chicken', quantity: 1, unit: InventoryUnit.kg, reorderThreshold: 0.5, category: 'Meat'),
    InventoryItem(id: 'inv-013', name: 'Paneer', quantity: 0.5, unit: InventoryUnit.kg, reorderThreshold: 0.25, category: 'Dairy'),
    InventoryItem(id: 'inv-014', name: 'Green Chillies', quantity: 0.1, unit: InventoryUnit.kg, reorderThreshold: 0.05, category: 'Vegetables'),
    InventoryItem(id: 'inv-015', name: 'Ginger-Garlic Paste', quantity: 0.2, unit: InventoryUnit.kg, reorderThreshold: 0.1, category: 'Spices'),
    InventoryItem(id: 'inv-016', name: 'Atta (Wheat Flour)', quantity: 4, unit: InventoryUnit.kg, reorderThreshold: 2, category: 'Grains'),
    InventoryItem(id: 'inv-017', name: 'Sugar', quantity: 1, unit: InventoryUnit.kg, reorderThreshold: 0.5, category: 'General'),
    InventoryItem(id: 'inv-018', name: 'Tea Leaves', quantity: 0.25, unit: InventoryUnit.kg, reorderThreshold: 0.1, category: 'Beverages'),
    InventoryItem(id: 'inv-019', name: 'Salt', quantity: 0.8, unit: InventoryUnit.kg, reorderThreshold: 0.5, category: 'General'),
    InventoryItem(id: 'inv-020', name: 'Coriander Leaves', quantity: 0.05, unit: InventoryUnit.kg, reorderThreshold: 0.02, category: 'Vegetables'),
    // New items for expanded recipe database
    InventoryItem(id: 'inv-021', name: 'Potatoes', quantity: 3, unit: InventoryUnit.kg, reorderThreshold: 1, category: 'Vegetables'),
    InventoryItem(id: 'inv-022', name: 'Butter', quantity: 0.5, unit: InventoryUnit.kg, reorderThreshold: 0.2, category: 'Dairy'),
    InventoryItem(id: 'inv-023', name: 'Pav Buns', quantity: 8, unit: InventoryUnit.pieces, reorderThreshold: 4, category: 'Bakery'),
    InventoryItem(id: 'inv-024', name: 'Capsicum', quantity: 0.5, unit: InventoryUnit.kg, reorderThreshold: 0.2, category: 'Vegetables'),
    InventoryItem(id: 'inv-025', name: 'Cauliflower', quantity: 1, unit: InventoryUnit.kg, reorderThreshold: 0.5, category: 'Vegetables'),
    InventoryItem(id: 'inv-026', name: 'Chickpeas (Chana)', quantity: 1, unit: InventoryUnit.kg, reorderThreshold: 0.5, category: 'Pulses'),
    InventoryItem(id: 'inv-027', name: 'Garam Masala', quantity: 0.1, unit: InventoryUnit.kg, reorderThreshold: 0.03, category: 'Spices'),
    InventoryItem(id: 'inv-028', name: 'Pav Bhaji Masala', quantity: 0.1, unit: InventoryUnit.kg, reorderThreshold: 0.03, category: 'Spices'),
  ];

  // ─── Recipes (Expanded) ────────────────────────────────────
  static List<Recipe> get recipes => [
    // rec-001: Dal Tadka
    Recipe(
      id: 'rec-001',
      name: 'Dal Tadka',
      description: 'Classic tempered lentil curry',
      servings: 4,
      prepTimeMinutes: 40,
      ingredients: [
        RecipeIngredient(inventoryItemId: 'inv-002', name: 'Toor Dal', quantity: 0.5, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-005', name: 'Tomatoes', quantity: 0.3, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-004', name: 'Onions', quantity: 0.2, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-007', name: 'Turmeric Powder', quantity: 0.005, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-009', name: 'Cumin Seeds', quantity: 0.005, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-010', name: 'Ghee', quantity: 0.03, unit: InventoryUnit.kg),
      ],
      instructions: '1. Wash dal, pressure cook 4 whistles.\n2. Sauté cumin in ghee, add onions & tomatoes.\n3. Add turmeric & spices, mix with cooked dal.\n4. Simmer 10 min, garnish with coriander.',
    ),
    // rec-002: Chicken Biryani
    Recipe(
      id: 'rec-002',
      name: 'Chicken Biryani',
      description: 'Hyderabadi-style layered biryani',
      servings: 6,
      prepTimeMinutes: 90,
      ingredients: [
        RecipeIngredient(inventoryItemId: 'inv-001', name: 'Basmati Rice', quantity: 0.75, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-012', name: 'Chicken', quantity: 0.75, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-004', name: 'Onions', quantity: 0.5, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-015', name: 'Ginger-Garlic Paste', quantity: 0.05, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-006', name: 'Cooking Oil', quantity: 0.1, unit: InventoryUnit.l),
        RecipeIngredient(inventoryItemId: 'inv-010', name: 'Ghee', quantity: 0.05, unit: InventoryUnit.kg),
      ],
      instructions: '1. Marinate chicken with yoghurt & spices.\n2. Parboil rice with whole spices.\n3. Layer rice & chicken, dum cook 25 min.\n4. Serve with raita & mirchi ka salan.',
    ),
    // rec-003: Paneer Butter Masala
    Recipe(
      id: 'rec-003',
      name: 'Paneer Butter Masala',
      description: 'Rich tomato-cream paneer curry',
      servings: 4,
      prepTimeMinutes: 35,
      ingredients: [
        RecipeIngredient(inventoryItemId: 'inv-013', name: 'Paneer', quantity: 0.4, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-005', name: 'Tomatoes', quantity: 0.5, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-004', name: 'Onions', quantity: 0.2, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-006', name: 'Cooking Oil', quantity: 0.05, unit: InventoryUnit.l),
        RecipeIngredient(inventoryItemId: 'inv-010', name: 'Ghee', quantity: 0.03, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-008', name: 'Red Chilli Powder', quantity: 0.005, unit: InventoryUnit.kg),
      ],
      instructions: '1. Blend tomatoes & onions into paste.\n2. Sauté paste in butter, add spices.\n3. Add cream, simmer, add paneer cubes.\n4. Garnish with kasuri methi & cream.',
    ),
    // rec-004: Pav Bhaji (NEW — for 4 servings)
    Recipe(
      id: 'rec-004',
      name: 'Pav Bhaji',
      description: 'Mumbai-style spiced vegetable mash with buttered buns',
      servings: 4,
      prepTimeMinutes: 45,
      ingredients: [
        RecipeIngredient(inventoryItemId: 'inv-021', name: 'Potatoes', quantity: 0.5, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-005', name: 'Tomatoes', quantity: 0.4, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-004', name: 'Onions', quantity: 0.3, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-024', name: 'Capsicum', quantity: 0.15, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-022', name: 'Butter', quantity: 0.1, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-023', name: 'Pav Buns', quantity: 8, unit: InventoryUnit.pieces),
        RecipeIngredient(inventoryItemId: 'inv-028', name: 'Pav Bhaji Masala', quantity: 0.02, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-014', name: 'Green Chillies', quantity: 0.02, unit: InventoryUnit.kg),
      ],
      instructions: '1. Boil & mash potatoes.\n2. Sauté onions, tomatoes, capsicum in butter.\n3. Add mashed potatoes, pav bhaji masala, mix well.\n4. Mash everything together, simmer 10 min.\n5. Toast pav buns with butter, serve hot with bhaji.',
    ),
    // rec-005: Aloo Gobi
    Recipe(
      id: 'rec-005',
      name: 'Aloo Gobi',
      description: 'Dry potato-cauliflower curry with spices',
      servings: 4,
      prepTimeMinutes: 30,
      ingredients: [
        RecipeIngredient(inventoryItemId: 'inv-021', name: 'Potatoes', quantity: 0.3, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-025', name: 'Cauliflower', quantity: 0.4, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-004', name: 'Onions', quantity: 0.15, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-007', name: 'Turmeric Powder', quantity: 0.005, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-006', name: 'Cooking Oil', quantity: 0.05, unit: InventoryUnit.l),
        RecipeIngredient(inventoryItemId: 'inv-009', name: 'Cumin Seeds', quantity: 0.005, unit: InventoryUnit.kg),
      ],
      instructions: '1. Cut potatoes & cauliflower into florets.\n2. Heat oil, add cumin seeds.\n3. Add vegetables, turmeric, salt.\n4. Cover and cook on low flame 20 min.',
    ),
    // rec-006: Chole Bhature
    Recipe(
      id: 'rec-006',
      name: 'Chole Bhature',
      description: 'Spiced chickpea curry with fried bread',
      servings: 4,
      prepTimeMinutes: 60,
      ingredients: [
        RecipeIngredient(inventoryItemId: 'inv-026', name: 'Chickpeas', quantity: 0.4, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-004', name: 'Onions', quantity: 0.25, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-005', name: 'Tomatoes', quantity: 0.3, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-015', name: 'Ginger-Garlic Paste', quantity: 0.03, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-027', name: 'Garam Masala', quantity: 0.01, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-016', name: 'Atta', quantity: 0.3, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-006', name: 'Cooking Oil', quantity: 0.2, unit: InventoryUnit.l),
      ],
      instructions: '1. Soak chickpeas overnight, pressure cook.\n2. Prepare chole masala with onion-tomato base.\n3. Knead bhature dough with yoghurt.\n4. Deep fry bhature, serve with chole.',
    ),
    // rec-007: Egg Curry
    Recipe(
      id: 'rec-007',
      name: 'Egg Curry',
      description: 'Boiled eggs in spiced onion-tomato gravy',
      servings: 4,
      prepTimeMinutes: 25,
      ingredients: [
        RecipeIngredient(inventoryItemId: 'inv-011', name: 'Eggs', quantity: 6, unit: InventoryUnit.pieces),
        RecipeIngredient(inventoryItemId: 'inv-004', name: 'Onions', quantity: 0.2, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-005', name: 'Tomatoes', quantity: 0.3, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-007', name: 'Turmeric Powder', quantity: 0.005, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-008', name: 'Red Chilli Powder', quantity: 0.005, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-006', name: 'Cooking Oil', quantity: 0.05, unit: InventoryUnit.l),
      ],
      instructions: '1. Boil eggs, peel and halve.\n2. Sauté onions golden, add tomatoes.\n3. Add spices, cook gravy 10 min.\n4. Add eggs, simmer 5 min.',
    ),
    // rec-008: Masala Chai
    Recipe(
      id: 'rec-008',
      name: 'Masala Chai',
      description: 'Spiced Indian tea with milk',
      servings: 4,
      prepTimeMinutes: 10,
      ingredients: [
        RecipeIngredient(inventoryItemId: 'inv-018', name: 'Tea Leaves', quantity: 0.02, unit: InventoryUnit.kg),
        RecipeIngredient(inventoryItemId: 'inv-003', name: 'Whole Milk', quantity: 0.5, unit: InventoryUnit.l),
        RecipeIngredient(inventoryItemId: 'inv-017', name: 'Sugar', quantity: 0.04, unit: InventoryUnit.kg),
      ],
      instructions: '1. Boil water with tea leaves.\n2. Add milk, sugar.\n3. Boil and strain. Serve hot.',
    ),
  ];

  // ─── Daily Routine Tasks ───────────────────────────────────
  static List<HouseholdTask> get dailyTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return [
      HouseholdTask(
        id: 't-001', title: 'Prepare breakfast – Idli & Chutney',
        description: 'Make fresh idli batter if needed, serve with coconut chutney and sambar',
        priority: TaskPriority.high, status: TaskStatus.completed,
        category: TaskCategory.cooking, assignedTo: 's-001',
        createdAt: today.add(const Duration(hours: 5, minutes: 30)),
        dueAt: today.add(const Duration(hours: 7, minutes: 30)),
        completedAt: today.add(const Duration(hours: 7, minutes: 15)),
      ),
      HouseholdTask(
        id: 't-002', title: 'Clean living room & dining area',
        description: 'Vacuum carpets, dust shelves, mop floors, arrange cushions',
        priority: TaskPriority.medium, status: TaskStatus.inProgress,
        category: TaskCategory.cleaning, assignedTo: 's-002',
        createdAt: today.add(const Duration(hours: 8)),
        dueAt: today.add(const Duration(hours: 10)),
      ),
      HouseholdTask(
        id: 't-003', title: 'Cook lunch – Dal Tadka + Rice',
        description: 'Prepare dal tadka with jeera rice for 6 people',
        priority: TaskPriority.high, status: TaskStatus.pending,
        category: TaskCategory.cooking, assignedTo: 's-001',
        createdAt: today.add(const Duration(hours: 9)),
        dueAt: today.add(const Duration(hours: 12, minutes: 30)),
        linkedRecipeId: 'rec-001',
      ),
      HouseholdTask(
        id: 't-004', title: 'Water garden & trim hedges',
        description: 'Morning watering cycle, check drip irrigation, trim rose bushes',
        priority: TaskPriority.low, status: TaskStatus.pending,
        category: TaskCategory.gardening, assignedTo: 's-003',
        createdAt: today.add(const Duration(hours: 6)),
        dueAt: today.add(const Duration(hours: 8)),
      ),
      HouseholdTask(
        id: 't-005', title: 'School pickup – 3:30 PM',
        description: 'Pick up kids from DPS school, drop at home',
        priority: TaskPriority.urgent, status: TaskStatus.pending,
        category: TaskCategory.other, assignedTo: 's-004',
        createdAt: today.add(const Duration(hours: 14)),
        dueAt: today.add(const Duration(hours: 15, minutes: 30)),
      ),
      HouseholdTask(
        id: 't-006', title: 'Weekly laundry – bedsheets & curtains',
        description: 'Wash all bedroom sheets and living room curtains',
        priority: TaskPriority.medium, status: TaskStatus.pending,
        category: TaskCategory.laundry, assignedTo: 's-002',
        createdAt: today.add(const Duration(hours: 10)),
        dueAt: today.add(const Duration(hours: 16)),
        isRecurring: true, recurrenceRule: 'WEEKLY',
      ),
      HouseholdTask(
        id: 't-007', title: 'Evening snacks – Tea & pakoras',
        description: 'Prepare masala chai and onion pakoras for evening',
        priority: TaskPriority.medium, status: TaskStatus.pending,
        category: TaskCategory.cooking, assignedTo: 's-001',
        createdAt: today.add(const Duration(hours: 15)),
        dueAt: today.add(const Duration(hours: 17)),
        linkedRecipeId: 'rec-008',
      ),
      HouseholdTask(
        id: 't-008', title: 'Prepare dinner – Chicken Biryani',
        description: 'Hyderabadi dum biryani for family dinner + guests',
        priority: TaskPriority.high, status: TaskStatus.pending,
        category: TaskCategory.cooking, assignedTo: 's-001',
        createdAt: today.add(const Duration(hours: 16)),
        dueAt: today.add(const Duration(hours: 20)),
        linkedRecipeId: 'rec-002',
      ),
      HouseholdTask(
        id: 't-009', title: 'Grocery restock – vegetables & dairy',
        description: 'Buy tomatoes, onions, milk, curd from local market',
        priority: TaskPriority.high, status: TaskStatus.overdue,
        category: TaskCategory.shopping, assignedTo: 's-006',
        createdAt: today.subtract(const Duration(days: 1)),
        dueAt: today.add(const Duration(hours: 10)),
      ),
      HouseholdTask(
        id: 't-010', title: 'Check AC filter & water purifier',
        description: 'Monthly maintenance check on all AC units and RO purifier',
        priority: TaskPriority.low, status: TaskStatus.pending,
        category: TaskCategory.maintenance, assignedTo: 's-006',
        createdAt: today,
        dueAt: today.add(const Duration(days: 2)),
        isRecurring: true, recurrenceRule: 'MONTHLY',
      ),
    ];
  }

  // ─── Wallet Data ───────────────────────────────────────────
  static double get defaultWalletBalance => 45000.0;

  static List<WalletTransaction> get walletTransactions {
    final today = DateTime.now();
    return [
      WalletTransaction(id: 'wt-001', title: 'Salary - Lakshmi Devi', amount: 12000, category: 'Salary', date: today.subtract(const Duration(days: 2))),
      WalletTransaction(id: 'wt-002', title: 'Blinkit Groceries', amount: 1540, category: 'Grocery', date: today.subtract(const Duration(days: 3))),
      WalletTransaction(id: 'wt-003', title: 'Salary - Ramu Kumar', amount: 8000, category: 'Salary', date: today.subtract(const Duration(days: 4))),
      WalletTransaction(id: 'wt-004', title: 'Electricity Bill', amount: 4300, category: 'Maintenance', date: today.subtract(const Duration(days: 5))),
      WalletTransaction(id: 'wt-005', title: 'Fund Added', amount: 50000, category: 'Top-up', date: today.subtract(const Duration(days: 6)), isDeduction: false),
    ];
  }
}
