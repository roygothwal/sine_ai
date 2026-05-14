import 'package:go_router/go_router.dart';
import 'package:sine_ai/features/auth/screens/splash_screen.dart';
import 'package:sine_ai/features/auth/screens/login_screen.dart';
import 'package:sine_ai/features/auth/screens/create_account_screen.dart';
import 'package:sine_ai/features/auth/screens/verify_email_screen.dart';
import 'package:sine_ai/features/auth/screens/home_screen.dart';
import 'package:sine_ai/features/settings/appearance/appearance_screen.dart';
import 'route_names.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.createAccount,
      builder: (context, state) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: RouteNames.verifyEmail,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return VerifyEmailScreen(pendingData: data);
      },
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RouteNames.appearance,
      builder: (context, state) => const AppearanceScreen(),
    ),
  ],
);
