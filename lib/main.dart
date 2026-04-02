import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:five2ten/core/services/notification_service.dart';
import 'package:five2ten/l10n/app_localizations.dart';
import 'package:five2ten/firebase_options.dart';
import 'package:five2ten/core/theme/app_theme.dart';
import 'package:five2ten/core/utils/app_strings.dart';
import 'package:five2ten/core/utils/app_routes.dart';
import 'package:five2ten/core/utils/injection_container.dart' as di;
import 'package:five2ten/core/services/local_storage_service.dart';
import 'package:five2ten/features/auth/presentation/manager/auth_cubit.dart';
import 'package:five2ten/features/user_setup/presentation/manager/user_setup_cubit.dart';
import 'package:five2ten/features/nutrition_scan/presentation/manager/nutrition_scan_cubit.dart';
import 'package:five2ten/features/healthy_recipes/presentation/manager/recipe_cubit.dart';
import 'package:five2ten/features/home/presentation/manager/home_cubit.dart';
import 'package:five2ten/features/profile/presentation/manager/profile_cubit.dart';
import 'package:five2ten/features/games/bonding_game/presentation/manager/bonding_game_cubit.dart';
import 'package:five2ten/core/network/network_cubit.dart';
import 'package:five2ten/features/notifications/presentation/manager/notification_cubit.dart';
import 'package:five2ten/features/game_center/presentation/manager/user_points_cubit.dart';
import 'package:five2ten/features/daily_tasks_game/presentation/manager/daily_tasks_cubit.dart';
import 'package:five2ten/core/widgets/offline_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('ar'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize App Check only if you need it, wrapped in try-catch to not block auth
    // try {
    //   await FirebaseAppCheck.instance.activate(
    //     // ignore: deprecated_member_use
    //     androidProvider: AndroidProvider.playIntegrity,
    //     // ignore: deprecated_member_use
    //     appleProvider: AppleProvider.deviceCheck,
    //   );
    // } catch (e) {
    //   debugPrint("App Check Initialization ignored: $e");
    // }
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Dotenv Load Error: $e");
  }

  await di.init();

  await _initializeServices();

  String langCode = 'ar';
  try {
    final localStorage = di.sl<LocalStorageService>();
    final settings = await localStorage.get('settings', 'language');
    if (settings != null && settings['code'] != null) {
      langCode = settings['code'];
      appLocale.value = Locale(langCode);
    }
  } catch (e) {
    debugPrint("Error loading language: $e");
  }

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  try {
    await di.sl<NotificationService>().init();
  } catch (e) {
    debugPrint("Notification init error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>(create: (_) => di.sl<AuthCubit>()),
            BlocProvider<UserSetupCubit>(
              create: (_) => di.sl<UserSetupCubit>(),
            ),
            BlocProvider<NutritionScanCubit>(
              create: (_) => di.sl<NutritionScanCubit>(),
            ),
            BlocProvider<RecipeCubit>(
              create: (_) => di.sl<RecipeCubit>()..getRecipes(),
            ),
            BlocProvider<HomeCubit>(
              create: (_) => di.sl<HomeCubit>()..loadUserProfile(),
            ),
            BlocProvider<ProfileCubit>(
              create: (_) => di.sl<ProfileCubit>()..getProfile(),
            ),
            BlocProvider<BondingGameCubit>(
              create: (_) => di.sl<BondingGameCubit>()..initGame(),
            ),
            BlocProvider<NetworkCubit>(create: (_) => di.sl<NetworkCubit>()),
            BlocProvider<NotificationCubit>(
              create: (_) => di.sl<NotificationCubit>()..loadNotifications(),
            ),
            BlocProvider<UserPointsCubit>(
              create: (_) => di.sl<UserPointsCubit>()..init(),
            ),
            BlocProvider<DailyTasksCubit>(
              create: (_) => di.sl<DailyTasksCubit>()..init(),
            ),
            // Step Tracker disabled for Play Store compliance
            // BlocProvider<StepTrackerCubit>(
            //   create: (_) => di.sl<StepTrackerCubit>()..init(),
            // ),
          ],
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: MaterialApp(
              title: AppStrings.appName,
              navigatorKey: AppRoutes.navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              scrollBehavior: GlobalScrollBehavior(),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              initialRoute: AppRoutes.splash,
              builder: (context, child) => OfflineWrapper(child: child!),
            ),
          ),
        );
      },
    );
  }
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
