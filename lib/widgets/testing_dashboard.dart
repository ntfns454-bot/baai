import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baai/providers/app_state.dart';
import 'package:baai/theme/app_theme.dart';

/// Floating Sandbox Toolbar — a top-center header bar for instant
/// toggling between Admin Dashboard and Kitchen Kiosk modes,
/// plus a "Reset Sandbox Data" button.
class SandboxToolbar extends StatefulWidget {
  const SandboxToolbar({super.key});
  @override State<SandboxToolbar> createState() => _SandboxToolbarState();
}

class _SandboxToolbarState extends State<SandboxToolbar> with SingleTickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _slideDown;
  late Animation<double> _fade;
  bool _hovering = false;
  bool _showResetConfirm = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideDown = Tween<double>(begin: -60, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: const Interval(0.2, 1.0)),
    );
    _entryController.forward();
  }

  @override
  void dispose() { _entryController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      return Positioned(
        top: 12,
        left: 0,
        right: 0,
        child: AnimatedBuilder(
          animation: _entryController,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _slideDown.value),
            child: Opacity(opacity: _fade.value.clamp(0.0, 1.0), child: child),
          ),
          child: Center(
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovering = true),
              onExit: (_) => setState(() { _hovering = false; _showResetConfirm = false; }),
              child: AnimatedContainer(
                duration: BaaiTheme.fastAnim,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BaaiTheme.sandboxToolbar.copyWith(
                  border: Border.all(
                    color: _hovering
                        ? BaaiTheme.accent.withValues(alpha: 0.45)
                        : BaaiTheme.accent.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BAAI label
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: BaaiTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.science_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('SANDBOX', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // ─── Mode Toggle ──────────────────────────
                    _modeToggle(
                      icon: Icons.dashboard_rounded,
                      label: 'Admin Dashboard',
                      active: !state.isKioskMode,
                      onTap: () => state.setKioskMode(false),
                    ),
                    const SizedBox(width: 4),
                    _modeToggle(
                      icon: Icons.tablet_mac_rounded,
                      label: 'Kitchen Kiosk',
                      active: state.isKioskMode,
                      onTap: () => state.setKioskMode(true),
                    ),

                    // Divider
                    Container(
                      width: 1, height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      color: BaaiTheme.divider.withValues(alpha: 0.5),
                    ),

                    // ─── Reset Button ──────────────────────────
                    _showResetConfirm
                        ? _resetConfirmRow(state)
                        : _resetButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _modeToggle({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BaaiTheme.fastAnim,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? BaaiTheme.accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: active
              ? Border.all(color: BaaiTheme.accent.withValues(alpha: 0.45), width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? BaaiTheme.accent : BaaiTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? BaaiTheme.accent : BaaiTheme.textSecondary,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 6),
              Container(
                width: 6, height: 6,
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

  Widget _resetButton() {
    return GestureDetector(
      onTap: () => setState(() => _showResetConfirm = true),
      child: AnimatedContainer(
        duration: BaaiTheme.fastAnim,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: BaaiTheme.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: BaaiTheme.warning.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 15, color: BaaiTheme.warning),
            SizedBox(width: 5),
            Text('Reset Data', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: BaaiTheme.warning)),
          ],
        ),
      ),
    );
  }

  Widget _resetConfirmRow(AppState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            state.resetToDefaults();
            setState(() => _showResetConfirm = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('🔄 Sandbox data reset to defaults'),
                ],
              ),
              backgroundColor: BaaiTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 2),
            ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: BaaiTheme.warmGradient,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text('Confirm Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => setState(() => _showResetConfirm = false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: BaaiTheme.card.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.close, size: 14, color: BaaiTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}
