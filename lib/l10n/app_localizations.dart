import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your healthy journey'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @launchNow.
  ///
  /// In en, this message translates to:
  /// **'Launch Now'**
  String get launchNow;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @newHeroQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get newHeroQuestion;

  /// No description provided for @registerHere.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get registerHere;

  /// No description provided for @newHeroTitleBoy.
  ///
  /// In en, this message translates to:
  /// **'New Member!'**
  String get newHeroTitleBoy;

  /// No description provided for @newHeroTitleGirl.
  ///
  /// In en, this message translates to:
  /// **'New Member!'**
  String get newHeroTitleGirl;

  /// No description provided for @heroNameBoy.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get heroNameBoy;

  /// No description provided for @heroNameGirl.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get heroNameGirl;

  /// No description provided for @heroAgeBoy.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get heroAgeBoy;

  /// No description provided for @heroAgeGirl.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get heroAgeGirl;

  /// No description provided for @parentsEmail.
  ///
  /// In en, this message translates to:
  /// **'Parents Email'**
  String get parentsEmail;

  /// No description provided for @startAdventure.
  ///
  /// In en, this message translates to:
  /// **'Get Started Now!'**
  String get startAdventure;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boy;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girl;

  /// No description provided for @onboardingTitle5.
  ///
  /// In en, this message translates to:
  /// **'5 Servings of Fruits & Veggies'**
  String get onboardingTitle5;

  /// No description provided for @onboardingDesc5.
  ///
  /// In en, this message translates to:
  /// **'Your body energy! Eat 5 servings of colorful fruits and vegetables every day to stay strong.'**
  String get onboardingDesc5;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'2 Hours of Screen Time Only'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'TV and mobile time shouldn\'t exceed two hours, so your eyes and mind stay sharp and bright.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'1 Hour of Exercise & Play'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Move, play, and run for an entire hour every day. Exercise makes your heart and muscles strong!'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle0.
  ///
  /// In en, this message translates to:
  /// **'0 Sugar & Fizzy Drinks'**
  String get onboardingTitle0;

  /// No description provided for @onboardingDesc0.
  ///
  /// In en, this message translates to:
  /// **'Stay away from sugar and soft drinks, and stick with water and natural juices for better health.'**
  String get onboardingDesc0;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! Enter your email and we will send a code to reset your password.'**
  String get forgotPasswordDesc;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Phone'**
  String get verifyPhoneTitle;

  /// No description provided for @verifyEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your email.\nPlease enter it below.'**
  String get verifyEmailDesc;

  /// No description provided for @verifyPhoneDesc.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to your phone.\nPlease enter it below.'**
  String get verifyPhoneDesc;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code? Resend'**
  String get didntReceiveCode;

  /// No description provided for @verificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationTitle;

  /// No description provided for @verificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to your device'**
  String get verificationDesc;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @emailVerificationLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your email. Open the link in your inbox, then tap Continue below.'**
  String get emailVerificationLinkSent;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @whoAreYou.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get whoAreYou;

  /// No description provided for @welcomeHero.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeHero;

  /// No description provided for @chooseRole.
  ///
  /// In en, this message translates to:
  /// **'Choose your role'**
  String get chooseRole;

  /// No description provided for @chooseRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your role to start the journey'**
  String get chooseRoleDesc;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @parent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get parent;

  /// No description provided for @parentDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor progress & settings'**
  String get parentDesc;

  /// No description provided for @parentRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor progress & settings'**
  String get parentRoleDesc;

  /// No description provided for @roleChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get roleChild;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @childDesc.
  ///
  /// In en, this message translates to:
  /// **'Play, learn & have fun'**
  String get childDesc;

  /// No description provided for @childRoleDesc.
  ///
  /// In en, this message translates to:
  /// **'Play, learn & have fun'**
  String get childRoleDesc;

  /// No description provided for @discoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Discover!'**
  String get discoveryTitle;

  /// No description provided for @favoriteHobbyQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your favorite sport or hobby?'**
  String get favoriteHobbyQuestion;

  /// No description provided for @hobbyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Football, Drawing, Swimming...'**
  String get hobbyHint;

  /// No description provided for @heroFeelingQuestion.
  ///
  /// In en, this message translates to:
  /// **'What makes you feel motivated?'**
  String get heroFeelingQuestion;

  /// No description provided for @heroHint.
  ///
  /// In en, this message translates to:
  /// **'Doing exercise, eating fruit, helping others...'**
  String get heroHint;

  /// No description provided for @favoriteFoodQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s the tastiest healthy food you love?'**
  String get favoriteFoodQuestion;

  /// No description provided for @foodHint.
  ///
  /// In en, this message translates to:
  /// **'Apples, salad, chicken...'**
  String get foodHint;

  /// No description provided for @superPowerQuestion.
  ///
  /// In en, this message translates to:
  /// **'If you had a super power, what would it be?'**
  String get superPowerQuestion;

  /// No description provided for @powerHint.
  ///
  /// In en, this message translates to:
  /// **'Flying, super strength, super speed...'**
  String get powerHint;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @parentInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get parentInfoTitle;

  /// No description provided for @healthGoalQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your health goal for your family?'**
  String get healthGoalQuestion;

  /// No description provided for @goalHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Eat more veggies, stay active...'**
  String get goalHint;

  /// No description provided for @challengeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s the hardest part about staying healthy?'**
  String get challengeQuestion;

  /// No description provided for @challengeHint.
  ///
  /// In en, this message translates to:
  /// **'Time, picky eaters, sweets...'**
  String get challengeHint;

  /// No description provided for @activityQuestion.
  ///
  /// In en, this message translates to:
  /// **'What\'s your family\'s favorite active way to play?'**
  String get activityQuestion;

  /// No description provided for @activityHint.
  ///
  /// In en, this message translates to:
  /// **'Walking, dancing, playing ball...'**
  String get activityHint;

  /// No description provided for @specialInfoQuestion.
  ///
  /// In en, this message translates to:
  /// **'Anything else you want to share with us?'**
  String get specialInfoQuestion;

  /// No description provided for @specialHint.
  ///
  /// In en, this message translates to:
  /// **'Any tips or notes about your members...'**
  String get specialHint;

  /// No description provided for @continueToProfile.
  ///
  /// In en, this message translates to:
  /// **'Continue to Profile'**
  String get continueToProfile;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @setupDesc.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself and your family members.'**
  String get setupDesc;

  /// No description provided for @yourInfo.
  ///
  /// In en, this message translates to:
  /// **'Your Info'**
  String get yourInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @yourChildren.
  ///
  /// In en, this message translates to:
  /// **'Your Children ({count})'**
  String yourChildren(Object count);

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChild;

  /// No description provided for @noChildrenAdded.
  ///
  /// In en, this message translates to:
  /// **'No children added yet.'**
  String get noChildrenAdded;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get finishSetup;

  /// No description provided for @addChildError.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one child to continue.'**
  String get addChildError;

  /// No description provided for @childName.
  ///
  /// In en, this message translates to:
  /// **'Child Name'**
  String get childName;

  /// No description provided for @childAge.
  ///
  /// In en, this message translates to:
  /// **'Child Age'**
  String get childAge;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @chronicDiseases.
  ///
  /// In en, this message translates to:
  /// **'Chronic Diseases?'**
  String get chronicDiseases;

  /// No description provided for @specifyDetails.
  ///
  /// In en, this message translates to:
  /// **'Please specify details...'**
  String get specifyDetails;

  /// No description provided for @notesHabits.
  ///
  /// In en, this message translates to:
  /// **'Notes / Eating Habits'**
  String get notesHabits;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Likes, dislikes, allergies...'**
  String get notesHint;

  /// No description provided for @saveChild.
  ///
  /// In en, this message translates to:
  /// **'Save Child'**
  String get saveChild;

  /// No description provided for @hasCondition.
  ///
  /// In en, this message translates to:
  /// **'Has Condition'**
  String get hasCondition;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} Years'**
  String yearsOld(Object age);

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Your Relationship'**
  String get relationship;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @guardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get guardian;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City / Area'**
  String get city;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get height;

  /// No description provided for @favoriteHero.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Favorite Character'**
  String get favoriteHero;

  /// No description provided for @familyPriority.
  ///
  /// In en, this message translates to:
  /// **'Family Health Priority'**
  String get familyPriority;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get navGame;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning,'**
  String get goodMorning;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @dailyTarget.
  ///
  /// In en, this message translates to:
  /// **'Daily Targets'**
  String get dailyTarget;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @dailyTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Tip'**
  String get dailyTipTitle;

  /// No description provided for @funZone.
  ///
  /// In en, this message translates to:
  /// **'Fun Zone'**
  String get funZone;

  /// No description provided for @promoTip1.
  ///
  /// In en, this message translates to:
  /// **'An apple a day keeps the doctor away!'**
  String get promoTip1;

  /// No description provided for @promoTip2.
  ///
  /// In en, this message translates to:
  /// **'Water is the best fuel for your brain!'**
  String get promoTip2;

  /// No description provided for @promoTip3.
  ///
  /// In en, this message translates to:
  /// **'1 hour of play makes you stronger!'**
  String get promoTip3;

  /// No description provided for @promoTip4.
  ///
  /// In en, this message translates to:
  /// **'Sleep well to grow tall and smart!'**
  String get promoTip4;

  /// No description provided for @promoTip5.
  ///
  /// In en, this message translates to:
  /// **'Brush your teeth to keep them bright!'**
  String get promoTip5;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} Day Streak!'**
  String dayStreak(int count);

  /// No description provided for @mysteryMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mystery Mission ⚡'**
  String get mysteryMissionTitle;

  /// No description provided for @mysteryMissionSubTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal your challenge!'**
  String get mysteryMissionSubTitle;

  /// No description provided for @summaryCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep going!'**
  String get summaryCardTitle;

  /// No description provided for @summaryCardSubTitle.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} targets completed'**
  String summaryCardSubTitle(int completed, int total);

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @missionComplete.
  ///
  /// In en, this message translates to:
  /// **'Mission Complete! 🎉'**
  String get missionComplete;

  /// No description provided for @missionHydrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Hydration Target'**
  String get missionHydrationTitle;

  /// No description provided for @missionHydrationText.
  ///
  /// In en, this message translates to:
  /// **'Drink a big glass of water right now!'**
  String get missionHydrationText;

  /// No description provided for @missionEnergyTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy Burst'**
  String get missionEnergyTitle;

  /// No description provided for @missionEnergyText.
  ///
  /// In en, this message translates to:
  /// **'Do 10 jumping jacks!'**
  String get missionEnergyText;

  /// No description provided for @missionSnackTitle.
  ///
  /// In en, this message translates to:
  /// **'Snack Attack'**
  String get missionSnackTitle;

  /// No description provided for @missionSnackText.
  ///
  /// In en, this message translates to:
  /// **'Eat a piece of fruit if you\'re hungry.'**
  String get missionSnackText;

  /// No description provided for @missionLoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Spread Love'**
  String get missionLoveTitle;

  /// No description provided for @missionLoveText.
  ///
  /// In en, this message translates to:
  /// **'Give a high-five or hug to someone nearby!'**
  String get missionLoveText;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @reduceThis.
  ///
  /// In en, this message translates to:
  /// **'Reduce this!'**
  String get reduceThis;

  /// No description provided for @logTime.
  ///
  /// In en, this message translates to:
  /// **'Log Time'**
  String get logTime;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @drinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get drinks;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @servingsProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} / {total} Servings'**
  String servingsProgress(Object count, Object total);

  /// No description provided for @drinksProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} Sugary Drinks'**
  String drinksProgress(Object count);

  /// No description provided for @durationFormat.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String durationFormat(Object h, Object m);

  /// No description provided for @minutesFormat.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String minutesFormat(Object m);

  /// No description provided for @heroName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get heroName;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteChild.
  ///
  /// In en, this message translates to:
  /// **'Delete Child'**
  String get deleteChild;

  /// No description provided for @deleteChildConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this child profile?'**
  String get deleteChildConfirm;

  /// No description provided for @congratulationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulationsTitle;

  /// No description provided for @setupComplete.
  ///
  /// In en, this message translates to:
  /// **'Setup Complete'**
  String get setupComplete;

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'You are ready to start your healthy journey!'**
  String get readyToStart;

  /// No description provided for @specialistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Specialists Directory'**
  String get specialistsTitle;

  /// No description provided for @specialistsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for doctor or specialty...'**
  String get specialistsSearchHint;

  /// No description provided for @onlineConsultation.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineConsultation;

  /// No description provided for @clinicsLocation.
  ///
  /// In en, this message translates to:
  /// **'Clinic Locations'**
  String get clinicsLocation;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get nameRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhone;

  /// No description provided for @phoneSignInNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Sign in with phone is not available yet. Please use email.'**
  String get phoneSignInNotAvailable;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! 🌟'**
  String get welcomeBack;

  /// No description provided for @welcomeMission.
  ///
  /// In en, this message translates to:
  /// **'Welcome to our MISSION! 🚀'**
  String get welcomeMission;

  /// No description provided for @callNow.
  ///
  /// In en, this message translates to:
  /// **'Call Now'**
  String get callNow;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @workingDays.
  ///
  /// In en, this message translates to:
  /// **'Working Days'**
  String get workingDays;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @availableOnline.
  ///
  /// In en, this message translates to:
  /// **'Available Online'**
  String get availableOnline;

  /// No description provided for @certificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates & Training'**
  String get certificates;

  /// No description provided for @yearsExp.
  ///
  /// In en, this message translates to:
  /// **'Years Experience'**
  String get yearsExp;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @scanIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s in your food?'**
  String get scanIntroTitle;

  /// No description provided for @scanIntroDesc.
  ///
  /// In en, this message translates to:
  /// **'Discover nutrition facts and health warnings with one touch. Your smart assistant for healthy nutrition.'**
  String get scanIntroDesc;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works?'**
  String get howItWorks;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Capture Label'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the nutrition facts table'**
  String get step1Desc;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Smart Analysis'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'AI reads and analyzes the ingredients'**
  String get step2Desc;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Detailed Report'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Get health scores and child safety warnings'**
  String get step3Desc;

  /// No description provided for @startScan.
  ///
  /// In en, this message translates to:
  /// **'Start Scanning Now'**
  String get startScan;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View Scan History'**
  String get viewHistory;

  /// No description provided for @serverErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Issue'**
  String get serverErrorTitle;

  /// No description provided for @serverErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we\'re facing a minor issue with the server. We\'ll be back online soon!'**
  String get serverErrorMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @scanResultTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Food Analysis'**
  String get scanResultTitle;

  /// No description provided for @healthReport.
  ///
  /// In en, this message translates to:
  /// **'Health Report'**
  String get healthReport;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthScore;

  /// No description provided for @nutritionFacts.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts'**
  String get nutritionFacts;

  /// No description provided for @childSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent & Child Guide'**
  String get childSafetyTitle;

  /// No description provided for @safeForChildren.
  ///
  /// In en, this message translates to:
  /// **'Safe for Children'**
  String get safeForChildren;

  /// No description provided for @notSafeForChildren.
  ///
  /// In en, this message translates to:
  /// **'Safety Warning'**
  String get notSafeForChildren;

  /// No description provided for @suitableForAge.
  ///
  /// In en, this message translates to:
  /// **'Suitable for ages {range}'**
  String suitableForAge(String range);

  /// No description provided for @containsHarmfulStuff.
  ///
  /// In en, this message translates to:
  /// **'Contains ingredients that may not suit children'**
  String get containsHarmfulStuff;

  /// No description provided for @positives.
  ///
  /// In en, this message translates to:
  /// **'Positives'**
  String get positives;

  /// No description provided for @negatives.
  ///
  /// In en, this message translates to:
  /// **'Negatives'**
  String get negatives;

  /// No description provided for @harmfulIngredients.
  ///
  /// In en, this message translates to:
  /// **'Harmful Ingredients'**
  String get harmfulIngredients;

  /// No description provided for @medicalAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Expert Advice'**
  String get medicalAdviceTitle;

  /// No description provided for @saveReport.
  ///
  /// In en, this message translates to:
  /// **'Save to History'**
  String get saveReport;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: Results are AI-generated estimates and do not replace professional medical advice.'**
  String get disclaimer;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// No description provided for @totalFat.
  ///
  /// In en, this message translates to:
  /// **'Total Fat'**
  String get totalFat;

  /// No description provided for @saturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Sat. Fat'**
  String get saturatedFat;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// No description provided for @sodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodium;

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbohydrates;

  /// No description provided for @gram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get gram;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @excellentChoice.
  ///
  /// In en, this message translates to:
  /// **'Excellent Choice'**
  String get excellentChoice;

  /// No description provided for @goodChoice.
  ///
  /// In en, this message translates to:
  /// **'Good Choice'**
  String get goodChoice;

  /// No description provided for @averageChoice.
  ///
  /// In en, this message translates to:
  /// **'Average Choice'**
  String get averageChoice;

  /// No description provided for @unhealthyChoice.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy Choice'**
  String get unhealthyChoice;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report saved successfully'**
  String get saveSuccess;

  /// No description provided for @deleteReport.
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get deleteReport;

  /// No description provided for @deleteReportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this report?'**
  String get deleteReportConfirm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @recentScansTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get recentScansTitle;

  /// No description provided for @noScansTitle.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get noScansTitle;

  /// No description provided for @noScansDesc.
  ///
  /// In en, this message translates to:
  /// **'Start scanning products to see them here'**
  String get noScansDesc;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editChildren.
  ///
  /// In en, this message translates to:
  /// **'Edit Children'**
  String get editChildren;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutAppTitle.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutAppTitle;

  /// No description provided for @rateFeedback.
  ///
  /// In en, this message translates to:
  /// **'Rate & Feedback'**
  String get rateFeedback;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @generalPreferences.
  ///
  /// In en, this message translates to:
  /// **'General Preferences'**
  String get generalPreferences;

  /// No description provided for @chooseOne.
  ///
  /// In en, this message translates to:
  /// **'Choose One...'**
  String get chooseOne;

  /// No description provided for @selectField.
  ///
  /// In en, this message translates to:
  /// **'Select {field}'**
  String selectField(Object field);

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @verifyNewEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'You will need to verify your new email address.'**
  String get verifyNewEmailDesc;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get noEmail;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @healthPriorityHealthyEating.
  ///
  /// In en, this message translates to:
  /// **'Healthy Eating'**
  String get healthPriorityHealthyEating;

  /// No description provided for @healthPriorityPhysicalActivity.
  ///
  /// In en, this message translates to:
  /// **'Physical Activity'**
  String get healthPriorityPhysicalActivity;

  /// No description provided for @healthPriorityReducedScreenTime.
  ///
  /// In en, this message translates to:
  /// **'Reduced Screen Time'**
  String get healthPriorityReducedScreenTime;

  /// No description provided for @healthPriorityZeroSoda.
  ///
  /// In en, this message translates to:
  /// **'Zero Soda'**
  String get healthPriorityZeroSoda;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @chooseImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose Image Source'**
  String get chooseImageSource;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @noSpecialists.
  ///
  /// In en, this message translates to:
  /// **'No specialists available'**
  String get noSpecialists;

  /// No description provided for @noSpecialistsFound.
  ///
  /// In en, this message translates to:
  /// **'No specialists found'**
  String get noSpecialistsFound;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get supportTitle;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqUpdateProfileQ.
  ///
  /// In en, this message translates to:
  /// **'How do I update my profile?'**
  String get faqUpdateProfileQ;

  /// No description provided for @faqUpdateProfileA.
  ///
  /// In en, this message translates to:
  /// **'You can update your personal information by visiting the Profile tab and clicking \'Edit Profile\'.'**
  String get faqUpdateProfileA;

  /// No description provided for @faqManageChildrenQ.
  ///
  /// In en, this message translates to:
  /// **'How do I add or manage children?'**
  String get faqManageChildrenQ;

  /// No description provided for @faqManageChildrenA.
  ///
  /// In en, this message translates to:
  /// **'Go to the Profile tab and tap \'Edit Children\' to manage profiles or add new ones.'**
  String get faqManageChildrenA;

  /// No description provided for @faqDataSecurityQ.
  ///
  /// In en, this message translates to:
  /// **'How do I know my data is secure?'**
  String get faqDataSecurityQ;

  /// No description provided for @faqDataSecurityA.
  ///
  /// In en, this message translates to:
  /// **'Yes, we use advanced encryption to protect your data.'**
  String get faqDataSecurityA;

  /// No description provided for @contactSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupportTitle;

  /// No description provided for @emailSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupportTitle;

  /// No description provided for @liveChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChatTitle;

  /// No description provided for @liveChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with a representative'**
  String get liveChatSubtitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Family Health App'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Designed to help families track health, nutrition, and activities for a happier, healthier lifestyle.'**
  String get appDescription;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Family Heath Team'**
  String get companyName;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'© 2026 All Rights Reserved'**
  String get allRightsReserved;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @infoCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'1. Information Collection'**
  String get infoCollectionTitle;

  /// No description provided for @infoCollectionDesc.
  ///
  /// In en, this message translates to:
  /// **'We collect personal information such as name, email, and password to create your account. We also collect profile data (like age, weight, height) to provide personalized health insights.'**
  String get infoCollectionDesc;

  /// No description provided for @howWeUseInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Information'**
  String get howWeUseInfoTitle;

  /// No description provided for @howWeUseInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to improve app functionality, track health progress, and provide tailored recommendations. We do not sell your personal data to third parties.'**
  String get howWeUseInfoDesc;

  /// No description provided for @dataSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Data Security'**
  String get dataSecurityTitle;

  /// No description provided for @dataSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'We implement industry-standard security measures to protect your data. All sensitive information is encrypted during transmission and storage.'**
  String get dataSecurityDesc;

  /// No description provided for @childrenPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Children\'s Privacy'**
  String get childrenPrivacyTitle;

  /// No description provided for @childrenPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'This app is designed for families. While we may collect data about children, it is provided and managed by the parent/guardian account holder.'**
  String get childrenPrivacyDesc;

  /// No description provided for @userRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'5. User Rights'**
  String get userRightsTitle;

  /// No description provided for @userRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, update, or delete your personal information at any time through the app settings or by contacting support.'**
  String get userRightsDesc;

  /// No description provided for @policyChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'6. Changes to Policy'**
  String get policyChangesTitle;

  /// No description provided for @policyChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.'**
  String get policyChangesDesc;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: February 2026'**
  String get lastUpdated;

  /// No description provided for @healthyRecipes.
  ///
  /// In en, this message translates to:
  /// **'Healthy Recipes'**
  String get healthyRecipes;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @preparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation Steps'**
  String get preparation;

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch Video Tutorial'**
  String get watchVideo;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search for healthy recipes...'**
  String get searchRecipes;

  /// No description provided for @noRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
