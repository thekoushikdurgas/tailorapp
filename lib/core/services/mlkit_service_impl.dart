// import 'dart:typed_data';
import 'package:tailorapp/core/services/ai_service.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/models/garment_model.dart';

class MLKitServiceImpl implements MLKitService {
  @override
  Future<Map<String, double>> calculateSizeRecommendations({
    required BodyMeasurements measurements,
    required GarmentType garmentType,
  }) async {
    try {
      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 500));

      final recommendations = <String, double>{};

      switch (garmentType) {
        case GarmentType.shirt:
          recommendations.addAll(_calculateShirtSize(measurements));
          break;
        case GarmentType.dress:
          recommendations.addAll(_calculateDressSize(measurements));
          break;
        case GarmentType.suit:
          recommendations.addAll(_calculateSuitSize(measurements));
          break;
        case GarmentType.jacket:
          recommendations.addAll(_calculateJacketSize(measurements));
          break;
        case GarmentType.trousers:
          recommendations.addAll(_calculateTrousersSize(measurements));
          break;
        case GarmentType.skirt:
          recommendations.addAll(_calculateSkirtSize(measurements));
          break;
        default:
          recommendations.addAll(_calculateGenericSize(measurements));
      }

      return recommendations;
    } catch (e) {
      throw Exception('ML Kit size calculation failed: $e');
    }
  }

  Map<String, double> _calculateShirtSize(BodyMeasurements measurements) {
    final recommendations = <String, double>{};

    if (measurements.chest != null) {
      // Calculate recommended chest size with ease allowance
      recommendations['recommendedChest'] = measurements.chest! + 10.0;
      recommendations['minChest'] = measurements.chest! + 6.0;
      recommendations['maxChest'] = measurements.chest! + 14.0;
    }

    if (measurements.waist != null) {
      recommendations['recommendedWaist'] = measurements.waist! + 8.0;
      recommendations['minWaist'] = measurements.waist! + 4.0;
      recommendations['maxWaist'] = measurements.waist! + 12.0;
    }

    if (measurements.shoulders != null) {
      recommendations['recommendedShoulders'] = measurements.shoulders! + 2.0;
      recommendations['minShoulders'] = measurements.shoulders!;
      recommendations['maxShoulders'] = measurements.shoulders! + 4.0;
    }

    if (measurements.armLength != null) {
      recommendations['recommendedSleeveLength'] =
          measurements.armLength! - 1.0;
      recommendations['minSleeveLength'] = measurements.armLength! - 2.0;
      recommendations['maxSleeveLength'] = measurements.armLength!;
    }

    if (measurements.neck != null) {
      recommendations['recommendedCollarSize'] = measurements.neck! + 1.5;
      recommendations['minCollarSize'] = measurements.neck! + 1.0;
      recommendations['maxCollarSize'] = measurements.neck! + 2.0;
    }

    // Calculate shirt length based on height
    if (measurements.height != null) {
      final shirtLength = measurements.height! * 0.32; // Approximate ratio
      recommendations['recommendedLength'] = shirtLength;
      recommendations['minLength'] = shirtLength - 3.0;
      recommendations['maxLength'] = shirtLength + 3.0;
    }

    return recommendations;
  }

  Map<String, double> _calculateDressSize(BodyMeasurements measurements) {
    final recommendations = <String, double>{};

    if (measurements.bust != null) {
      recommendations['recommendedBust'] = measurements.bust! + 8.0;
      recommendations['minBust'] = measurements.bust! + 4.0;
      recommendations['maxBust'] = measurements.bust! + 12.0;
    }

    if (measurements.waist != null) {
      recommendations['recommendedWaist'] = measurements.waist! + 6.0;
      recommendations['minWaist'] = measurements.waist! + 2.0;
      recommendations['maxWaist'] = measurements.waist! + 10.0;
    }

    if (measurements.hips != null) {
      recommendations['recommendedHips'] = measurements.hips! + 8.0;
      recommendations['minHips'] = measurements.hips! + 4.0;
      recommendations['maxHips'] = measurements.hips! + 12.0;
    }

    if (measurements.height != null) {
      // Different dress lengths
      final kneeLength = measurements.height! * 0.6;
      final midiLength = measurements.height! * 0.7;
      final maxiLength = measurements.height! * 0.9;

      recommendations['kneeLengthDress'] = kneeLength;
      recommendations['midiLengthDress'] = midiLength;
      recommendations['maxiLengthDress'] = maxiLength;
    }

    return recommendations;
  }

  Map<String, double> _calculateSuitSize(BodyMeasurements measurements) {
    final recommendations = <String, double>{};

    // Combine jacket and trouser measurements
    recommendations.addAll(_calculateJacketSize(measurements));
    recommendations.addAll(_calculateTrousersSize(measurements));

    return recommendations;
  }

  Map<String, double> _calculateJacketSize(BodyMeasurements measurements) {
    final recommendations = <String, double>{};

    if (measurements.chest != null) {
      recommendations['recommendedChest'] = measurements.chest! + 12.0;
      recommendations['minChest'] = measurements.chest! + 8.0;
      recommendations['maxChest'] = measurements.chest! + 16.0;
    }

    if (measurements.waist != null) {
      recommendations['recommendedWaist'] = measurements.waist! + 10.0;
      recommendations['minWaist'] = measurements.waist! + 6.0;
      recommendations['maxWaist'] = measurements.waist! + 14.0;
    }

    if (measurements.shoulders != null) {
      recommendations['recommendedShoulders'] = measurements.shoulders! + 3.0;
      recommendations['minShoulders'] = measurements.shoulders! + 1.0;
      recommendations['maxShoulders'] = measurements.shoulders! + 5.0;
    }

    if (measurements.armLength != null) {
      recommendations['recommendedSleeveLength'] =
          measurements.armLength! - 2.0;
      recommendations['minSleeveLength'] = measurements.armLength! - 3.0;
      recommendations['maxSleeveLength'] = measurements.armLength! - 1.0;
    }

    if (measurements.height != null) {
      final jacketLength = measurements.height! * 0.38;
      recommendations['recommendedLength'] = jacketLength;
      recommendations['minLength'] = jacketLength - 4.0;
      recommendations['maxLength'] = jacketLength + 4.0;
    }

    return recommendations;
  }

  Map<String, double> _calculateTrousersSize(BodyMeasurements measurements) {
    final recommendations = <String, double>{};

    if (measurements.waist != null) {
      recommendations['recommendedWaist'] = measurements.waist! + 4.0;
      recommendations['minWaist'] = measurements.waist! + 2.0;
      recommendations['maxWaist'] = measurements.waist! + 6.0;
    }

    if (measurements.hips != null) {
      recommendations['recommendedHips'] = measurements.hips! + 6.0;
      recommendations['minHips'] = measurements.hips! + 2.0;
      recommendations['maxHips'] = measurements.hips! + 10.0;
    }

    if (measurements.thigh != null) {
      recommendations['recommendedThigh'] = measurements.thigh! + 4.0;
      recommendations['minThigh'] = measurements.thigh! + 2.0;
      recommendations['maxThigh'] = measurements.thigh! + 6.0;
    }

    if (measurements.inseam != null) {
      recommendations['recommendedInseam'] = measurements.inseam!;
      recommendations['minInseam'] = measurements.inseam! - 2.0;
      recommendations['maxInseam'] = measurements.inseam! + 2.0;
    }

    return recommendations;
  }

  Map<String, double> _calculateSkirtSize(BodyMeasurements measurements) {
    final recommendations = <String, double>{};

    if (measurements.waist != null) {
      recommendations['recommendedWaist'] = measurements.waist! + 3.0;
      recommendations['minWaist'] = measurements.waist! + 1.0;
      recommendations['maxWaist'] = measurements.waist! + 5.0;
    }

    if (measurements.hips != null) {
      recommendations['recommendedHips'] = measurements.hips! + 6.0;
      recommendations['minHips'] = measurements.hips! + 3.0;
      recommendations['maxHips'] = measurements.hips! + 9.0;
    }

    if (measurements.height != null) {
      // Different skirt lengths
      final miniLength = measurements.height! * 0.35;
      final kneeLength = measurements.height! * 0.45;
      final midiLength = measurements.height! * 0.55;

      recommendations['miniSkirtLength'] = miniLength;
      recommendations['kneeSkirtLength'] = kneeLength;
      recommendations['midiSkirtLength'] = midiLength;
    }

    return recommendations;
  }

  Map<String, double> _calculateGenericSize(BodyMeasurements measurements) {
    final recommendations = <String, double>{};

    if (measurements.chest != null) {
      recommendations['recommendedChest'] = measurements.chest! + 10.0;
    }

    if (measurements.waist != null) {
      recommendations['recommendedWaist'] = measurements.waist! + 8.0;
    }

    if (measurements.hips != null) {
      recommendations['recommendedHips'] = measurements.hips! + 8.0;
    }

    return recommendations;
  }

  // Additional utility methods for body measurement analysis
  Future<Map<String, dynamic>> analyzeBodyProportions(
      BodyMeasurements measurements) async {
    final analysis = <String, dynamic>{};

    if (measurements.chest != null &&
        measurements.waist != null &&
        measurements.hips != null) {
      final chestWaistRatio = measurements.chest! / measurements.waist!;
      final waistHipRatio = measurements.waist! / measurements.hips!;

      analysis['bodyShape'] =
          _determineBodyShape(chestWaistRatio, waistHipRatio);
      analysis['chestWaistRatio'] = chestWaistRatio;
      analysis['waistHipRatio'] = waistHipRatio;
    }

    if (measurements.height != null && measurements.weight != null) {
      final bmi = measurements.weight! /
          ((measurements.height! / 100) * (measurements.height! / 100));
      analysis['bmi'] = bmi;
      analysis['weightCategory'] = _categorizeWeight(bmi);
    }

    analysis['recommendations'] = _generateFitRecommendations(analysis);

    return analysis;
  }

  String _determineBodyShape(double chestWaistRatio, double waistHipRatio) {
    if (chestWaistRatio > 1.3 && waistHipRatio < 0.85) {
      return 'Apple';
    } else if (chestWaistRatio < 1.1 && waistHipRatio > 0.85) {
      return 'Pear';
    } else if (chestWaistRatio >= 1.1 &&
        chestWaistRatio <= 1.3 &&
        waistHipRatio >= 0.8 &&
        waistHipRatio <= 0.9) {
      return 'Hourglass';
    } else {
      return 'Rectangle';
    }
  }

  String _categorizeWeight(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  List<String> _generateFitRecommendations(Map<String, dynamic> analysis) {
    final recommendations = <String>[];
    final bodyShape = analysis['bodyShape'] as String?;

    switch (bodyShape) {
      case 'Apple':
        recommendations.addAll([
          'Consider A-line cuts to balance proportions',
          'Empire waistlines work well',
          'Avoid tight-fitting around the midsection'
        ]);
        break;
      case 'Pear':
        recommendations.addAll([
          'Emphasize the upper body with structured shoulders',
          'A-line skirts and dresses are flattering',
          'Avoid tight-fitting bottoms'
        ]);
        break;
      case 'Hourglass':
        recommendations.addAll([
          'Fitted garments that highlight the waist',
          'Wrap styles work beautifully',
          'Avoid loose, shapeless clothing'
        ]);
        break;
      case 'Rectangle':
        recommendations.addAll([
          'Create curves with fitted waists',
          'Layering adds dimension',
          'Experiment with different silhouettes'
        ]);
        break;
      default:
        recommendations.add('Focus on comfort and personal style preferences');
    }

    return recommendations;
  }
}
