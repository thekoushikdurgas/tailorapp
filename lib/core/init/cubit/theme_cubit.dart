import 'package:tailorapp/core/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(HiveService.getInitialTheme());

  void makelight() {
    HiveService.setLightTheme();
    emit(ThemeMode.light);
  }

  void makeDark() {
    HiveService.setDarkTheme();
    emit(ThemeMode.dark);
  }

  void makeSystem() {
    HiveService.setSystemTheme();
    emit(ThemeMode.system);
  }
}
