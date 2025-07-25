import 'package:tailorapp/core/services/hive_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RadioCubit extends Cubit<String> {
  RadioCubit() : super(HiveService.getInitialRadio());

  void changeValue(String radio) {
    emit(radio);
  }
}
