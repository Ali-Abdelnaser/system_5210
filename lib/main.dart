import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/core/services/notification_service.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/firebase_options.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_strings.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:system_5210/core/utils/injection_container.dart' as di;
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';
import 'package:system_5210/features/user_setup/presentation/manager/user_setup_cubit.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_cubit.dart';
import 'package:system_5210/features/healthy_recipes/presentation/manager/recipe_cubit.dart';
import 'package:system_5210/features/home/presentation/manager/home_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/features/games/bonding_game/presentation/manager/bonding_game_cubit.dart';
import 'package:system_5210/core/network/network_cubit.dart';
import 'package:system_5210/features/notifications/presentation/manager/notification_cubit.dart';
import 'package:system_5210/core/widgets/offline_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('ar'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Dotenv Load Error: $e");
  }

  // تهيئة الـ Dependency Injection
  await di.init();

  // تهيئة الخدمات بشكل متوازي (Async) لتسريع الـ Splash
  _initializeServices();

  // تحميل اللغة المحفوظة
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
  // تهيئة الفايربيز
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  // تهيئة الإشعارات وجدولة التذكير اليومي
  try {
    final notificationService = di.sl<NotificationService>();
    await notificationService.init();

    // جدولة الإشعار اليومي باللغة المناسبة
    final currentLocale = appLocale.value;
    final l10n = await AppLocalizations.delegate.load(currentLocale);

    await notificationService.scheduleDailyReminder(
      title: l10n.streakNotificationTitle,
      body: l10n.streakNotificationMessage,
    );
  } catch (e) {
    debugPrint("Notification Scheduling Error: $e");
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
          ],
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: MaterialApp(
              title: AppStrings.appName,
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
