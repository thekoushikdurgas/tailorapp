import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorapp/app.dart';
import 'package:tailorapp/core/cubit/theme_cubit.dart';
import 'package:tailorapp/core/cubit/user_data_cubit.dart';
import 'package:tailorapp/core/services/hive_service.dart';
import 'package:tailorapp/core/localization/project_locales.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/cubit_observer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'supabase_options.dart';
part 'core/localization/localization.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase for database operations only
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  await LocaleVariables._init();
  await HiveService.init(); // This replaces ThemeCaching.init() and IntroCaching.init()

  // Setup production services - database only (no auth)
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
            create: (context) => serviceLocator<UserDataCubit>(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
