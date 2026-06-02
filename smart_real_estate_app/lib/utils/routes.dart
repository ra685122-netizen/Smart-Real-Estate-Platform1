import 'package:go_router/go_router.dart';
import '../models/property_model.dart';
import '../providers/auth_provider.dart';
import '../views/splash_view.dart';
import '../views/onboarding_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/main_shell.dart';
import '../views/property_details_view.dart';
import '../views/property/add_property_view.dart';
import '../views/property/my_properties_view.dart';
import '../views/chat/chat_view.dart';
import '../views/profile/edit_profile_view.dart';
import '../views/notifications/notifications_view.dart';
import '../views/settings/settings_view.dart';
import '../views/settings/theme_settings_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/admin/admin_users_view.dart';
import '../views/admin/admin_properties_view.dart';
import '../views/admin/admin_reviews_view.dart';
import '../views/admin/admin_reports_view.dart';
import '../views/admin/admin_payments_view.dart';
import '../views/payment/payment_history_view.dart';
import '../views/ai/ai_assistant_view.dart';
import '../views/map/property_map_view.dart';
import '../views/virtual_tour/virtual_tour_view.dart';
import '../views/contracts/contracts_view.dart';
import '../views/contracts/contract_details_view.dart';
import '../views/payment/payment_view.dart';
import '../views/payment/payment_success_view.dart';
import '../views/agency/agency_profile_view.dart';
import '../views/profile/owner_profile_view.dart';
import '../views/tools/mortgage_calculator_view.dart';
import '../views/tools/property_comparison_view.dart';
import '../views/tools/investment_calculator_view.dart';
import '../views/neighborhood/neighborhood_insights_view.dart';

const _publicPaths = [
  '/splash',
  '/onboarding',
  '/login',
  '/register',
  '/home',
];

const _adminPaths = ['/admin'];

class AppRoutes {
  static GoRouter createRouter(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final path = state.uri.path;
        final isLoggedIn = auth.isLoggedIn;

        final isPublic = _publicPaths.any((p) => path == p || path.startsWith('$p/'));
        if (!isPublic && !isLoggedIn) return '/login';

        final needsAdmin = _adminPaths.any((p) => path.startsWith(p));
        if (needsAdmin && auth.currentUser?.role != 'admin') {
          return '/home';
        }

        return null;
      },
      routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/property',
        builder: (context, state) {
          final property = state.extra as Property;
          return PropertyDetailsView(property: property);
        },
      ),
      GoRoute(
        path: '/add-property',
        builder: (context, state) {
          final property = state.extra as Property?;
          return AddPropertyView(property: property);
        },
      ),
      GoRoute(
        path: '/my-properties',
        builder: (context, state) => const MyPropertiesView(),
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['userId']!);
          final extra = state.extra as Map<String, dynamic>?;
          return ChatView(
            otherUserId: userId,
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileView(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsView(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: '/theme-settings',
        builder: (context, state) => const ThemeSettingsView(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardView(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersView(),
      ),
      GoRoute(
        path: '/admin/properties',
        builder: (context, state) => const AdminPropertiesView(),
      ),
      GoRoute(
        path: '/admin/reviews',
        builder: (context, state) => const AdminReviewsView(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const AdminReportsView(),
      ),
      GoRoute(
        path: '/admin/payments',
        builder: (context, state) => const AdminPaymentsView(),
      ),
      GoRoute(
        path: '/payment-history',
        builder: (context, state) => const PaymentHistoryView(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AIAssistantView(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const PropertyMapView(),
      ),
      GoRoute(
        path: '/virtual-tour',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VirtualTourView(
            propertyTitle: extra?['title'] as String? ?? 'جولة افتراضية',
            propertyId: extra?['id'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/contracts',
        builder: (context, state) => const ContractsView(),
      ),
      GoRoute(
        path: '/contract-details/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ContractDetailsView(contractId: id);
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentView(
            amount: (extra?['amount'] as num?)?.toDouble() ?? 0,
            propertyTitle: extra?['title'] as String? ?? '',
            contractId: extra?['contractId'] as int?,
            sellerId: extra?['sellerId'] as int?,
          );
        },
      ),
      GoRoute(
        path: '/payment-success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentSuccessView(
            amount: (extra?['amount'] as num?)?.toDouble() ?? 0,
            transactionId: extra?['transactionId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/agency/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AgencyProfileView(agencyId: id);
        },
      ),
      GoRoute(
        path: '/owner/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return OwnerProfileView(ownerId: id);
        },
      ),
      GoRoute(
        path: '/mortgage-calculator',
        builder: (context, state) => const MortgageCalculatorView(),
      ),
      GoRoute(
        path: '/compare-properties',
        builder: (context, state) => const PropertyComparisonView(),
      ),
      GoRoute(
        path: '/investment-calculator',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return InvestmentCalculatorView(
            propertyPrice: (extra?['price'] as num?)?.toDouble(),
          );
        },
      ),
      GoRoute(
        path: '/neighborhood-insights',
        builder: (context, state) {
          final property = state.extra as Property;
          return NeighborhoodInsightsView(property: property);
        },
      ),
      ],
    );
  }
}
