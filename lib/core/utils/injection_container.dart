import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:get_it/get_it.dart';
import 'package:system_5210/features/specialists/data/datasources/specialists_remote_data_source.dart';
import 'package:system_5210/features/specialists/data/datasources/specialists_remote_data_source_impl.dart';
import 'package:system_5210/features/specialists/data/repositories/specialists_repository_impl.dart';
import 'package:system_5210/features/specialists/domain/repositories/specialists_repository.dart';
import 'package:system_5210/features/specialists/domain/usecases/get_specialists.dart';
import 'package:system_5210/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:system_5210/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:system_5210/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:system_5210/features/auth/domain/repositories/auth_repository.dart';
import 'package:system_5210/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/login_with_social_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/register_with_email_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/send_phone_code_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/sign_in_with_phone_code_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/check_user_data_exists_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/check_phone_registered_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/update_display_name_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/check_email_exists_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/verify_password_reset_otp_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/send_email_verification_otp_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/verify_email_otp_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:system_5210/features/auth/domain/usecases/update_email_usecase.dart';
import 'package:system_5210/features/user_setup/data/repositories/user_setup_repository_impl.dart';
import 'package:system_5210/features/user_setup/domain/repositories/user_setup_repository.dart';
import 'package:system_5210/features/user_setup/domain/usecases/save_user_profile_usecase.dart';
import 'package:system_5210/features/user_setup/presentation/manager/user_setup_cubit.dart';
import 'package:system_5210/features/auth/presentation/manager/auth_cubit.dart';

import 'package:system_5210/features/user_setup/domain/usecases/get_user_profile_usecase.dart';
import 'package:system_5210/features/home/presentation/manager/home_cubit.dart';
import 'package:system_5210/features/auth/domain/usecases/logout_usecase.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/core/services/storage_service.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/features/healthy_recipes/data/datasources/recipe_remote_data_source.dart';
import 'package:system_5210/features/healthy_recipes/data/repositories/recipe_repository_impl.dart';
import 'package:system_5210/features/healthy_recipes/domain/repositories/recipe_repository.dart';
import 'package:system_5210/features/healthy_recipes/domain/usecases/get_recipes_usecase.dart';
import 'package:system_5210/features/healthy_recipes/presentation/manager/recipe_cubit.dart';
import 'package:system_5210/features/nutrition_scan/data/repositories/nutrition_repository_impl.dart';
import 'package:system_5210/features/nutrition_scan/domain/repositories/nutrition_repository.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_cubit.dart';
import 'package:system_5210/features/games/balanced_diet/data/datasources/game_remote_data_source.dart';
import 'package:system_5210/features/games/balanced_diet/data/datasources/game_remote_data_source_impl.dart';
import 'package:system_5210/features/games/balanced_diet/data/repositories/game_repository_impl.dart';
import 'package:system_5210/features/games/food_matching/presentation/cubit/food_matching_cubit.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/cubit/game_stats_cubit.dart';
import 'package:system_5210/features/games/balanced_diet/presentation/cubit/balanced_plate_cubit.dart';
import 'package:system_5210/features/games/balanced_diet/domain/repositories/game_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use cases
  sl.registerLazySingleton(() => GetSpecialists(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithSocialUseCase(sl()));
  sl.registerLazySingleton(() => SendPhoneCodeUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithPhoneCodeUseCase(sl()));
  sl.registerLazySingleton(() => CheckUserDataExistsUseCase(sl()));
  sl.registerLazySingleton(() => CheckPhoneRegisteredUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDisplayNameUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckEmailExistsUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPasswordResetOTPUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SendEmailVerificationOTPUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailOTPUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateEmailUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));

  sl.registerLazySingleton(() => SaveUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetRecipesUseCase(sl()));

  // Cubit
  // User Setup
  sl.registerFactory(
    () => UserSetupCubit(saveUserProfileUseCase: sl(), auth: sl()),
  );

  // Home
  sl.registerFactory(
    () => HomeCubit(getUserProfileUseCase: sl(), authRepository: sl()),
  );

  sl.registerFactory(
    () => ProfileCubit(
      getUserProfileUseCase: sl(),
      authRepository: sl(),
      storageService: sl(),
      userSetupRepository: sl(),
    ),
  );

  // Auth
  sl.registerFactory(
    () => AuthCubit(
      loginWithEmailUseCase: sl(),
      registerWithEmailUseCase: sl(),
      loginWithSocialUseCase: sl(),
      sendPhoneCodeUseCase: sl(),
      signInWithPhoneCodeUseCase: sl(),
      checkUserDataExistsUseCase: sl(),
      checkPhoneRegisteredUseCase: sl(),
      updateDisplayNameUseCase: sl(),
      logoutUseCase: sl(),
      checkEmailExistsUseCase: sl(),
      forgotPasswordUseCase: sl(),
      verifyPasswordResetOTPUseCase: sl(),
      resetPasswordUseCase: sl(),
      sendEmailVerificationOTPUseCase: sl(),
      verifyEmailOTPUseCase: sl(),
      updatePasswordUseCase: sl(),
      updateEmailUseCase: sl(),
    ),
  );

  sl.registerFactory(() => NutritionScanCubit(repository: sl()));
  sl.registerFactory(() => RecipeCubit(getRecipesUseCase: sl()));
  sl.registerFactory(() => BalancedPlateCubit(repository: sl(), auth: sl()));
  sl.registerFactory(() => GameStatsCubit(repository: sl(), auth: sl()));
  sl.registerFactory(() => FoodMatchingCubit(repository: sl(), auth: sl()));

  // Repository
  // Repository
  sl.registerLazySingleton<SpecialistsRepository>(
    () => SpecialistsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UserSetupRepository>(
    () => UserSetupRepositoryImpl(firestore: sl()),
  );

  sl.registerLazySingleton<NutritionRepository>(
    () => NutritionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<GameRepository>(
    () => GameRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<SpecialistsRemoteDataSource>(
    () => SpecialistsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl<GoogleSignIn>(),
      firestore: sl(),
      functions: sl(),
    ),
  );
  sl.registerLazySingleton<RecipeRemoteDataSource>(
    () => RecipeRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<GameRemoteDataSource>(
    () => GameRemoteDataSourceImpl(firestore: sl()),
  );

  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(
    () => FirebaseFunctions.instanceFor(region: 'us-central1'),
  ); // Or your region
  sl.registerLazySingleton(() => StorageService());

  // GoogleSignIn 7.x registration
  // TODO: Replace "YOUR_WEB_CLIENT_ID" with your actual Web Client ID from Firebase Console
  // You can find this in the Firebase Console -> Authentication -> Sign-in method -> Google -> Web SDK configuration
  // It usually looks like: "1234567890-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com"
  await GoogleSignIn.instance.initialize(
    serverClientId:
        "438853515029-pvmsfd2hjj6ktu9e3n1r54901l25d2f1.apps.googleusercontent.com",
  );
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);

  // Local Storage
  final localStorage = HiveStorageService();
  await localStorage.init(); // Initialize Hive
  sl.registerLazySingleton<LocalStorageService>(() => localStorage);

  // Re-register NutritionRepository with generic LocalStorage (Note: I need to update NutritionRepositoryImpl first, but I can register it now assuming I'll update the constructor)
}
