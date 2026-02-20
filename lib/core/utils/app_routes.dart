import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/features/specialists/presentation/views/data_uploader_view.dart';
import 'package:system_5210/core/utils/injection_container.dart';
import 'package:system_5210/features/auth/presentation/views/forgot_password_view.dart';
import 'package:system_5210/features/auth/presentation/views/login_view.dart';
import 'package:system_5210/features/auth/presentation/views/register_view.dart';
import 'package:system_5210/features/auth/presentation/views/verification_view.dart';
import 'package:system_5210/features/auth/presentation/views/reset_password_view.dart';
import 'package:system_5210/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:system_5210/features/home/presentation/views/main_layout_view.dart';
import 'package:system_5210/features/splash/presentation/views/language_view.dart';
import 'package:system_5210/features/splash/presentation/views/splash_view.dart';
import 'package:system_5210/features/user_setup/presentation/views/role_selection_view.dart';
import 'package:system_5210/features/user_setup/presentation/views/child_quiz_view.dart';
import 'package:system_5210/features/user_setup/presentation/views/parent_quiz_view.dart';
import 'package:system_5210/features/user_setup/presentation/views/parent_profile_setup_view.dart';
import 'package:system_5210/features/user_setup/presentation/views/congratulations_view.dart';
import 'package:system_5210/features/nutrition_scan/presentation/pages/scan_page.dart';
import 'package:system_5210/features/nutrition_scan/presentation/pages/recent_scans_page.dart';
import 'package:system_5210/features/healthy_recipes/presentation/views/recipes_list_view.dart';
import 'package:system_5210/features/healthy_recipes/presentation/views/recipe_details_view.dart';
import 'package:system_5210/features/healthy_recipes/domain/entities/recipe.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/views/balanced_plate_view.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/views/game_stats_view.dart';
import 'package:system_5210/features/games/presentation/views/games_list_view.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/cubit/balanced_plate_cubit.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/cubit/game_stats_cubit.dart';
import 'package:system_5210/features/games/food_matching/presentation/views/food_matching_view.dart';
import 'package:system_5210/features/games/food_matching/presentation/views/matching_stats_view.dart';
import 'package:system_5210/features/games/food_matching/presentation/cubit/food_matching_cubit.dart';
import 'package:system_5210/features/games/quizGame/presentation/views/quiz_levels_view.dart';
import 'package:system_5210/features/games/quizGame/presentation/cubit/quiz_cubit.dart';
import 'package:system_5210/features/games/bonding_game/presentation/views/bonding_game_dashboard_view.dart';
import 'package:system_5210/features/healthy_insights/presentation/views/healthy_insights_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String roleSelection = '/role-selection';
  static const String childQuiz = '/child-quiz';
  static const String parentQuiz = '/parent-quiz';
  static const String parentProfileSetup = '/parent-profile-setup';
  static const String congratulations = '/congratulations';
  static const String home = '/home';
  static const String nutritionScan = '/scan';
  static const String recentScans = '/recent-scans';
  static const String healthyRecipes = '/recipes-list';
  static const String recipeDetails = '/recipe-details';
  static const String uploader = '/data-uploader';
  static const String healthyInsights = '/healthy-insights';

  // Games
  static const String gamesList = '/games-list';
  static const String balancedPlateGame = '/balanced-plate-game';
  static const String balancedPlateStats = '/balanced-plate-stats';
  static const String matchingGame = '/matching-game';
  static const String matchingStats = '/matching-stats';
  static const String quizGame = '/quiz-game';
  static const String bondingGame = '/bonding-game';

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
      case verification:
        final args = settings.arguments as Map<String, dynamic>;
        page = VerificationView(
          isEmail: args['isEmail'] ?? false,
          email: args['email'],
          phoneNumber: args['phoneNumber'],
          verificationId: args['verificationId'],
          isPasswordReset: args['isPasswordReset'] ?? false,
        );
        break;
      case forgotPassword:
        page = const ForgotPasswordView();
        break;
      case resetPassword:
        final email = settings.arguments as String;
        page = ResetPasswordView(email: email);
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
      case home:
        page = const MainLayoutView();
        break;
      case nutritionScan:
        page = const ScanPage();
        break;
      case recentScans:
        page = const RecentScansPage();
        break;
      case healthyRecipes:
        page = const RecipesListView();
        break;
      case recipeDetails:
        final recipe = settings.arguments as Recipe;
        page = RecipeDetailsView(recipe: recipe);
        break;
      case uploader:
        page = const DataUploaderView();
        break;

      // Games
      case balancedPlateGame:
        page = BlocProvider(
          create: (context) => sl<BalancedPlateCubit>()..startGame(),
          child: const BalancedPlateView(),
        );
        break;
      case balancedPlateStats:
        page = BlocProvider(
          create: (context) => sl<GameStatsCubit>(),
          child: const GameStatsView(),
        );
        break;
      case gamesList:
        page = const GamesListView();
        break;
      case matchingGame:
        page = BlocProvider(
          create: (context) => sl<FoodMatchingCubit>(),
          child: const FoodMatchingView(),
        );
        break;
      case matchingStats:
        page = BlocProvider(
          create: (context) => sl<GameStatsCubit>(),
          child: const MatchingStatsView(),
        );
        break;
      case quizGame:
        page = BlocProvider(
          create: (context) => sl<QuizCubit>()..loadLevels(),
          child: const QuizLevelsView(),
        );
        break;
      case bondingGame:
        page = const BondingGameDashboardView();
        break;
      case healthyInsights:
        page = const HealthyInsightsView();
        break;
      default:
        return null;
    }

    return MaterialPageRoute(builder: (context) => page, settings: settings);
  }
}
