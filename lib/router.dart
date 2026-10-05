import 'package:go_router/go_router.dart';
import 'package:restaurant_unified_app/core/auth_provider.dart';
import 'package:restaurant_unified_app/core/constants.dart';

import 'shared/login_screen.dart';
import 'shared/forgot_password_screen.dart';
import 'shared/reset_password_screen.dart';

// Admin
import 'admin/screens/dashboard/admin_main_scaffold.dart';
import 'admin/screens/dashboard/staff/staff_screen.dart';

// Staff
import 'staff/screens/main_scaffold.dart';
import 'staff/screens/new_orders_screen.dart';
import 'staff/screens/create_order_screen.dart';
import 'staff/screens/order_details_screen.dart';
import 'staff/screens/payment_screen.dart';
import 'staff/screens/bill_screen.dart';

// Customer
import 'customer/screens/welcome_screen.dart';
import 'customer/screens/menu_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  // ------------------------------------------------------------
  // Decide where the app should start AFTER saved authentication
  // has already been loaded in main.dart.
  // ------------------------------------------------------------

  String getInitialLocation() {
    if (!authProvider.isAuthenticated) {
      return '/login';
    }

    switch (authProvider.role) {
      case UserRole.admin:
        return '/admin/dashboard';

      case UserRole.billingStaff:
        return '/staff/billing';

      case UserRole.servingStaff:
        return '/staff/dashboard';

      default:
        return '/login';
    }
  }

  return GoRouter(
    // IMPORTANT:
    // Do not always start at /login.
    // Use the restored authentication state.
    initialLocation: getInitialLocation(),

    refreshListenable: authProvider,

    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;

      final isLoggingIn = state.matchedLocation == '/login';

      final isForgotPassword =
          state.matchedLocation == '/forgot-password';

      final isResetPassword =
          state.matchedLocation.startsWith('/reset-password');

      final isCustomerScan =
          state.matchedLocation == '/customer/scan-qr';

      final isCustomerMenu =
          state.matchedLocation == '/customer/menu';

      final isAuthRoute =
          isLoggingIn ||
          isForgotPassword ||
          isResetPassword ||
          isCustomerScan ||
          isCustomerMenu;

      final isRoot = state.matchedLocation == '/';

      // ------------------------------------------------------------
      // NOT LOGGED IN
      // ------------------------------------------------------------
      if (!isLoggedIn) {
        if (isAuthRoute) {
          return null;
        }

        return '/login';
      }

      // ------------------------------------------------------------
      // LOGGED IN
      // If user reaches login/root, send them to their dashboard.
      // ------------------------------------------------------------
      if (isAuthRoute || isRoot) {
        switch (authProvider.role) {
          case UserRole.admin:
            return '/admin/dashboard';

          case UserRole.billingStaff:
            return '/staff/billing';

          case UserRole.servingStaff:
            return '/staff/dashboard';

          default:
            return '/login';
        }
      }

      // Already on the correct protected page.
      return null;
    },

    routes: [
      // ------------------------------------------------------------
      // AUTH
      // ------------------------------------------------------------

      GoRoute(
        path: '/login',
        builder: (context, state) => const UnifiedLoginScreen(),
      ),

      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/reset-password/:token',
        builder: (context, state) {
          final token =
              state.pathParameters['token'] ?? '';

          return ResetPasswordScreen(
            token: token,
          );
        },
      ),

      // ------------------------------------------------------------
      // ADMIN
      // ------------------------------------------------------------

      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) =>
            const AdminMainScaffold(initialTab: 0),
      ),

      GoRoute(
        path: '/admin/menu',
        builder: (context, state) =>
            const AdminMainScaffold(initialTab: 0),
      ),

      GoRoute(
        path: '/admin/staff',
        builder: (context, state) =>
            const AdminMainScaffold(initialTab: 1),
      ),

      GoRoute(
        path: '/admin/staff/:role',
        builder: (context, state) {
          final role =
              state.pathParameters['role'] ?? 'server';

          return StaffScreen(role: role);
        },
      ),

      GoRoute(
        path: '/admin/tables',
        builder: (context, state) =>
            const AdminMainScaffold(initialTab: 2),
      ),

      GoRoute(
        path: '/admin/orders',
        builder: (context, state) =>
            const AdminMainScaffold(initialTab: 3),
      ),

      GoRoute(
        path: '/admin/profile',
        builder: (context, state) =>
            const AdminMainScaffold(initialTab: 4),
      ),

      // ------------------------------------------------------------
      // STAFF
      // ------------------------------------------------------------

      GoRoute(
        path: '/staff/dashboard',
        builder: (context, state) =>
            const MainScaffold(initialTab: 0),
      ),

      GoRoute(
        path: '/staff/orders',
        builder: (context, state) =>
            const MainScaffold(initialTab: 1),
      ),

      GoRoute(
        path: '/staff/tables',
        builder: (context, state) =>
            const MainScaffold(initialTab: 2),
      ),

      GoRoute(
        path: '/staff/profile',
        builder: (context, state) =>
            const MainScaffold(initialTab: 3),
      ),

      GoRoute(
        path: '/staff/billing',
        builder: (context, state) =>
            const MainScaffold(initialTab: 0),
      ),

      GoRoute(
        path: '/staff/new-orders',
        builder: (context, state) =>
            const NewOrdersScreen(),
      ),

      GoRoute(
        path: '/staff/create-order',
        builder: (context, state) =>
            const CreateOrderScreen(),
      ),

      GoRoute(
        path: '/staff/order-details/:id',
        builder: (context, state) {
          final id =
              state.pathParameters['id'] ?? '';

          final from =
              state.uri.queryParameters['from'];

          return OrderDetailsScreen(
            orderId: id,
            from: from,
          );
        },
      ),

      GoRoute(
        path: '/staff/payment/:id',
        builder: (context, state) {
          final id =
              state.pathParameters['id'] ?? '';

          return PaymentScreen(
            orderId: id,
          );
        },
      ),

      GoRoute(
        path: '/staff/bill',
        builder: (context, state) {
          final extra =
              state.extra as Map<String, dynamic>? ?? {};

          return BillScreen(
            orderId:
                extra['orderId'] as String? ?? '',
            finalTotal:
                extra['finalTotal'] as int? ?? 0,
            paymentMethod:
                extra['paymentMethod'] as String? ?? 'cash',
          );
        },
      ),

      // ------------------------------------------------------------
      // CUSTOMER
      // ------------------------------------------------------------

      GoRoute(
        path: '/customer/scan-qr',
        builder: (context, state) {
          final table =
              state.uri.queryParameters['table'];

          final token =
              state.uri.queryParameters['token'];

          return WelcomeScreen(
            tableNumber: table ?? token,
          );
        },
      ),

      GoRoute(
        path: '/customer/menu',
        builder: (context, state) =>
            const CustomerMenuScreen(),
      ),
    ],
  );
}