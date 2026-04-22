import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'theme.dart';
import 'providers/crop_plan_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/unit_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_layout.dart';
import 'screens/connection_error_screen.dart';
import 'utils/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
  } catch (e) {
    print(ErrorHandler.getReadableError(e));
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        ChangeNotifierProvider(create: (_) => CropPlanProvider()),
      ],
      child: const CropSenseApp(),
    ),
  );
}


class CropSenseApp extends StatelessWidget {
  const CropSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'CropSense AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
        Locale('hi', 'HR'), // Haryanvi
      ],
      locale: localeProvider.locale,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const MainLayout(),
        '/connectionError': (context) => ConnectionErrorScreen(
          onRetry: () => Navigator.pushReplacementNamed(context, '/'),
        ),
      },
    );
  }
}
