import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baai/models/models.dart';
import 'package:baai/providers/app_state.dart';
import 'package:baai/theme/app_theme.dart';

// ─── Animated Task Card ──────────────────────────────────────
// Features:
//  • Smooth slide-in entry animation
//  • Hover lift effect
//  • "Complete Task" triggers green checkmark celebration before slide-out
//  • Responsive touch targets for kiosk/desktop/wall
class TaskCard extends StatefulWidget {
  final HouseholdTask task;
  final bool isKiosk;
  const TaskCard({super.key, required this.task, this.isKiosk = false});
  @override State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with TickerProviderStateMixin {
  bool _hovering = false;

  // Entry animation
  late AnimationController _entryController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Celebration animation (checkmark + slide-out)
  late AnimationController _celebrationController;
  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _slideOutX;
  late Animation<double> _slideOutOpacity;
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    // Entry
    _entryController = AnimationController(vsync: this, duration: BaaiTheme.slowAnim);
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: BaaiTheme.defaultCurve),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();

    // Celebration
    _celebrationController = AnimationController(vsync: this, duration: BaaiTheme.celebrationAnim);
    _checkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.3).chain(CurveTween(curve: Curves.easeOutBack)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 30),
    ]).animate(_celebrationController);
    _checkOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(_celebrationController);
    _slideOutX = Tween<double>(begin: 0, end: 200).animate(
      CurvedAnimation(parent: _celebrationController, curve: const Interval(0.6, 1.0, curve: Curves.easeInCubic)),
    );
    _slideOutOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _celebrationController, curve: const Interval(0.6, 1.0)),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _handleComplete() {
    if (_celebrating) return;
    setState(() => _celebrating = true);
    _celebrationController.forward().then((_) {
      if (mounted) {
        context.read<AppState>().updateTaskStatus(widget.task.id, TaskStatus.completed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final staff = appState.getStaffById(widget.task.assignedTo);
    final isKiosk = widget.isKiosk;
    // Responsive min-height for touch targets
    final minTouchTarget = isKiosk ? 56.0 : 44.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _celebrationController]),
      builder: (context, child) {
        final entryOffset = Offset(0, _slideAnimation.value);
        final celebOffset = Offset(_slideOutX.value, 0);
        final opacity = _celebrating
            ? _slideOutOpacity.value
            : _fadeAnimation.value;
        return Transform.translate(
          offset: entryOffset + celebOffset,
          child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: child),
        );
      },
      child: Stack(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: AnimatedContainer(
              duration: BaaiTheme.fastAnim,
              decoration: _hovering
                  ? (isKiosk ? BaaiTheme.kioskCardHover : BaaiTheme.glassCardHover)
                  : (isKiosk ? BaaiTheme.kioskCard : BaaiTheme.glassCard),
              padding: EdgeInsets.all(isKiosk ? 20 : 16),
              margin: EdgeInsets.only(bottom: isKiosk ? 16 : 10),
              constraints: BoxConstraints(minHeight: minTouchTarget),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Priority dot with glow
                      AnimatedContainer(
                        duration: BaaiTheme.mediumAnim,
                        width: isKiosk ? 14 : 10,
                        height: isKiosk ? 14 : 10,
                        decoration: BoxDecoration(
                          color: widget.task.priorityColor,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: widget.task.priorityColor.withOpacity(0.5), blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Category icon
                      Icon(widget.task.categoryIcon, color: BaaiTheme.accent, size: isKiosk ? 28 : 20),
                      const SizedBox(width: 10),
                      // Title
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: isKiosk ? 20 : 15,
                            fontWeight: FontWeight.w600,
                            color: BaaiTheme.textPrimary,
                            decoration: widget.task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Status chip
                      _StatusChip(status: widget.task.status, isKiosk: isKiosk),
                    ],
                  ),
                  if (widget.task.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(widget.task.description, style: TextStyle(fontSize: isKiosk ? 15 : 13, color: BaaiTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (staff != null) ...[
                        Icon(staff.roleIcon, size: isKiosk ? 18 : 14, color: BaaiTheme.primary),
                        const SizedBox(width: 4),
                        Text(staff.name, style: TextStyle(fontSize: isKiosk ? 14 : 12, color: BaaiTheme.textSecondary)),
                        const SizedBox(width: 12),
                      ],
                      if (widget.task.dueAt != null) ...[
                        Icon(Icons.schedule, size: isKiosk ? 18 : 14, color: BaaiTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(_formatTime(widget.task.dueAt!), style: TextStyle(fontSize: isKiosk ? 14 : 12, color: BaaiTheme.textSecondary)),
                      ],
                      if (widget.task.isRecurring) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.repeat, size: isKiosk ? 18 : 14, color: BaaiTheme.info),
                      ],
                      if (widget.task.linkedRecipeId != null) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.menu_book, size: isKiosk ? 18 : 14, color: BaaiTheme.warning),
                      ],
                      const Spacer(),
                      // Quick actions — sized for touch
                      if (widget.task.status != TaskStatus.completed && !_celebrating) ...[
                        _ActionButton(
                          icon: Icons.play_arrow,
                          color: BaaiTheme.info,
                          tooltip: 'Start',
                          isKiosk: isKiosk,
                          onTap: () => appState.updateTaskStatus(widget.task.id, TaskStatus.inProgress),
                        ),
                        const SizedBox(width: 6),
                        _ActionButton(
                          icon: Icons.check_circle,
                          color: BaaiTheme.success,
                          tooltip: 'Complete',
                          isKiosk: isKiosk,
                          onTap: _handleComplete,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Celebration overlay ──────────────────────
          if (_celebrating)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _celebrationController,
                builder: (context, _) {
                  return Container(
                    margin: EdgeInsets.only(bottom: isKiosk ? 16 : 10),
                    decoration: BoxDecoration(
                      color: BaaiTheme.success.withOpacity(0.12 * _checkOpacity.value),
                      borderRadius: BorderRadius.circular(isKiosk ? 20 : 16),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _checkScale.value,
                        child: Opacity(
                          opacity: _checkOpacity.value.clamp(0.0, 1.0),
                          child: Container(
                            width: isKiosk ? 64 : 48,
                            height: isKiosk ? 64 : 48,
                            decoration: BoxDecoration(
                              gradient: BaaiTheme.successGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: BaaiTheme.success.withOpacity(0.4), blurRadius: 20, spreadRadius: 4),
                              ],
                            ),
                            child: Icon(Icons.check_rounded, color: Colors.white, size: isKiosk ? 36 : 28),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

// ─── Status Chip ──────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final TaskStatus status;
  final bool isKiosk;
  const _StatusChip({required this.status, this.isKiosk = false});

  @override
  Widget build(BuildContext context) {
    Color bg; Color fg; String label;
    switch (status) {
      case TaskStatus.pending:    bg = BaaiTheme.warning.withOpacity(0.15); fg = BaaiTheme.warning; label = 'Pending';
      case TaskStatus.inProgress: bg = BaaiTheme.info.withOpacity(0.15);    fg = BaaiTheme.info;    label = 'In Progress';
      case TaskStatus.completed:  bg = BaaiTheme.success.withOpacity(0.15); fg = BaaiTheme.success; label = 'Done';
      case TaskStatus.overdue:    bg = BaaiTheme.error.withOpacity(0.15);   fg = BaaiTheme.error;   label = 'Overdue';
    }
    return AnimatedContainer(
      duration: BaaiTheme.mediumAnim,
      padding: EdgeInsets.symmetric(horizontal: isKiosk ? 14 : 10, vertical: isKiosk ? 6 : 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: isKiosk ? 14 : 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Small Action Button ──────────────────────────────────────
// Min touch targets: 44px desktop, 56px kiosk
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final bool isKiosk;
  const _ActionButton({required this.icon, required this.color, required this.tooltip, required this.onTap, this.isKiosk = false});

  @override
  Widget build(BuildContext context) {
    final size = isKiosk ? 48.0 : 36.0;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Icon(icon, size: isKiosk ? 24 : 18, color: color)),
        ),
      ),
    );
  }
}

// ─── Pulsing Mic Button ───────────────────────────────────────
// Idle: smooth subtle pulse. Recording: multi-ring glowing ripple + waveform bars.
class PulsingMicButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;
  final bool isKiosk;
  const PulsingMicButton({super.key, required this.isRecording, required this.onTap, this.isKiosk = false});
  @override State<PulsingMicButton> createState() => _PulsingMicButtonState();
}

class _PulsingMicButtonState extends State<PulsingMicButton> with TickerProviderStateMixin {
  // Idle pulse
  late AnimationController _idlePulse;
  // Recording ripple (3 expanding rings)
  late AnimationController _ripple;
  // Recording waveform bars
  late AnimationController _waveform;

  @override
  void initState() {
    super.initState();
    _idlePulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _ripple = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    _waveform = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idlePulse.dispose();
    _ripple.dispose();
    _waveform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.isKiosk ? 80.0 : 56.0;
    final isRec = widget.isRecording;
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: size + 40,
        height: size + 40,
        child: AnimatedBuilder(
          animation: Listenable.merge([_idlePulse, _ripple, _waveform]),
          builder: (context, _) {
            return CustomPaint(
              painter: _MicButtonPainter(
                isRecording: isRec,
                idleValue: _idlePulse.value,
                rippleValue: _ripple.value,
                waveformValue: _waveform.value,
                buttonSize: size,
                accentColor: isRec ? BaaiTheme.error : BaaiTheme.primary,
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: BaaiTheme.mediumAnim,
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isRec ? BaaiTheme.warmGradient : BaaiTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (isRec ? BaaiTheme.error : BaaiTheme.primary).withOpacity(0.5),
                        blurRadius: isRec ? 24 : 12,
                        spreadRadius: isRec ? 2 : 0,
                      ),
                    ],
                  ),
                  child: isRec
                      ? _buildWaveformBars()
                      : Icon(Icons.mic, color: Colors.white, size: widget.isKiosk ? 36 : 28),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWaveformBars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final phase = (i * 0.2 + _waveform.value) * math.pi * 2;
        final h = 8.0 + math.sin(phase).abs() * (widget.isKiosk ? 22.0 : 16.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: widget.isKiosk ? 4 : 3,
          height: h,
          margin: EdgeInsets.symmetric(horizontal: widget.isKiosk ? 2.5 : 1.5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

/// Custom painter: draws expanding ripple rings when recording, subtle pulse when idle.
class _MicButtonPainter extends CustomPainter {
  final bool isRecording;
  final double idleValue;
  final double rippleValue;
  final double waveformValue;
  final double buttonSize;
  final Color accentColor;

  _MicButtonPainter({
    required this.isRecording,
    required this.idleValue,
    required this.rippleValue,
    required this.waveformValue,
    required this.buttonSize,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (isRecording) {
      // Draw 3 expanding ripple rings
      for (int i = 0; i < 3; i++) {
        final progress = ((rippleValue + i * 0.33) % 1.0);
        final radius = buttonSize / 2 + progress * 30;
        final opacity = (1.0 - progress) * 0.35;
        final paint = Paint()
          ..color = accentColor.withOpacity(opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 - progress * 1.5;
        canvas.drawCircle(center, radius, paint);
      }
    } else {
      // Idle: single subtle expanding/contracting glow ring
      final radius = buttonSize / 2 + 4 + idleValue * 6;
      final opacity = 0.08 + idleValue * 0.12;
      final paint = Paint()
        ..color = accentColor.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MicButtonPainter old) => true;
}

// ─── Inventory Item Tile ──────────────────────────────────────
// Features:
//  • Low-stock pulsing red warning banner
//  • Animated quantity counter on deduction (TweenAnimationBuilder)
class InventoryTile extends StatefulWidget {
  final InventoryItem item;
  const InventoryTile({super.key, required this.item});
  @override State<InventoryTile> createState() => _InventoryTileState();
}

class _InventoryTileState extends State<InventoryTile> with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _lowStockPulse;

  @override
  void initState() {
    super.initState();
    _lowStockPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() { _lowStockPulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final ratio = item.reorderThreshold > 0 ? (item.quantity / (item.reorderThreshold * 3)).clamp(0.0, 1.0) : 1.0;
    final barColor = item.isLowStock ? BaaiTheme.error : (ratio < 0.5 ? BaaiTheme.warning : BaaiTheme.success);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: BaaiTheme.fastAnim,
        decoration: _hovering ? BaaiTheme.glassCardHover : BaaiTheme.glassCard,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (item.isLowStock)
                  AnimatedBuilder(
                    animation: _lowStockPulse,
                    builder: (context, child) {
                      final opacity = 0.6 + _lowStockPulse.value * 0.4;
                      final scale = 1.0 + _lowStockPulse.value * 0.08;
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BaaiTheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: BaaiTheme.error.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(color: BaaiTheme.error.withOpacity(0.15), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 11, color: BaaiTheme.error),
                          const SizedBox(width: 3),
                          const Text('LOW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: BaaiTheme.error)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(item.category, style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
            const Spacer(),
            // Animated counter value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: item.quantity, end: item.quantity),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Text(
                      '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} ${item.unit.name}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: barColor),
                    );
                  },
                ),
                if (item.isLowStock)
                  TextButton.icon(
                    onPressed: () {
                      final link = context.read<AppState>().generateReorderLink(item);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('🔗 Redirecting to Blinkit: ${item.name}\\n$link'),
                        backgroundColor: BaaiTheme.accent,
                        duration: const Duration(seconds: 4),
                      ));
                    },
                    icon: const Icon(Icons.shopping_cart_checkout, size: 14),
                    label: const Text('Reorder', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: BaaiTheme.textPrimary,
                      backgroundColor: BaaiTheme.accent.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            // Progress bar with animated value
            TweenAnimationBuilder<double>(
              tween: Tween(begin: ratio, end: ratio),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: BaaiTheme.divider,
                    color: barColor,
                    minHeight: 4,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Inventory Tile (with real-time deduction counter) ──
// Used in the admin dashboard pantry view for animated deduction display.
class AnimatedInventoryTile extends StatefulWidget {
  final InventoryItem item;
  const AnimatedInventoryTile({super.key, required this.item});
  @override State<AnimatedInventoryTile> createState() => _AnimatedInventoryTileState();
}

class _AnimatedInventoryTileState extends State<AnimatedInventoryTile> with SingleTickerProviderStateMixin {
  bool _hovering = false;
  double _prevQuantity = 0;
  late AnimationController _lowStockPulse;

  @override
  void initState() {
    super.initState();
    _prevQuantity = widget.item.quantity;
    _lowStockPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AnimatedInventoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity) {
      _prevQuantity = oldWidget.item.quantity;
    }
  }

  @override
  void dispose() { _lowStockPulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final ratio = item.reorderThreshold > 0 ? (item.quantity / (item.reorderThreshold * 3)).clamp(0.0, 1.0) : 1.0;
    final barColor = item.isLowStock ? BaaiTheme.error : (ratio < 0.5 ? BaaiTheme.warning : BaaiTheme.success);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: BaaiTheme.fastAnim,
        decoration: _hovering ? BaaiTheme.glassCardHover : BaaiTheme.glassCard,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: BaaiTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (item.isLowStock)
                  AnimatedBuilder(
                    animation: _lowStockPulse,
                    builder: (context, child) {
                      final opacity = 0.6 + _lowStockPulse.value * 0.4;
                      final scale = 1.0 + _lowStockPulse.value * 0.08;
                      return Transform.scale(
                        scale: scale,
                        child: Opacity(opacity: opacity, child: child),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: BaaiTheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: BaaiTheme.error.withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(color: BaaiTheme.error.withOpacity(0.15), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 11, color: BaaiTheme.error),
                          const SizedBox(width: 3),
                          const Text('LOW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: BaaiTheme.error)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(item.category, style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary)),
            const Spacer(),
            // Animated counter deduction
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TweenAnimationBuilder<double>(
                  key: ValueKey('${item.id}-${item.quantity}'),
                  tween: Tween(begin: _prevQuantity, end: item.quantity),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Text(
                      '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} ${item.unit.name}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: barColor),
                    );
                  },
                ),
                if (item.isLowStock)
                  TextButton.icon(
                    onPressed: () {
                      final link = context.read<AppState>().generateReorderLink(item);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('🔗 Redirecting to Blinkit: ${item.name}\\n$link'),
                        backgroundColor: BaaiTheme.accent,
                        duration: const Duration(seconds: 4),
                      ));
                    },
                    icon: const Icon(Icons.shopping_cart_checkout, size: 14),
                    label: const Text('Reorder', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      foregroundColor: BaaiTheme.textPrimary,
                      backgroundColor: BaaiTheme.accent.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              key: ValueKey('bar-${item.id}-${item.quantity}'),
              tween: Tween(begin: _prevQuantity > 0 ? (_prevQuantity / (item.reorderThreshold * 3)).clamp(0.0, 1.0) : ratio, end: ratio),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: BaaiTheme.divider,
                    color: barColor,
                    minHeight: 4,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card (Dashboard Summary) ────────────────────────────
class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;
  const StatCard({super.key, required this.title, required this.value, required this.icon, required this.gradient});
  @override State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: _hovering ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: widget.gradient.colors.first.withOpacity(_hovering ? 0.4 : 0.2), blurRadius: _hovering ? 24 : 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, color: Colors.white.withOpacity(0.85), size: 28),
            const Spacer(),
            // Animated counter
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: int.tryParse(widget.value) ?? 0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white));
              },
            ),
            const SizedBox(height: 4),
            Text(widget.title, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
          ],
        ),
      ),
    );
  }
}

// ─── Alert Tile ───────────────────────────────────────────────
class AlertTile extends StatelessWidget {
  final BaaiAlert alert;
  final VoidCallback? onTap;
  const AlertTile({super.key, required this.alert, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: BaaiTheme.fastAnim,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: alert.isRead ? BaaiTheme.card.withOpacity(0.3) : BaaiTheme.card.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: alert.isRead ? null : Border.all(color: alert.color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: alert.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(alert.icon, color: alert.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert.title, style: TextStyle(fontSize: 13, fontWeight: alert.isRead ? FontWeight.w400 : FontWeight.w600, color: BaaiTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(alert.message, style: const TextStyle(fontSize: 11, color: BaaiTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (!alert.isRead) Container(width: 8, height: 8, decoration: BoxDecoration(color: alert.color, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}
