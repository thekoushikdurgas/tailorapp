import 'package:firebase_core/firebase_core.dart';
import 'package:tailorapp/app.dart';
import 'package:tailorapp/core/init/cubit/theme_cubit.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/core/init/localization/project_locales.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/services/auth_service.dart';
import 'package:tailorapp/cubit_observer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
part 'core/init/localization/localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Firebase
  await Firebase.initializeApp();

  await LocaleVariables._init();
  await HiveService
      .init(); // This replaces ThemeCaching.init() and IntroCaching.init()

  // Setup production services with authentication
  await ServiceLocator.setupServiceLocator();

  Bloc.observer = CubitObserver();

  runApp(
    EasyLocalization(
      supportedLocales: LocaleVariables._localesList,
      path: LocaleVariables._localesPath,
      fallbackLocale: LocaleVariables._fallBackLocale,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
          BlocProvider(
            create: (context) => AuthCubit(
              authService: serviceLocator<AuthService>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
