import 'package:flutter/material.dart';
import 'package:system_5210/features/specialists/presentation/views/data_uploader_view.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/verification_view.dart';
import '../../features/auth/presentation/views/reset_password_view.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/home/presentation/views/main_layout_view.dart';
import '../../features/splash/presentation/views/language_view.dart';
import '../../features/splash/presentation/views/splash_view.dart';
import '../../features/user_setup/presentation/views/role_selection_view.dart';
import '../../features/user_setup/presentation/views/child_quiz_view.dart';
import '../../features/user_setup/presentation/views/parent_quiz_view.dart';
import '../../features/user_setup/presentation/views/parent_profile_setup_view.dart';
import '../../features/user_setup/presentation/views/congratulations_view.dart';
import '../../features/nutrition_scan/presentation/pages/scan_page.dart';
import '../../features/nutrition_scan/presentation/pages/recent_scans_page.dart';
import '../../features/healthy_recipes/presentation/views/recipes_list_view.dart';
import '../../features/healthy_recipes/presentation/views/recipe_details_view.dart';
import '../../features/healthy_recipes/domain/entities/recipe.dart';

class AppRoutes {
  static const String splash = '/';
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String uploader = '/uploader';
  static const String resetPassword = '/reset-password';

  // New User Setup Routes
  static const String roleSelection = '/role-selection';
  static const String childQuiz = '/child-quiz';
  static const String parentQuiz = '/parent-quiz';
  static const String parentProfileSetup = '/parent-profile-setup';
  static const String congratulations = '/congratulations';
  static const String nutritionScan = '/nutrition-scan';
  static const String recentScans = '/recent-scans';
  static const String healthyRecipes = '/healthy-recipes';
  static const String recipeDetails = '/recipe-details';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case splash:
        page = const SplashView();
        break;
      case language:
        final fromSettings = settings.arguments as bool? ?? false;
        page = LanguageView(fromSettings: fromSettings);
        break;
      case onboarding:
        page = const OnboardingView();
        break;
      case login:
        page = const LoginView();
        break;
      case register:
        page = const RegisterView();
        break;
      case forgotPassword:
        page = const ForgotPasswordView();
        break;
      case home:
        page = const MainLayoutView();
        break;
      case roleSelection:
        page = const RoleSelectionView();
        break;
      case childQuiz:
        page = const ChildQuizView();
        break;
      case parentQuiz:
        page = const ParentQuizView();
        break;
      case parentProfileSetup:
        page = const ParentProfileSetupView();
        break;
      case congratulations:
        page = const CongratulationsView();
        break;
      case resetPassword:
        final email = settings.arguments as String? ?? "";
        page = ResetPasswordView(email: email);
        break;
      case verification:
        final args = settings.arguments as Map<String, dynamic>?;
        page = VerificationView(
          isEmail: args?['isEmail'] ?? true,
          email: args?['email'] as String?,
          verificationId: args?['verificationId'] as String?,
          isPasswordReset: args?['isPasswordReset'] ?? false,
        );
        break;
      case nutritionScan:
        page = const ScanPage();
        break;
      case recentScans:
        page = const RecentScansPage();
        break;
      case uploader:
        page = const DataUploaderView();
        break;
      case healthyRecipes:
        page = const RecipesListView();
        break;
      case recipeDetails:
        final recipe = settings.arguments as Recipe;
        page = RecipeDetailsView(recipe: recipe);
        break;
      default:
        return null;
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}
