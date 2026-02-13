import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

import 'package:flutter_dotenv/flutter_dotenv.dart';

ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 1. تأكد من تهيئة Firebase أولاً
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  // 2. ثم قم بتهيئة الـ Dependency Injection
  await di.init();

  // 3. Load Saved Language
  try {
    final localStorage = di.sl<LocalStorageService>();
    final settings = await localStorage.get('settings', 'language');
    if (settings != null && settings['code'] != null) {
      appLocale.value = Locale(settings['code']);
    }
  } catch (e) {
    debugPrint("Error loading language: $e");
  }

  runApp(const MyApp());
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
          ],

          child: GestureDetector(
            onTap: () {
              // Unfocus keyboard when tapping anywhere outside a text field
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: MaterialApp(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRoutes.onGenerateRoute,
            ),
          ),
        );
      },
    );
  }
}
