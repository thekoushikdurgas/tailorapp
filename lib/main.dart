import 'package:tailorapp/app.dart';
import 'package:tailorapp/core/init/cache/onboarding/intro_caching.dart';
import 'package:tailorapp/core/init/cubit/theme_cubit.dart';
import 'package:tailorapp/core/init/cache/theme/theme_caching.dart';
import 'package:tailorapp/core/init/localization/project_locales.dart';
import 'package:tailorapp/cubit_observer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'core/init/localization/localization.dart';

Future<void> main() async {
  await LocaleVariables._init();
  await ThemeCaching.init();
  await IntroCaching.init();
  Bloc.observer = CubitObserver();

  runApp(
    EasyLocalization(
      supportedLocales: LocaleVariables._localesList,
      path: LocaleVariables._localesPath,
      fallbackLocale: LocaleVariables._fallBackLocale,
      child: BlocProvider(
        create: (context) => ThemeCubit(),
        child: const MyApp(),
      ),
    ),
  );
}
