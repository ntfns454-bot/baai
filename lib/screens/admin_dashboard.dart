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
        body: Row(
          children: [
            // ─── Side Navigation ──────────────────────
            _buildSideNav(state),
            // ─── Main Content ─────────────────────────
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(state),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _tabAnimController,
                      builder: (context, child) {
                        final slideIn = Tween<Offset>(
                          begin: const Offset(0.03, 0),
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
                  ),
                ],
              ),
            ),
            // ─── Right Panel (Alerts) ─────────────────
            _buildAlertPanel(state),
          ],
        ),
      );
    });
  }

  Widget _buildTabContent(AppState state) {
    switch (_currentTabIndex) {
      case 0: return _buildOverview(state);
      case 1: return _buildTaskList(state);
      case 2: return _buildPantry(state);
      case 3: return _buildStaffView(state);
      default: return _buildOverview(state);
    }
  }

  // ─── Side Navigation ──────────────────────────────────────
  Widget _buildSideNav(AppState state) {
    final items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Overview'},
      {'icon': Icons.task_alt, 'label': 'Tasks'},
      {'icon': Icons.inventory_2, 'label': 'Pantry'},
      {'icon': Icons.people_alt, 'label': 'Staff'},
    ];

    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: BaaiTheme.surface,
        border: Border(right: BorderSide(color: BaaiTheme.divider.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(gradient: BaaiTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('B', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white))),
          ),
          const SizedBox(height: 24),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isActive = _currentTabIndex == idx;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Tooltip(
                message: item['label'] as String,
                child: InkWell(
                  onTap: () => _switchTab(idx),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: BaaiTheme.fastAnim,
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isActive ? BaaiTheme.primary.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isActive ? Border.all(color: BaaiTheme.primary.withOpacity(0.4)) : null,
                    ),
                    child: Icon(item['icon'] as IconData, color: isActive ? BaaiTheme.primary : BaaiTheme.textSecondary, size: 24),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          // Mic button
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: PulsingMicButton(
              isRecording: state.isRecording,
              onTap: () {
                if (state.isRecording) { _voiceService.stopListening(); }
                else { _voiceService.startListening(); }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar(AppState state) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: BaaiTheme.surface,
        border: Border(bottom: BorderSide(color: BaaiTheme.divider.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.household.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
              Text('Admin Workspace • ${_greeting()}', style: const TextStyle(fontSize: 12, color: BaaiTheme.textSecondary)),
            ],
          ),
          const Spacer(),
          if (state.isRecording)
            AnimatedContainer(
              duration: BaaiTheme.fastAnim,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: BaaiTheme.error.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
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
              IconButton(icon: const Icon(Icons.notifications_outlined, color: BaaiTheme.textSecondary), onPressed: () {}),
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
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ─── Overview Tab ──────────────────────────────────────────
  Widget _buildOverview(AppState state) {
    return SingleChildScrollView(
      key: const ValueKey('overview'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards
          SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(child: StatCard(title: 'Pending Tasks', value: '${state.pendingTasks.length}', icon: Icons.pending_actions, gradient: BaaiTheme.primaryGradient)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'In Progress', value: '${state.inProgressTasks.length}', icon: Icons.trending_up, gradient: BaaiTheme.accentGradient)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Completed Today', value: '${state.completedTasks.length}', icon: Icons.check_circle, gradient: BaaiTheme.successGradient)),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: 'Low Stock Items', value: '${state.lowStockItems.length}', icon: Icons.warning_amber, gradient: BaaiTheme.warmGradient)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Recent Tasks
          const Text('Today\'s Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
          const SizedBox(height: 12),
          ...state.tasks.take(6).map((t) => TaskCard(task: t)),
          const SizedBox(height: 24),
          // Low Stock Preview
          const Text('Pantry Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, mainAxisExtent: 160, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: state.inventory.length.clamp(0, 10),
              itemBuilder: (_, i) => AnimatedInventoryTile(item: state.inventory[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tasks Tab ─────────────────────────────────────────────
  Widget _buildTaskList(AppState state) {
    return SingleChildScrollView(
      key: const ValueKey('tasks'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('All Tasks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
              const Spacer(),
              Text('${state.tasks.length} total', style: const TextStyle(color: BaaiTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          if (state.overdueTasks.isNotEmpty) ...[
            _sectionHeader('Overdue', BaaiTheme.error, state.overdueTasks.length),
            ...state.overdueTasks.map((t) => TaskCard(task: t)),
          ],
          if (state.inProgressTasks.isNotEmpty) ...[
            _sectionHeader('In Progress', BaaiTheme.info, state.inProgressTasks.length),
            ...state.inProgressTasks.map((t) => TaskCard(task: t)),
          ],
          _sectionHeader('Pending', BaaiTheme.warning, state.pendingTasks.length),
          ...state.pendingTasks.map((t) => TaskCard(task: t)),
          if (state.completedTasks.isNotEmpty) ...[
            _sectionHeader('Completed', BaaiTheme.success, state.completedTasks.length),
            ...state.completedTasks.map((t) => TaskCard(task: t)),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: BaaiTheme.mediumAnim,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }

  // ─── Pantry Tab ────────────────────────────────────────────
  Widget _buildPantry(AppState state) {
    final categories = state.inventory.map((i) => i.category).toSet().toList()..sort();

    // Low stock banner at top
    final lowStockCount = state.lowStockItems.length;

    return SingleChildScrollView(
      key: const ValueKey('pantry'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Smart Pantry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
              const Spacer(),
              if (lowStockCount > 0)
                _PulsingLowStockBanner(count: lowStockCount),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Completing recipe tasks auto-deducts ingredients.', style: TextStyle(fontSize: 13, color: BaaiTheme.textSecondary)),
          const SizedBox(height: 20),
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
                  width: 200,
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
          // Inventory by category
          ...categories.map((cat) {
            final items = state.inventory.where((i) => i.category == cat).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 8),
                  child: Text(cat, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: BaaiTheme.accent)),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1.4, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: items.length,
                  itemBuilder: (_, i) => AnimatedInventoryTile(item: items[i]),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── Staff Tab ─────────────────────────────────────────────
  Widget _buildStaffView(AppState state) {
    return SingleChildScrollView(
      key: const ValueKey('staff'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff Directory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: state.staff.length,
            itemBuilder: (_, i) {
              final s = state.staff[i];
              final taskCount = state.tasks.where((t) => t.assignedTo == s.id && t.status != TaskStatus.completed).length;
              return AnimatedContainer(
                duration: BaaiTheme.mediumAnim,
                padding: const EdgeInsets.all(16),
                decoration: BaaiTheme.glassCard,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: BaaiTheme.primary.withOpacity(0.2),
                      child: Icon(s.roleIcon, color: BaaiTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary)),
                          const SizedBox(height: 4),
                          Text(s.roleLabel, style: const TextStyle(fontSize: 12, color: BaaiTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(color: s.isOnDuty ? BaaiTheme.success : BaaiTheme.textSecondary, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(s.isOnDuty ? 'On Duty' : 'Off Duty', style: TextStyle(fontSize: 11, color: s.isOnDuty ? BaaiTheme.success : BaaiTheme.textSecondary)),
                              const SizedBox(width: 12),
                              Text('$taskCount tasks', style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Alert Panel ───────────────────────────────────────────
  Widget _buildAlertPanel(AppState state) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: BaaiTheme.surface,
        border: Border(left: BorderSide(color: BaaiTheme.divider.withOpacity(0.5))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: BaaiTheme.textPrimary)),
                const Spacer(),
                if (state.alerts.isNotEmpty)
                  TextButton(
                    onPressed: () => state.clearAlerts(),
                    child: const Text('Clear', style: TextStyle(fontSize: 12, color: BaaiTheme.textSecondary)),
                  ),
              ],
            ),
          ),
          Expanded(
            child: state.alerts.isEmpty
              ? const Center(child: Text('No alerts', style: TextStyle(color: BaaiTheme.textSecondary)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => AlertTile(
                    alert: state.alerts[i],
                    onTap: () => state.markAlertRead(state.alerts[i].id),
                  ),
                ),
          ),
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
            color: widget.color.withOpacity(0.5 + _ctrl.value * 0.5),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.3 * _ctrl.value), blurRadius: 6)],
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
          color: BaaiTheme.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: BaaiTheme.error.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: BaaiTheme.error.withOpacity(0.1), blurRadius: 10)],
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
