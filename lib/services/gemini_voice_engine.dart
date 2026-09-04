// ─── Gemini Regional Voice AI Engine ─────────────────────────────
// Simulates Gemini API NLU for Hindi/regional voice input parsing.
// In production: calls Gemini 2.0 Flash with a structured JSON schema prompt.
// In sandbox: uses a comprehensive local Hindi→English lexicon + pattern matcher.

import 'dart:convert';

/// Structured output from the Gemini Voice AI Engine.
class GeminiVoiceResult {
  final String taskTitle;         // English title for Admin
  final String originalTranscript; // Raw Hindi/English input
  final String category;          // cooking, cleaning, shopping, maintenance, etc.
  final String priority;          // low, medium, high, urgent
  final String? linkedRecipeId;   // If the command matches a known recipe
  final String? linkedRecipeName; // Human-readable recipe name
  final List<String> urgentAlerts; // Items detected as out-of-stock
  final List<InventoryMention> inventoryMentions; // Items referenced
  final double confidence;        // 0.0–1.0 simulated confidence

  GeminiVoiceResult({
    required this.taskTitle,
    required this.originalTranscript,
    required this.category,
    this.priority = 'medium',
    this.linkedRecipeId,
    this.linkedRecipeName,
    this.urgentAlerts = const [],
    this.inventoryMentions = const [],
    this.confidence = 0.85,
  });

  Map<String, dynamic> toJson() => {
    'task_title': taskTitle,
    'original_transcript': originalTranscript,
    'category': category,
    'priority': priority,
    'linked_recipe_id': linkedRecipeId,
    'linked_recipe_name': linkedRecipeName,
    'urgent_alerts': urgentAlerts,
    'inventory_mentions': inventoryMentions.map((m) => m.toJson()).toList(),
    'confidence': confidence,
  };

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

/// An inventory item mentioned in a voice command.
class InventoryMention {
  final String itemName;
  final String? inventoryId;
  final double? quantity;
  final String? unit;
  final bool isOutOfStock;

  InventoryMention({
    required this.itemName,
    this.inventoryId,
    this.quantity,
    this.unit,
    this.isOutOfStock = false,
  });

  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'inventory_id': inventoryId,
    'quantity': quantity,
    'unit': unit,
    'is_out_of_stock': isOutOfStock,
  };
}

/// The Gemini Regional Voice AI Engine.
/// Processes Hindi/Hinglish/English voice transcripts and extracts
/// structured task data with recipe linkage and inventory alerts.
class GeminiVoiceEngine {
  // ─── Hindi → English Translation Lexicon ───────────────────
  static const Map<String, String> _hindiToEnglish = {
    // Vegetables
    'tamatar': 'tomatoes', 'aloo': 'potatoes', 'pyaaz': 'onions', 'pyaz': 'onions',
    'shimla mirch': 'capsicum', 'mirch': 'chillies', 'hari mirch': 'green chillies',
    'lal mirch': 'red chilli powder', 'adrak': 'ginger', 'lehsun': 'garlic',
    'dhaniya': 'coriander leaves', 'palak': 'spinach', 'gobi': 'cauliflower',
    'matar': 'peas', 'bhindi': 'okra', 'baingan': 'brinjal',
    // Dairy
    'doodh': 'milk', 'dudh': 'milk', 'ghee': 'ghee', 'makhan': 'butter',
    'paneer': 'paneer', 'dahi': 'curd', 'anda': 'eggs', 'ande': 'eggs',
    // Grains
    'chawal': 'rice', 'atta': 'wheat flour', 'maida': 'refined flour',
    'dal': 'dal', 'daal': 'dal', 'chana': 'chickpeas', 'rajma': 'kidney beans',
    // Spices
    'haldi': 'turmeric powder', 'jeera': 'cumin seeds', 'namak': 'salt',
    'cheeni': 'sugar', 'shakkar': 'sugar', 'garam masala': 'garam masala',
    'pav bhaji masala': 'pav bhaji masala',
    // Oils
    'tel': 'cooking oil', 'sarson ka tel': 'mustard oil',
    // Other
    'pav': 'pav buns', 'roti': 'roti', 'chai': 'tea', 'pani': 'water',
    'sabzi': 'vegetables', 'meat': 'chicken', 'murga': 'chicken', 'murg': 'chicken',
    'machli': 'fish', 'gosht': 'meat',
  };

  // ─── Hindi Action Verbs → Categories ───────────────────────
  static const Map<String, String> _hindiActionCategories = {
    // Cooking
    'banana': 'cooking', 'banao': 'cooking', 'pakao': 'cooking', 'pakana': 'cooking',
    'cook': 'cooking', 'prepare': 'cooking', 'make': 'cooking', 'bake': 'cooking',
    // Cleaning
    'saaf': 'cleaning', 'safai': 'cleaning', 'dhona': 'cleaning', 'dho': 'cleaning',
    'pochha': 'cleaning', 'jhadu': 'cleaning', 'clean': 'cleaning', 'wash': 'cleaning',
    'mop': 'cleaning', 'sweep': 'cleaning',
    // Shopping
    'kharid': 'shopping', 'kharido': 'shopping', 'lao': 'shopping', 'lana': 'shopping',
    'mangao': 'shopping', 'mangwao': 'shopping', 'buy': 'shopping', 'shop': 'shopping',
    'order': 'shopping', 'restock': 'shopping',
    // Maintenance
    'theek': 'maintenance', 'repair': 'maintenance', 'fix': 'maintenance',
    'check': 'maintenance', 'dekho': 'maintenance', 'dekhna': 'maintenance',
    // Gardening
    'paani do': 'gardening', 'water': 'gardening', 'garden': 'gardening',
    // Laundry
    'kapde': 'laundry', 'istri': 'laundry', 'dhulai': 'laundry', 'iron': 'laundry',
    'laundry': 'laundry',
  };

  // ─── Recipe Name Patterns (Hindi → recipe ID) ──────────────
  static const Map<String, _RecipeMatch> _recipePatterns = {
    'pav bhaji': _RecipeMatch('rec-004', 'Pav Bhaji'),
    'dal tadka': _RecipeMatch('rec-001', 'Dal Tadka'),
    'dal': _RecipeMatch('rec-001', 'Dal Tadka'),
    'daal': _RecipeMatch('rec-001', 'Dal Tadka'),
    'biryani': _RecipeMatch('rec-002', 'Chicken Biryani'),
    'chicken biryani': _RecipeMatch('rec-002', 'Chicken Biryani'),
    'paneer butter masala': _RecipeMatch('rec-003', 'Paneer Butter Masala'),
    'paneer masala': _RecipeMatch('rec-003', 'Paneer Butter Masala'),
    'aloo gobi': _RecipeMatch('rec-005', 'Aloo Gobi'),
    'chole bhature': _RecipeMatch('rec-006', 'Chole Bhature'),
    'chole': _RecipeMatch('rec-006', 'Chole Bhature'),
    'egg curry': _RecipeMatch('rec-007', 'Egg Curry'),
    'anda curry': _RecipeMatch('rec-007', 'Egg Curry'),
    'chai': _RecipeMatch('rec-008', 'Masala Chai'),
    'masala chai': _RecipeMatch('rec-008', 'Masala Chai'),
  };

  // ─── Inventory Name → ID Mapping ───────────────────────────
  static const Map<String, String> _inventoryNameToId = {
    'basmati rice': 'inv-001', 'rice': 'inv-001',
    'toor dal': 'inv-002', 'dal': 'inv-002',
    'whole milk': 'inv-003', 'milk': 'inv-003', 'doodh': 'inv-003',
    'onions': 'inv-004', 'onion': 'inv-004',
    'tomatoes': 'inv-005', 'tomato': 'inv-005',
    'cooking oil': 'inv-006', 'oil': 'inv-006',
    'turmeric powder': 'inv-007', 'turmeric': 'inv-007',
    'red chilli powder': 'inv-008',
    'cumin seeds': 'inv-009', 'cumin': 'inv-009',
    'ghee': 'inv-010',
    'eggs': 'inv-011', 'egg': 'inv-011',
    'chicken': 'inv-012',
    'paneer': 'inv-013',
    'green chillies': 'inv-014', 'chillies': 'inv-014',
    'ginger-garlic paste': 'inv-015', 'ginger garlic': 'inv-015',
    'atta': 'inv-016', 'wheat flour': 'inv-016',
    'sugar': 'inv-017',
    'tea leaves': 'inv-018', 'tea': 'inv-018',
    'salt': 'inv-019',
    'coriander leaves': 'inv-020', 'coriander': 'inv-020',
    'potatoes': 'inv-021', 'potato': 'inv-021',
    'butter': 'inv-022',
    'pav buns': 'inv-023', 'pav': 'inv-023',
    'capsicum': 'inv-024',
    'cauliflower': 'inv-025',
    'chickpeas': 'inv-026',
  };

  // ─── Priority Keywords ─────────────────────────────────────
  static const Map<String, String> _priorityKeywords = {
    // Hindi urgency
    'jaldi': 'urgent', 'abhi': 'urgent', 'turant': 'urgent', 'fauran': 'urgent',
    'khatam': 'urgent', 'khtm': 'urgent', 'nahi hai': 'urgent', 'nhi hai': 'urgent',
    // English urgency
    'urgent': 'urgent', 'immediately': 'urgent', 'asap': 'urgent', 'now': 'urgent',
    'right away': 'urgent', 'emergency': 'urgent',
    // High
    'zaruri': 'high', 'zaroori': 'high', 'important': 'high', 'must': 'high',
    'before': 'high', 'pehle': 'high',
  };

  // ─── Out-of-stock indicator phrases ────────────────────────
  static const List<String> _outOfStockPhrases = [
    'khatam', 'khtm', 'nahi hai', 'nhi hai', 'nahi raha', 'nahi bach',
    'finished', 'out of stock', 'empty', 'ran out', 'over ho gaya',
    'khatm ho gaye', 'khatam ho gaye', 'nahi bacha',
  ];

  /// Parse a voice transcript (Hindi/Hinglish/English) into structured data.
  GeminiVoiceResult parse(String transcript, {Map<String, double>? currentStock}) {
    final lower = transcript.toLowerCase().trim();

    // 1. Detect category from action verbs
    String category = _detectCategory(lower);

    // 2. Detect priority
    String priority = _detectPriority(lower);

    // 3. Detect recipe linkage
    String? recipeId;
    String? recipeName;
    for (final entry in _recipePatterns.entries) {
      if (lower.contains(entry.key)) {
        recipeId = entry.value.id;
        recipeName = entry.value.name;
        if (category == 'other') category = 'cooking';
        break;
      }
    }

    // 4. Detect inventory mentions
    final mentions = _detectInventoryMentions(lower, currentStock);

    // 5. Detect urgent alerts (out-of-stock phrases)
    final urgentAlerts = <String>[];
    final hasOutOfStock = _outOfStockPhrases.any((p) => lower.contains(p));
    if (hasOutOfStock) {
      priority = 'urgent';
      // Find which items are mentioned as out of stock
      for (final mention in mentions) {
        if (mention.isOutOfStock || hasOutOfStock) {
          urgentAlerts.add('${mention.itemName} is out of stock!');
        }
      }
      if (urgentAlerts.isEmpty && mentions.isEmpty) {
        urgentAlerts.add('Stock alert detected from voice command');
      }
      if (category == 'other') category = 'shopping';
    }

    // 6. Generate English task title
    final taskTitle = _generateEnglishTitle(lower, recipeName, mentions, hasOutOfStock);

    // 7. Confidence scoring
    double confidence = 0.7;
    if (recipeId != null) confidence += 0.15;
    if (category != 'other') confidence += 0.1;
    if (mentions.isNotEmpty) confidence += 0.05;

    return GeminiVoiceResult(
      taskTitle: taskTitle,
      originalTranscript: transcript,
      category: category,
      priority: priority,
      linkedRecipeId: recipeId,
      linkedRecipeName: recipeName,
      urgentAlerts: urgentAlerts,
      inventoryMentions: mentions,
      confidence: confidence.clamp(0.0, 1.0),
    );
  }

  // ─── Internal Helpers ──────────────────────────────────────

  String _detectCategory(String lower) {
    for (final entry in _hindiActionCategories.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'other';
  }

  String _detectPriority(String lower) {
    for (final entry in _priorityKeywords.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return 'medium';
  }

  List<InventoryMention> _detectInventoryMentions(String lower, Map<String, double>? stock) {
    final mentions = <InventoryMention>[];
    final seen = <String>{};

    // Check Hindi terms first
    for (final entry in _hindiToEnglish.entries) {
      if (lower.contains(entry.key) && !seen.contains(entry.value)) {
        seen.add(entry.value);
        final invId = _inventoryNameToId[entry.value];
        final isOos = stock != null && invId != null && (stock[invId] ?? 0) <= 0;
        mentions.add(InventoryMention(
          itemName: entry.value,
          inventoryId: invId,
          isOutOfStock: isOos,
        ));
      }
    }

    // Check English names
    for (final entry in _inventoryNameToId.entries) {
      if (lower.contains(entry.key) && !seen.contains(entry.key)) {
        seen.add(entry.key);
        final isOos = stock != null && (stock[entry.value] ?? 0) <= 0;
        mentions.add(InventoryMention(
          itemName: entry.key,
          inventoryId: entry.value,
          isOutOfStock: isOos,
        ));
      }
    }

    // Extract quantities (basic pattern: digit + unit hint)
    final qtyPattern = RegExp(r'(\d+(?:\.\d+)?)\s*(kg|g|litre|liter|l|ml|piece|packet|dozen|cup|kilo)', caseSensitive: false);
    for (final match in qtyPattern.allMatches(lower)) {
      final qty = double.tryParse(match.group(1)!);
      final unit = match.group(2)!.toLowerCase();
      if (qty != null && mentions.isNotEmpty) {
        // Assign to the closest unset mention
        for (int i = 0; i < mentions.length; i++) {
          if (mentions[i].quantity == null) {
            mentions[i] = InventoryMention(
              itemName: mentions[i].itemName,
              inventoryId: mentions[i].inventoryId,
              quantity: qty,
              unit: unit,
              isOutOfStock: mentions[i].isOutOfStock,
            );
            break;
          }
        }
      }
    }

    return mentions;
  }

  String _generateEnglishTitle(String lower, String? recipeName, List<InventoryMention> mentions, bool isOos) {
    // If recipe detected, generate recipe-based title
    if (recipeName != null) {
      // Try to extract time context
      String timeContext = '';
      if (lower.contains('sham') || lower.contains('evening') || lower.contains('shaam')) {
        timeContext = ' for evening';
      } else if (lower.contains('dopahar') || lower.contains('lunch')) {
        timeContext = ' for lunch';
      } else if (lower.contains('raat') || lower.contains('dinner') || lower.contains('night')) {
        timeContext = ' for dinner';
      } else if (lower.contains('subah') || lower.contains('morning') || lower.contains('breakfast')) {
        timeContext = ' for breakfast';
      }
      return 'Prepare $recipeName$timeContext';
    }

    // If out-of-stock alert
    if (isOos && mentions.isNotEmpty) {
      final itemNames = mentions.map((m) => m.itemName).take(3).join(', ');
      return 'Restock urgently: $itemNames';
    }

    // Try to translate Hindi words to build an English title
    String translated = lower;
    for (final entry in _hindiToEnglish.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }
    // Clean up common Hindi connectors
    translated = translated
        .replaceAll(RegExp(r'\b(hai|hain|ho|gaye|gaya|ko|ka|ki|ke|mein|se|aur|bhi|aaj|kal)\b'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Capitalize first letter
    if (translated.isNotEmpty) {
      translated = translated[0].toUpperCase() + translated.substring(1);
    }

    return translated.isEmpty ? lower : translated;
  }
}

class _RecipeMatch {
  final String id;
  final String name;
  const _RecipeMatch(this.id, this.name);
}
