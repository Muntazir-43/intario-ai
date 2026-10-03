import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/providers/auth_provider.dart';
import 'package:intario_ai/screens/home/home_screen.dart';
import 'package:intario_ai/screens/projects/projects_screen.dart';
import 'package:intario_ai/screens/projects/project_preview_screen.dart';
import 'package:intario_ai/screens/profile/profile_screen.dart';
import 'package:intario_ai/screens/settings/settings_screen.dart';
import 'package:intario_ai/screens/auth/login_screen.dart';
import 'package:intario_ai/screens/flows/upload_screen.dart';
import 'package:intario_ai/screens/flows/room_type_screen.dart';
import 'package:intario_ai/screens/flows/style_screen.dart';
import 'package:intario_ai/screens/flows/color_scheme_screen.dart';
import 'package:intario_ai/screens/flows/color_picker_screen.dart';
import 'package:intario_ai/screens/flows/theme_screen.dart';
import 'package:intario_ai/screens/flows/garden_style_screen.dart';
import 'package:intario_ai/screens/flows/prompt_screen.dart';
import 'package:intario_ai/screens/flows/hint_screen.dart';
import 'package:intario_ai/screens/flows/confirm_screen.dart';
import 'package:intario_ai/screens/flows/generating_screen.dart';
import 'package:intario_ai/screens/flows/result_screen.dart';
import 'package:intario_ai/screens/flows/gateway_screens.dart';
import 'package:intario_ai/screens/premium_ar/premium_ar_screen.dart';
import 'package:intario_ai/screens/flows/style_transfer_inspiration_screen.dart';
import 'package:intario_ai/screens/errors/error_screen.dart';
import 'package:intario_ai/screens/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    // 1. Initial location is always the splash screen
    initialLocation: '/splash',
    
    // 2. Simple, non-blocking redirect logic
    redirect: (context, state) {
      final bool isAuthenticated = authState.isAuthenticated;
      final bool isLoggingIn = state.matchedLocation == '/login';
      final bool isSplashing = state.matchedLocation == '/splash';

      // Always allow splash to complete without interference
      if (isSplashing) return null;

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
      }

      return null;
    },
    
    routes: [
      // ── Splash Route ─────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        pageBuilder: (c, s) => NoTransitionPage(
          key: s.pageKey,
          child: const SplashScreen(),
        ),
      ),

      // ── Main tabs ──────────────────────────────────────────────────
      GoRoute(path: '/',          pageBuilder: (c,s) => _fadeSlide(c,s, const HomeScreen())),
      GoRoute(path: '/projects',  pageBuilder: (c,s) => _fadeSlide(c,s, const ProjectsScreen())),
      GoRoute(path: '/profile',   pageBuilder: (c,s) => _fadeSlide(c,s, const ProfileScreen())),
      GoRoute(path: '/settings',  pageBuilder: (c,s) => _fadeSlide(c,s, const SettingsScreen())),
      GoRoute(path: '/login',     pageBuilder: (c,s) => _fadeSlide(c,s, const LoginScreen())),

      // ── Project preview ────────────────────────────────────────────
      GoRoute(
        path: '/project/:id',
        pageBuilder: (c,s) => _fadeSlide(c,s,
            ProjectPreviewScreen(projectId: s.pathParameters['id']!)),
      ),

      // ── Gateways ───────────────────────────────────────────────────
      GoRoute(path: '/room-design',         pageBuilder: (c,s) => _fadeSlide(c,s, const RoomDesignGateway())),
      GoRoute(path: '/exterior-design',     pageBuilder: (c,s) => _fadeSlide(c,s, const ExteriorDesignGateway())),
      GoRoute(path: '/color-visualization', pageBuilder: (c,s) => _fadeSlide(c,s, const ColorVisualizationGateway())),
      GoRoute(path: '/premium-ar',          pageBuilder: (c,s) => _fadeSlide(c,s, const PremiumARScreen())),

      // ── Wizard flow ────────────────────────────────────────────────
      GoRoute(path: '/flow/upload',                     pageBuilder: (c,s) => _fadeSlide(c,s, const UploadScreen())),
      GoRoute(path: '/flow/room-type',                  pageBuilder: (c,s) => _fadeSlide(c,s, const RoomTypeScreen())),
      GoRoute(path: '/flow/style',                      pageBuilder: (c,s) => _fadeSlide(c,s, const StyleScreen())),
      GoRoute(path: '/flow/color-scheme',               pageBuilder: (c,s) => _fadeSlide(c,s, const ColorSchemeScreen())),
      GoRoute(path: '/flow/color-picker',               pageBuilder: (c,s) => _fadeSlide(c,s, const ColorPickerScreen())),
      GoRoute(path: '/flow/theme',                      pageBuilder: (c,s) => _fadeSlide(c,s, const ThemeScreen())),
      GoRoute(path: '/flow/garden-style',               pageBuilder: (c,s) => _fadeSlide(c,s, const GardenStyleScreen())),
      GoRoute(path: '/flow/prompt',                     pageBuilder: (c,s) => _fadeSlide(c,s, const PromptScreen())),
      GoRoute(path: '/flow/hint',                       pageBuilder: (c,s) => _fadeSlide(c,s, const HintScreen())),
      GoRoute(path: '/flow/confirm',                    pageBuilder: (c,s) => _fadeSlide(c,s, const ConfirmScreen())),
      GoRoute(path: '/flow/generating',                 pageBuilder: (c,s) => _fadeSlide(c,s, const GeneratingScreen())),
      GoRoute(path: '/flow/result',                     pageBuilder: (c,s) => _fadeSlide(c,s, const ResultScreen())),
      GoRoute(path: '/flow/style-transfer-inspiration', pageBuilder: (c,s) => _fadeSlide(c,s, const StyleTransferInspirationScreen())),

      // ── Error ──────────────────────────────────────────────────────
      GoRoute(path: '/error', pageBuilder: (c,s) => _fadeSlide(c,s, const ErrorScreen())),
    ],
  );
});

Page<void> _fadeSlide(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      );
    },
  );
}
