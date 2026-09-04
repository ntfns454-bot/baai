import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baai/providers/app_state.dart';
import 'package:baai/screens/admin_dashboard.dart';
import 'package:baai/screens/kiosk_view.dart';
import 'package:baai/widgets/testing_dashboard.dart';
import 'package:baai/theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BaaiApp(),
    ),
  );
}

class BaaiApp extends StatelessWidget {
  const BaaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAAI – Smart Household Management',
      debugShowCheckedModeBanner: false,
      theme: BaaiTheme.darkTheme,
      home: const BaaiShell(),
    );
  }
}

class BaaiShell extends StatelessWidget {
  const BaaiShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Stack(
          children: [
            // Main view — switches between Admin and Kiosk
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: state.isKioskMode
                ? const KioskView(key: ValueKey('kiosk'))
                : const AdminDashboard(key: ValueKey('admin')),
            ),
            // Floating sandbox toolbar (top-center)
            const SandboxToolbar(),
          ],
        );
      },
    );
  }
}
