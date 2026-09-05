import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baai/models/models.dart';
import 'package:baai/providers/app_state.dart';
import 'package:baai/services/voice_service.dart';
import 'package:baai/services/gemini_voice_engine.dart';
import 'package:baai/theme/app_theme.dart';
import 'package:baai/widgets/widgets.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  late TabController _tabController;

  // Smooth animated tab transition controller
  late AnimationController _tabAnimController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabAnimController = AnimationController(vsync: this, duration: BaaiTheme.mediumAnim);
    _tabAnimController.forward();

    _voiceService.updateStockLevels(context.read<AppState>().currentStockLevels);
    _voiceService.onResult.listen(_handleVoiceResult);
    _voiceService.onListeningChange.listen((listening) {
      if (!mounted) return;
      context.read<AppState>().setRecording(listening);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabAnimController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _handleVoiceResult(GeminiVoiceResult result) {
    final appState = context.read<AppState>();
    
    // Auto-create task
    final task = HouseholdTask(
      id: appState.generateTaskId(),
      title: result.taskTitle,
      category: TaskCategory.values.firstWhere((c) => c.name == result.category, orElse: () => TaskCategory.other),
      priority: TaskPriority.values.firstWhere((p) => p.name == result.priority, orElse: () => TaskPriority.medium),
      voiceNoteText: result.originalTranscript,
      linkedRecipeId: result.linkedRecipeId,
    );
    appState.addTask(task);
    
    appState.addAlert(BaaiAlert(
      id: appState.generateAlertId(),
      type: AlertType.voiceCommand,
      title: 'Voice Task Created',
      message: 'Created: "${task.title}" from voice command.',
    ));
    
    // Add urgent alerts if any from voice parsing
    for (final alertMsg in result.urgentAlerts) {
      appState.addAlert(BaaiAlert(
        id: appState.generateAlertId(),
        type: AlertType.lowStock,
        title: 'Voice Engine Alert',
        message: alertMsg,
      ));
    }
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ Task created: ${task.title}'),
      backgroundColor: BaaiTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _switchTab(int index) {
    if (_currentTabIndex == index) return;
    _tabAnimController.reset();
    setState(() => _currentTabIndex = index);
    context.read<AppState>().setNavIndex(index);
    _tabAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: _buildTopBar(state),
        ),
        body: AnimatedBuilder(
          animation: _tabAnimController,
          builder: (context, child) {
            final slideIn = Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: _tabAnimController, curve: BaaiTheme.defaultCurve));
            final fadeIn = CurvedAnimation(parent: _tabAnimController, curve: Curves.easeOut);
            return SlideTransition(
              position: slideIn,
              child: FadeTransition(opacity: fadeIn, child: child),
            );
          },
          child: _buildTabContent(state),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: _switchTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Staff'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Pantry'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          ],
        ),
        floatingActionButton: PulsingMicButton(
          isRecording: state.isRecording,
          onTap: () {
            if (state.isRecording) { _voiceService.stopListening(); }
            else { _voiceService.startListening(); }
          },
        ),
      );
    });
  }

  Widget _buildTabContent(AppState state) {
    switch (_currentTabIndex) {
      case 0: return _buildOverview(state);
      case 1: return _buildStaffView(state);
      case 2: return _buildPantry(state);
      case 3: return _buildWallet(state);
      default: return _buildOverview(state);
    }
  }

  // ─── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar(AppState state) {
    return SafeArea(
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: BaaiTheme.surface,
          border: Border(bottom: BorderSide(color: BaaiTheme.divider.withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: BaaiTheme.primary.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: BaaiTheme.primaryDark),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Project Baai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BaaiTheme.primaryDark)),
                const Text('Hello, Mr. Sharma.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
              ],
            ),
            const Spacer(),
            if (state.isRecording)
              AnimatedContainer(
                duration: BaaiTheme.fastAnim,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: BaaiTheme.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    _PulsingDot(color: BaaiTheme.error),
                    const SizedBox(width: 8),
                    const Text('Recording...', style: TextStyle(color: BaaiTheme.error, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            const SizedBox(width: 12),
            // Alert badge
            Stack(
              children: [
                IconButton(icon: const Icon(Icons.notifications_outlined, color: BaaiTheme.textPrimary), onPressed: () {}),
                if (state.unreadAlertCount > 0)
                  Positioned(right: 6, top: 6, child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: BaaiTheme.error, shape: BoxShape.circle),
                    child: Text('${state.unreadAlertCount}', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700)),
                  )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Overview Tab ──────────────────────────────────────────
  Widget _buildOverview(AppState state) {
    return SingleChildScrollView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Assign Today's Menu" Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BaaiTheme.glassCard,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Assign Today's Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BaaiTheme.primary,
                          foregroundColor: BaaiTheme.textPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('View Staff Schedules', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.restaurant_menu, size: 60, color: BaaiTheme.primaryDark),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // "Today's Routine" Module
          const Text("Today's Routine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
          const SizedBox(height: 12),
          ...state.tasks.take(4).map((t) => TaskCard(task: t)),
          
          const SizedBox(height: 24),
          // "Pantry Stock" Module
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Pantry Stock", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
              if (state.lowStockItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: BaaiTheme.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: BaaiTheme.error),
                      const SizedBox(width: 4),
                      Text('${state.lowStockItems.length} Low Stock', style: const TextStyle(fontSize: 12, color: BaaiTheme.error, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.inventory.take(3).length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedInventoryTile(item: state.inventory[i]),
            ),
          ),
          
          const SizedBox(height: 24),
          // "Staff Overview" Module
          const Text("Staff Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BaaiTheme.glassCard,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: state.staff.take(4).map((s) => Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: BaaiTheme.surfaceLight,
                        child: Icon(s.roleIcon, color: BaaiTheme.primaryDark, size: 28),
                      ),
                      if (s.isOnDuty)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: BaaiTheme.success, shape: BoxShape.circle),
                            child: const Icon(Icons.check, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary)),
                  Text(s.roleLabel, style: const TextStyle(fontSize: 10, color: BaaiTheme.textSecondary)),
                ],
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Staff Tab ─────────────────────────────────────────────
  Widget _buildStaffView(AppState state) {
    return ListView.builder(
      key: const ValueKey('staff'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: state.staff.length,
      itemBuilder: (_, i) {
        final s = state.staff[i];
        final taskCount = state.tasks.where((t) => t.assignedTo == s.id && t.status != TaskStatus.completed).length;
        return AnimatedContainer(
          duration: BaaiTheme.mediumAnim,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BaaiTheme.glassCard,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: BaaiTheme.surfaceLight,
                child: Icon(s.roleIcon, color: BaaiTheme.primaryDark, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(s.roleLabel, style: const TextStyle(fontSize: 12, color: BaaiTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: s.isOnDuty ? BaaiTheme.primary.withValues(alpha: 0.2) : BaaiTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(s.isOnDuty ? 'Present' : 'Absent', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: s.isOnDuty ? BaaiTheme.primaryDark : BaaiTheme.error)),
                        ),
                        const SizedBox(width: 12),
                        Text('$taskCount active tasks', style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => state.toggleStaffDuty(s.id),
                icon: Icon(s.isOnDuty ? Icons.logout : Icons.login, color: BaaiTheme.textSecondary),
                tooltip: 'Toggle Attendance',
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Pantry Tab ────────────────────────────────────────────
  Widget _buildPantry(AppState state) {
    final categories = state.inventory.map((i) => i.category).toSet().toList()..sort();
    final lowStockItems = state.lowStockItems;

    return SingleChildScrollView(
      key: const ValueKey('pantry'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Smart Pantry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
          const SizedBox(height: 16),
          
          if (lowStockItems.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BaaiTheme.error.withValues(alpha: 0.05),
                border: Border.all(color: BaaiTheme.error.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: BaaiTheme.error),
                      const SizedBox(width: 8),
                      Text('Low Stock Warning (${lowStockItems.length})', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: BaaiTheme.error)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...lowStockItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.name, style: const TextStyle(fontSize: 13, color: BaaiTheme.textPrimary)),
                        ElevatedButton(
                          onPressed: () {}, // 1-tap reorder
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BaaiTheme.primary,
                            foregroundColor: BaaiTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            minimumSize: const Size(60, 28),
                            elevation: 0,
                          ),
                          child: const Text('Reorder', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Recipes section
          const Text('Recipes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary)),
          const SizedBox(height: 10),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.recipes.length,
              itemBuilder: (_, i) {
                final r = state.recipes[i];
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BaaiTheme.glassCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text(r.description, style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 14, color: BaaiTheme.accent),
                          const SizedBox(width: 4),
                          Text('${r.prepTimeMinutes} min', style: const TextStyle(fontSize: 11, color: BaaiTheme.accent)),
                          const Spacer(),
                          Text('${r.ingredients.length} items', style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Inventory by category (List instead of Grid for mobile)
          ...categories.map((cat) {
            final items = state.inventory.where((i) => i.category == cat).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 8),
                  child: Text(cat, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedInventoryTile(item: items[i]),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Wallet Tab ─────────────────────────────────────────────
  Widget _buildWallet(AppState state) {
    return SingleChildScrollView(
      key: const ValueKey('wallet'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Overview Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [BaaiTheme.primary.withValues(alpha: 0.9), BaaiTheme.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: BaaiTheme.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Household Balance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary)),
                const SizedBox(height: 8),
                Text('₹${state.walletBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: BaaiTheme.textPrimary)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly Expense: ₹27,840', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: BaaiTheme.textPrimary)),
                    Icon(Icons.trending_up, size: 16, color: BaaiTheme.error.withValues(alpha: 0.8)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
          const SizedBox(height: 16),
          
          ...state.transactions.map((tx) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BaaiTheme.glassCard,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BaaiTheme.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    tx.isDeduction ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 18,
                    color: tx.isDeduction ? BaaiTheme.error : BaaiTheme.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text(tx.category, style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  '${tx.isDeduction ? '-' : '+'}₹${tx.amount.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: tx.isDeduction ? BaaiTheme.textPrimary : BaaiTheme.success),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Pulsing Recording Dot ────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.5 + _ctrl.value * 0.5),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: widget.color.withValues(alpha: 0.3 * _ctrl.value), blurRadius: 6)],
          ),
        );
      },
    );
  }
}

// ─── Pulsing Low-Stock Banner ─────────────────────────────────
class _PulsingLowStockBanner extends StatefulWidget {
  final int count;
  const _PulsingLowStockBanner({required this.count});
  @override State<_PulsingLowStockBanner> createState() => _PulsingLowStockBannerState();
}

class _PulsingLowStockBannerState extends State<_PulsingLowStockBanner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final opacity = 0.7 + _ctrl.value * 0.3;
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: BaaiTheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BaaiTheme.error.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: BaaiTheme.error.withValues(alpha: 0.1), blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: BaaiTheme.error),
            const SizedBox(width: 6),
            Text('${widget.count} Low Stock', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: BaaiTheme.error)),
          ],
        ),
      ),
    );
  }
}
