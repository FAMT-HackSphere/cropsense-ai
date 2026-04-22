import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

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
    Locale('en'),
    Locale('hi'),
    Locale('hi', 'HR'),
    Locale('mr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CropSense AI'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @soilInput.
  ///
  /// In en, this message translates to:
  /// **'Soil Input'**
  String get soilInput;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @enterSoilData.
  ///
  /// In en, this message translates to:
  /// **'Enter Soil Data'**
  String get enterSoilData;

  /// No description provided for @predictButton.
  ///
  /// In en, this message translates to:
  /// **'Predict'**
  String get predictButton;

  /// No description provided for @landArea.
  ///
  /// In en, this message translates to:
  /// **'Land Area (Acres)'**
  String get landArea;

  /// No description provided for @soilType.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soilType;

  /// No description provided for @organicCarbon.
  ///
  /// In en, this message translates to:
  /// **'Organic Carbon (%)'**
  String get organicCarbon;

  /// No description provided for @soilMoisture.
  ///
  /// In en, this message translates to:
  /// **'Soil Moisture (%)'**
  String get soilMoisture;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @resetData.
  ///
  /// In en, this message translates to:
  /// **'Reset Input Data'**
  String get resetData;

  /// No description provided for @locationAutofillMsg.
  ///
  /// In en, this message translates to:
  /// **'Soil profile auto-filled based on location. You can adjust values if needed.'**
  String get locationAutofillMsg;

  /// No description provided for @expectedYield.
  ///
  /// In en, this message translates to:
  /// **'Expected Yield'**
  String get expectedYield;

  /// No description provided for @totalRequired.
  ///
  /// In en, this message translates to:
  /// **'Total Required'**
  String get totalRequired;

  /// No description provided for @nitrogen.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N)'**
  String get nitrogen;

  /// No description provided for @phosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P)'**
  String get phosphorus;

  /// No description provided for @potassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K)'**
  String get potassium;

  /// No description provided for @ph.
  ///
  /// In en, this message translates to:
  /// **'Soil pH'**
  String get ph;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region / District'**
  String get region;

  /// No description provided for @startNewPrediction.
  ///
  /// In en, this message translates to:
  /// **'Start New Recommendation'**
  String get startNewPrediction;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View Crop History'**
  String get viewHistory;

  /// No description provided for @recentSummary.
  ///
  /// In en, this message translates to:
  /// **'Recent Summary'**
  String get recentSummary;

  /// No description provided for @lastRecommendedCrop.
  ///
  /// In en, this message translates to:
  /// **'Last Recommended Crop'**
  String get lastRecommendedCrop;

  /// No description provided for @profitEstimate.
  ///
  /// In en, this message translates to:
  /// **'Profit Estimate'**
  String get profitEstimate;

  /// No description provided for @noHistoryMsg.
  ///
  /// In en, this message translates to:
  /// **'No previous recommendations yet.'**
  String get noHistoryMsg;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Your intelligent crop planning assistant.\nEnter your soil data once — get a complete\nfarm plan powered by AI.'**
  String get appDescription;

  /// No description provided for @pickLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Location'**
  String get pickLocation;

  /// No description provided for @generateRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Generate Recommendation'**
  String get generateRecommendation;

  /// No description provided for @weatherProfile.
  ///
  /// In en, this message translates to:
  /// **'Weather Profile'**
  String get weatherProfile;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @rainfall.
  ///
  /// In en, this message translates to:
  /// **'Rainfall'**
  String get rainfall;

  /// No description provided for @sectionSoilNutrients.
  ///
  /// In en, this message translates to:
  /// **'1. Soil Nutrients (Required)'**
  String get sectionSoilNutrients;

  /// No description provided for @sectionSoilProperties.
  ///
  /// In en, this message translates to:
  /// **'2. Soil Properties'**
  String get sectionSoilProperties;

  /// No description provided for @sectionFarmContext.
  ///
  /// In en, this message translates to:
  /// **'3. Farm Context'**
  String get sectionFarmContext;

  /// No description provided for @autoFill.
  ///
  /// In en, this message translates to:
  /// **'Auto-Fill'**
  String get autoFill;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommendation Result'**
  String get resultsTitle;

  /// No description provided for @startOver.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get startOver;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// No description provided for @suitability.
  ///
  /// In en, this message translates to:
  /// **'Suitability'**
  String get suitability;

  /// No description provided for @tabExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get tabExplanation;

  /// No description provided for @tabFertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Plans'**
  String get tabFertilizer;

  /// No description provided for @tabEconomics.
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get tabEconomics;

  /// No description provided for @tabRotation.
  ///
  /// In en, this message translates to:
  /// **'Rotation'**
  String get tabRotation;

  /// No description provided for @scientificReasoning.
  ///
  /// In en, this message translates to:
  /// **'Scientific Reasoning'**
  String get scientificReasoning;

  /// No description provided for @saveToHistory.
  ///
  /// In en, this message translates to:
  /// **'Save Option to Crop History'**
  String get saveToHistory;

  /// No description provided for @estCultivationCost.
  ///
  /// In en, this message translates to:
  /// **'Est. Cultivation Cost (₹)'**
  String get estCultivationCost;

  /// No description provided for @marketPricePerTon.
  ///
  /// In en, this message translates to:
  /// **'Market Price per ton (₹)'**
  String get marketPricePerTon;

  /// No description provided for @calculateProfit.
  ///
  /// In en, this message translates to:
  /// **'Calculate Profit'**
  String get calculateProfit;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @nextBestCrop.
  ///
  /// In en, this message translates to:
  /// **'Next Best Crop'**
  String get nextBestCrop;

  /// No description provided for @benefit.
  ///
  /// In en, this message translates to:
  /// **'Benefit'**
  String get benefit;

  /// No description provided for @perHectare.
  ///
  /// In en, this message translates to:
  /// **'Per Hectare'**
  String get perHectare;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop History'**
  String get historyTitle;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get deleteRecord;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @connectingToServer.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server...'**
  String get connectingToServer;

  /// No description provided for @couldNotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server.'**
  String get couldNotReachServer;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @smartCropPlanningSystem.
  ///
  /// In en, this message translates to:
  /// **'Smart Crop Planning System'**
  String get smartCropPlanningSystem;
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
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'hi':
      {
        switch (locale.countryCode) {
          case 'HR':
            return AppLocalizationsHiHr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
