import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/models/garment_model.dart';

// States
abstract class MeasurementsState extends Equatable {
  const MeasurementsState();

  @override
  List<Object?> get props => [];
}

class MeasurementsInitial extends MeasurementsState {
  const MeasurementsInitial();
}

class MeasurementsLoading extends MeasurementsState {
  const MeasurementsLoading();
}

class MeasurementsLoaded extends MeasurementsState {
  final BodyMeasurements? measurements;
  final Map<String, double> sizeRecommendations;
  final Map<String, dynamic> bodyAnalysis;
  final bool isEditing;
  final String selectedUnit;

  const MeasurementsLoaded({
    this.measurements,
    this.sizeRecommendations = const {},
    this.bodyAnalysis = const {},
    this.isEditing = false,
    this.selectedUnit = 'cm',
  });

  MeasurementsLoaded copyWith({
    BodyMeasurements? measurements,
    Map<String, double>? sizeRecommendations,
    Map<String, dynamic>? bodyAnalysis,
    bool? isEditing,
    String? selectedUnit,
  }) {
    return MeasurementsLoaded(
      measurements: measurements ?? this.measurements,
      sizeRecommendations: sizeRecommendations ?? this.sizeRecommendations,
      bodyAnalysis: bodyAnalysis ?? this.bodyAnalysis,
      isEditing: isEditing ?? this.isEditing,
      selectedUnit: selectedUnit ?? this.selectedUnit,
    );
  }

  @override
  List<Object?> get props => [
        measurements,
        sizeRecommendations,
        bodyAnalysis,
        isEditing,
        selectedUnit,
      ];
}

class MeasurementsError extends MeasurementsState {
  final String message;

  const MeasurementsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MeasurementsSaved extends MeasurementsState {
  final BodyMeasurements measurements;
  final String message;

  const MeasurementsSaved({
    required this.measurements,
    required this.message,
  });

  @override
  List<Object?> get props => [measurements, message];
}

class SizeRecommendationsGenerated extends MeasurementsState {
  final Map<String, double> recommendations;
  final String message;

  const SizeRecommendationsGenerated({
    required this.recommendations,
    required this.message,
  });

  @override
  List<Object?> get props => [recommendations, message];
}

// Cubit
class MeasurementsCubit extends Cubit<MeasurementsState> {
  MeasurementsCubit() : super(const MeasurementsInitial());

  Future<void> loadMeasurements(String userId) async {
    emit(const MeasurementsLoading());

    try {
      final customer =
          await ServiceLocator.customerRepository.getCustomer(userId);

      if (customer?.measurements != null) {
        final recommendations =
            await _calculateSizeRecommendations(customer!.measurements!);
        final analysis = _generateBodyAnalysis(customer.measurements!);

        emit(
          MeasurementsLoaded(
            measurements: customer.measurements,
            sizeRecommendations: recommendations,
            bodyAnalysis: analysis,
            selectedUnit: customer.measurements!.unit,
          ),
        );
      } else {
        emit(const MeasurementsLoaded());
      }
    } catch (e) {
      emit(
        MeasurementsError(
          message: 'Failed to load measurements: ${e.toString()}',
        ),
      );
    }
  }

  void startEditing() {
    if (state is MeasurementsLoaded) {
      final currentState = state as MeasurementsLoaded;
      emit(currentState.copyWith(isEditing: true));
    }
  }

  void cancelEditing() {
    if (state is MeasurementsLoaded) {
      final currentState = state as MeasurementsLoaded;
      emit(currentState.copyWith(isEditing: false));
    }
  }

  void updateUnit(String unit) {
    if (state is MeasurementsLoaded) {
      final currentState = state as MeasurementsLoaded;
      emit(currentState.copyWith(selectedUnit: unit));
    }
  }

  Future<void> saveMeasurements({
    required String userId,
    double? height,
    double? weight,
    double? chest,
    double? waist,
    double? hips,
    double? shoulders,
    double? armLength,
    double? inseam,
    double? neck,
    double? bust,
    double? thigh,
    String unit = 'cm',
  }) async {
    emit(const MeasurementsLoading());

    try {
      final measurements = BodyMeasurements(
        height: height,
        weight: weight,
        chest: chest,
        waist: waist,
        hips: hips,
        shoulders: shoulders,
        armLength: armLength,
        inseam: inseam,
        neck: neck,
        bust: bust,
        thigh: thigh,
        unit: unit,
        lastUpdated: DateTime.now(),
      );

      await ServiceLocator.customerRepository
          .updateMeasurements(userId, measurements);

      final recommendations = await _calculateSizeRecommendations(measurements);
      final analysis = _generateBodyAnalysis(measurements);

      emit(
        MeasurementsSaved(
          measurements: measurements,
          message: 'Measurements saved successfully',
        ),
      );

      // Return to loaded state with new data
      emit(
        MeasurementsLoaded(
          measurements: measurements,
          sizeRecommendations: recommendations,
          bodyAnalysis: analysis,
          isEditing: false,
          selectedUnit: unit,
        ),
      );
    } catch (e) {
      emit(
        MeasurementsError(
          message: 'Failed to save measurements: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> generateSizeRecommendations() async {
    if (state is! MeasurementsLoaded ||
        (state as MeasurementsLoaded).measurements == null) {
      emit(const MeasurementsError(message: 'No measurements available'));
      return;
    }

    final currentState = state as MeasurementsLoaded;
    emit(const MeasurementsLoading());

    try {
      final recommendations =
          await _calculateSizeRecommendations(currentState.measurements!);

      emit(
        SizeRecommendationsGenerated(
          recommendations: recommendations,
          message: 'Size recommendations generated',
        ),
      );

      // Return to loaded state with new recommendations
      emit(currentState.copyWith(sizeRecommendations: recommendations));
    } catch (e) {
      emit(
        MeasurementsError(
          message: 'Failed to generate recommendations: ${e.toString()}',
        ),
      );
    }
  }

  Future<Map<String, double>> _calculateSizeRecommendations(
    BodyMeasurements measurements,
  ) async {
    try {
      // Calculate recommendations for different garment types
      final shirtRecommendations =
          await ServiceLocator.mlKitService.calculateSizeRecommendations(
        measurements: measurements,
        garmentType: GarmentType.shirt,
      );

      final dressRecommendations =
          await ServiceLocator.mlKitService.calculateSizeRecommendations(
        measurements: measurements,
        garmentType: GarmentType.dress,
      );

      final trousersRecommendations =
          await ServiceLocator.mlKitService.calculateSizeRecommendations(
        measurements: measurements,
        garmentType: GarmentType.trousers,
      );

      return {
        'shirt_chest': shirtRecommendations['chest'] ?? 0.0,
        'shirt_waist': shirtRecommendations['waist'] ?? 0.0,
        'dress_bust': dressRecommendations['bust'] ?? 0.0,
        'dress_waist': dressRecommendations['waist'] ?? 0.0,
        'dress_hips': dressRecommendations['hips'] ?? 0.0,
        'trousers_waist': trousersRecommendations['waist'] ?? 0.0,
        'trousers_inseam': trousersRecommendations['inseam'] ?? 0.0,
      };
    } catch (e) {
      // Return empty recommendations if calculation fails
      return {};
    }
  }

  Map<String, dynamic> _generateBodyAnalysis(BodyMeasurements measurements) {
    try {
      // Calculate BMI if height and weight are available
      double? bmi;
      if (measurements.height != null && measurements.weight != null) {
        final heightInMeters = measurements.unit == 'cm'
            ? measurements.height! / 100
            : measurements.height! * 0.0254; // inches to meters
        bmi = measurements.weight! / (heightInMeters * heightInMeters);
      }

      // Determine body shape based on measurements
      String bodyShape = 'Unknown';
      if (measurements.chest != null &&
          measurements.waist != null &&
          measurements.hips != null) {
        final chest = measurements.chest!;
        final waist = measurements.waist!;
        final hips = measurements.hips!;

        if ((chest - hips).abs() <= 2 && waist < chest * 0.8) {
          bodyShape = 'Hourglass';
        } else if (chest > hips && chest - hips >= 5) {
          bodyShape = 'Apple';
        } else if (hips > chest && hips - chest >= 5) {
          bodyShape = 'Pear';
        } else if ((chest - hips).abs() <= 5 && waist >= chest * 0.8) {
          bodyShape = 'Rectangle';
        }
      }

      // Generate recommendations based on body shape
      List<String> recommendations = [];
      switch (bodyShape) {
        case 'Hourglass':
          recommendations = [
            'Well-balanced proportions',
            'Most styles will suit you',
            'Emphasize your waist with fitted garments',
          ];
          break;
        case 'Apple':
          recommendations = [
            'Draw attention to your legs',
            'Choose empire waist styles',
            'Avoid clingy fabrics around the midsection',
          ];
          break;
        case 'Pear':
          recommendations = [
            'Balance proportions with shoulder emphasis',
            'A-line and straight cuts work well',
            'Darker colors on bottom, lighter on top',
          ];
          break;
        case 'Rectangle':
          recommendations = [
            'Create curves with strategic styling',
            'Belted styles add definition',
            'Layering creates visual interest',
          ];
          break;
        default:
          recommendations = [
            'Focus on comfort and personal style',
            'Experiment with different fits',
            'Choose quality fabrics',
          ];
      }

      return {
        'bodyShape': bodyShape,
        'bmi': bmi,
        'recommendations': recommendations,
        'measurementCount': _countValidMeasurements(measurements),
        'completionPercentage': _calculateCompletionPercentage(measurements),
      };
    } catch (e) {
      return {
        'bodyShape': 'Unknown',
        'bmi': null,
        'recommendations': ['Unable to generate analysis'],
        'measurementCount': 0,
        'completionPercentage': 0.0,
      };
    }
  }

  int _countValidMeasurements(BodyMeasurements measurements) {
    int count = 0;
    if (measurements.height != null) count++;
    if (measurements.weight != null) count++;
    if (measurements.chest != null) count++;
    if (measurements.waist != null) count++;
    if (measurements.hips != null) count++;
    if (measurements.shoulders != null) count++;
    if (measurements.armLength != null) count++;
    if (measurements.inseam != null) count++;
    if (measurements.neck != null) count++;
    if (measurements.bust != null) count++;
    if (measurements.thigh != null) count++;
    return count;
  }

  double _calculateCompletionPercentage(BodyMeasurements measurements) {
    const totalMeasurements = 11; // Total number of measurement fields
    final validMeasurements = _countValidMeasurements(measurements);
    return (validMeasurements / totalMeasurements) * 100;
  }

  Future<void> importFromVirtualFitting(
    Map<String, double> capturedMeasurements,
    String unit,
  ) async {
    emit(const MeasurementsLoading());

    try {
      final measurements = BodyMeasurements(
        height: capturedMeasurements['height'],
        chest: capturedMeasurements['chest'],
        waist: capturedMeasurements['waist'],
        hips: capturedMeasurements['hips'],
        shoulders: capturedMeasurements['shoulders'],
        unit: unit,
        lastUpdated: DateTime.now(),
      );

      final recommendations = await _calculateSizeRecommendations(measurements);
      final analysis = _generateBodyAnalysis(measurements);

      emit(
        MeasurementsLoaded(
          measurements: measurements,
          sizeRecommendations: recommendations,
          bodyAnalysis: analysis,
          selectedUnit: unit,
        ),
      );
    } catch (e) {
      emit(
        MeasurementsError(
          message: 'Failed to import measurements: ${e.toString()}',
        ),
      );
    }
  }

  void clearError() {
    if (state is MeasurementsError) {
      emit(const MeasurementsInitial());
    }
  }

  Future<void> refreshMeasurements(String userId) async {
    // Refresh without showing loading state
    try {
      final customer =
          await ServiceLocator.customerRepository.getCustomer(userId);

      if (customer?.measurements != null) {
        final recommendations =
            await _calculateSizeRecommendations(customer!.measurements!);
        final analysis = _generateBodyAnalysis(customer.measurements!);

        if (state is MeasurementsLoaded) {
          final currentState = state as MeasurementsLoaded;
          emit(
            currentState.copyWith(
              measurements: customer.measurements,
              sizeRecommendations: recommendations,
              bodyAnalysis: analysis,
              selectedUnit: customer.measurements!.unit,
            ),
          );
        } else {
          emit(
            MeasurementsLoaded(
              measurements: customer.measurements,
              sizeRecommendations: recommendations,
              bodyAnalysis: analysis,
              selectedUnit: customer.measurements!.unit,
            ),
          );
        }
      }
    } catch (e) {
      emit(
        MeasurementsError(
          message: 'Failed to refresh measurements: ${e.toString()}',
        ),
      );
    }
  }
}
