import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baai/models/models.dart';
import 'package:baai/providers/app_state.dart';
import 'package:baai/services/voice_service.dart';
import 'package:baai/services/gemini_voice_engine.dart';
import 'package:baai/theme/app_theme.dart';
import 'package:baai/widgets/widgets.dart';

/// Landscape Kitchen Kiosk View — large touch targets, big text, swipe-friendly.
/// Polished with voice recording animations and animated tab transitions.
class KioskView extends StatefulWidget {
  const KioskView({super.key});
  @override State<KioskView> createState() => _KioskViewState();
}

class _KioskViewState extends State<KioskView> with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  int _kioskTab = 0; // 0 = tasks, 1 = pantry

  // Smooth tab transition
  late AnimationController _tabAnimController;

  @override
  void initState() {
    super.initState();
    _tabAnimController = AnimationController(vsync: this, duration: BaaiTheme.mediumAnim)..forward();
    _voiceService.updateStockLevels(context.read<AppState>().currentStockLevels);
    _voiceService.onResult.listen(_handleVoiceResult);
    _voiceService.onListeningChange.listen((v) {
      if (!mounted) return;
      context.read<AppState>().setRecording(v);
    });
  }

  @override
  void dispose() {
    _tabAnimController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _handleVoiceResult(GeminiVoiceResult result) {
    final appState = context.read<AppState>();
    final task = HouseholdTask(
      id: appState.generateTaskId(),
      title: result.taskTitle,
      category: TaskCategory.values.firstWhere((c) => c.name == result.category, orElse: () => TaskCategory.other),
      priority: TaskPriority.values.firstWhere((p) => p.name == result.priority, orElse: () => TaskPriority.medium),
      voiceNoteText: result.originalTranscript,
      linkedRecipeId: result.linkedRecipeId,
    );
    appState.addTask(task);
    
    // Add urgent alerts if any from voice parsing
    for (final alertMsg in result.urgentAlerts) {
      appState.addAlert(BaaiAlert(
        id: appState.generateAlertId(),
        type: AlertType.lowStock,
        title: 'Voice Engine Alert',
        message: alertMsg,
      ));
    }
    
    // Confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.mic, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text('🎤 Voice task: "${task.title}"')),
        ],
      ),
      backgroundColor: BaaiTheme.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _switchTab(int idx) {
    if (_kioskTab == idx) return;
    _tabAnimController.reset();
    setState(() => _kioskTab = idx);
    _tabAnimController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final now = DateTime.now();
      final h = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final ampm = now.hour >= 12 ? 'PM' : 'AM';
      final timeStr = '${h.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $ampm';

      return Scaffold(
        backgroundColor: BaaiTheme.background,
        body: Row(
          children: [
            // ─── Left: Tasks / Pantry ────────────────────
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Kiosk top bar
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    decoration: BoxDecoration(
                      color: BaaiTheme.surface,
                      border: Border(bottom: BorderSide(color: BaaiTheme.divider.withValues(alpha: 0.5))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(gradient: BaaiTheme.accentGradient, borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.restaurant, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kitchen Kiosk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: BaaiTheme.textPrimary)),
                            Text(state.household.name, style: const TextStyle(fontSize: 14, color: BaaiTheme.textSecondary)),
                          ],
                        ),
                        const Spacer(),
                        // Tab toggles — large touch targets (min 56px)
                        _kioskTabButton('Tasks', Icons.task_alt, 0),
                        const SizedBox(width: 12),
                        _kioskTabButton('Pantry', Icons.inventory_2, 1),
                        const Spacer(),
                        // Recording indicator
                        if (state.isRecording)
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: BaaiTheme.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: BaaiTheme.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _KioskPulsingDot(),
                                const SizedBox(width: 8),
                                const Text('Listening...', style: TextStyle(color: BaaiTheme.error, fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        Text(timeStr, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: BaaiTheme.textSecondary)),
                      ],
                    ),
                  ),
                  // Content with animated transitions
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _tabAnimController,
                      builder: (context, child) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: _tabAnimController, curve: BaaiTheme.defaultCurve));
                        final fade = CurvedAnimation(parent: _tabAnimController, curve: Curves.easeOut);
                        return SlideTransition(
                          position: slide,
                          child: FadeTransition(opacity: fade, child: child),
                        );
                      },
                      child: _kioskTab == 0
                        ? _buildKioskTasks(state)
                        : _buildKioskPantry(state),
                    ),
                  ),
                ],
              ),
            ),
            // ─── Right: Quick Action Sidebar ─────────────
            Container(
              width: 130,
              decoration: BoxDecoration(
                color: BaaiTheme.surface,
                border: Border(left: BorderSide(color: BaaiTheme.divider.withValues(alpha: 0.5))),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Removed mic button to center it prominently in the tasks view
                  const SizedBox(height: 12),
                  const SizedBox(height: 28),
                  // Quick stats
                  _kioskStat('Pending', '${state.pendingTasks.length}', BaaiTheme.warning),
                  _kioskStat('Active', '${state.inProgressTasks.length}', BaaiTheme.info),
                  _kioskStat('Done', '${state.completedTasks.length}', BaaiTheme.success),
                  _kioskStat('Low Stock', '${state.lowStockItems.length}', BaaiTheme.error),
                  const Spacer(),
                  // Staff on duty
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        const Text('On Duty', style: TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
                        const SizedBox(height: 8),
                        ...state.staff.where((s) => s.isOnDuty).take(4).map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Tooltip(
                            message: '${s.name} – ${s.roleLabel}',
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: BaaiTheme.primary.withValues(alpha: 0.2),
                              child: Icon(s.roleIcon, size: 20, color: BaaiTheme.primary),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _kioskTabButton(String label, IconData icon, int idx) {
    final active = _kioskTab == idx;
    return GestureDetector(
      onTap: () => _switchTab(idx),
      child: AnimatedContainer(
        duration: BaaiTheme.fastAnim,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: active ? BaaiTheme.accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: active ? Border.all(color: BaaiTheme.accent.withValues(alpha: 0.4), width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? BaaiTheme.accent : BaaiTheme.textSecondary, size: 24),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: active ? BaaiTheme.accent : BaaiTheme.textSecondary)),
            if (active) ...[
              const SizedBox(width: 8),
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: BaaiTheme.accent,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: BaaiTheme.accent.withValues(alpha: 0.5), blurRadius: 6)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kioskStat(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Column(
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) {
              return Text('$v', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color));
            },
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
        ],
      ),
    );
  }

  // ─── Kiosk Tasks ───────────────────────────────────────────
  Widget _buildKioskTasks(AppState state) {
    final activeTasks = state.tasks.where((t) => t.status != TaskStatus.completed).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: VoiceCenterWidget(
            isRecording: state.isRecording,
            onMicTap: () {
              if (state.isRecording) {
                _voiceService.stopListening();
              } else {
                _voiceService.startListening();
              }
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: const ValueKey('kiosk-tasks'),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
            itemCount: activeTasks.length,
            itemBuilder: (_, i) => TaskCard(task: activeTasks[i], isKiosk: true),
          ),
        ),
      ],
    );
  }

  // ─── Kiosk Pantry ──────────────────────────────────────────
  Widget _buildKioskPantry(AppState state) {
    return GridView.builder(
      key: const ValueKey('kiosk-pantry'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: 1.3, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: state.inventory.length,
      itemBuilder: (_, i) => InventoryTile(item: state.inventory[i]),
    );
  }
}

// ─── Kiosk-specific pulsing dot ──────────────────────────────
class _KioskPulsingDot extends StatefulWidget {
  @override State<_KioskPulsingDot> createState() => _KioskPulsingDotState();
}

class _KioskPulsingDotState extends State<_KioskPulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: BaaiTheme.error.withValues(alpha: 0.5 + _ctrl.value * 0.5),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: BaaiTheme.error.withValues(alpha: 0.4 * _ctrl.value), blurRadius: 8)],
          ),
        );
      },
    );
  }
}
