import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/models/ai_design_suggestion.dart';
import 'package:tailorapp/core/models/garment_model.dart';

// States
abstract class DesignState extends Equatable {
  const DesignState();

  @override
  List<Object?> get props => [];
}

class DesignInitial extends DesignState {
  const DesignInitial();
}

class DesignLoading extends DesignState {
  const DesignLoading();
}

class DesignLoaded extends DesignState {
  final String selectedGarmentType;
  final Color selectedColor;
  final String selectedFabric;
  final String selectedPattern;
  final List<Offset> designPoints;
  final List<List<Offset>> strokeHistory;
  final String selectedTool;
  final double brushSize;
  final List<AIDesignSuggestion> aiSuggestions;
  final bool isGeneratingAI;
  final bool showAISuggestions;

  const DesignLoaded({
    required this.selectedGarmentType,
    required this.selectedColor,
    required this.selectedFabric,
    required this.selectedPattern,
    required this.designPoints,
    required this.strokeHistory,
    required this.selectedTool,
    required this.brushSize,
    required this.aiSuggestions,
    this.isGeneratingAI = false,
    this.showAISuggestions = false,
  });

  DesignLoaded copyWith({
    String? selectedGarmentType,
    Color? selectedColor,
    String? selectedFabric,
    String? selectedPattern,
    List<Offset>? designPoints,
    List<List<Offset>>? strokeHistory,
    String? selectedTool,
    double? brushSize,
    List<AIDesignSuggestion>? aiSuggestions,
    bool? isGeneratingAI,
    bool? showAISuggestions,
  }) {
    return DesignLoaded(
      selectedGarmentType: selectedGarmentType ?? this.selectedGarmentType,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedFabric: selectedFabric ?? this.selectedFabric,
      selectedPattern: selectedPattern ?? this.selectedPattern,
      designPoints: designPoints ?? this.designPoints,
      strokeHistory: strokeHistory ?? this.strokeHistory,
      selectedTool: selectedTool ?? this.selectedTool,
      brushSize: brushSize ?? this.brushSize,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      isGeneratingAI: isGeneratingAI ?? this.isGeneratingAI,
      showAISuggestions: showAISuggestions ?? this.showAISuggestions,
    );
  }

  @override
  List<Object?> get props => [
        selectedGarmentType,
        selectedColor,
        selectedFabric,
        selectedPattern,
        designPoints,
        strokeHistory,
        selectedTool,
        brushSize,
        aiSuggestions,
        isGeneratingAI,
        showAISuggestions,
      ];
}

class DesignError extends DesignState {
  final String message;

  const DesignError({required this.message});

  @override
  List<Object?> get props => [message];
}

class DesignSaved extends DesignState {
  final String designId;
  final String message;

  const DesignSaved({
    required this.designId,
    required this.message,
  });

  @override
  List<Object?> get props => [designId, message];
}

// Events/Methods for the Cubit
class DesignCubit extends Cubit<DesignState> {
  DesignCubit() : super(const DesignInitial()) {
    _initializeDesign();
  }

  void _initializeDesign() {
    emit(const DesignLoaded(
      selectedGarmentType: 'shirt',
      selectedColor: Colors.blue,
      selectedFabric: 'Cotton',
      selectedPattern: 'Solid',
      designPoints: [],
      strokeHistory: [],
      selectedTool: 'pen',
      brushSize: 3.0,
      aiSuggestions: [],
    ));
  }

  void selectGarmentType(String garmentType) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      emit(currentState.copyWith(selectedGarmentType: garmentType));
    }
  }

  void selectColor(Color color) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      emit(currentState.copyWith(selectedColor: color));
    }
  }

  void selectFabric(String fabric) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      emit(currentState.copyWith(selectedFabric: fabric));
    }
  }

  void selectPattern(String pattern) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      emit(currentState.copyWith(selectedPattern: pattern));
    }
  }

  void selectTool(String tool) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      emit(currentState.copyWith(selectedTool: tool));
    }
  }

  void updateBrushSize(double size) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      emit(currentState.copyWith(brushSize: size));
    }
  }

  void addDesignPoint(Offset point) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      final updatedPoints = List<Offset>.from(currentState.designPoints)
        ..add(point);
      emit(currentState.copyWith(designPoints: updatedPoints));
    }
  }

  void addStroke(List<Offset> stroke) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      final updatedStrokes = List<List<Offset>>.from(currentState.strokeHistory)
        ..add(stroke);
      emit(currentState.copyWith(strokeHistory: updatedStrokes));
    }
  }

  void undoLastStroke() {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      if (currentState.strokeHistory.isNotEmpty) {
        final updatedStrokes =
            List<List<Offset>>.from(currentState.strokeHistory)..removeLast();

        // Rebuild design points from remaining strokes
        final updatedPoints = <Offset>[];
        for (final stroke in updatedStrokes) {
          updatedPoints.addAll(stroke);
          if (stroke.isNotEmpty) {
            updatedPoints.add(Offset.infinite); // Stroke separator
          }
        }

        emit(currentState.copyWith(
          strokeHistory: updatedStrokes,
          designPoints: updatedPoints,
        ));
      }
    }
  }

  void clearCanvas() {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      emit(currentState.copyWith(
        designPoints: [],
        strokeHistory: [],
      ));
    }
  }

  void toggleAISuggestions() {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;
      emit(currentState.copyWith(
        showAISuggestions: !currentState.showAISuggestions,
      ));
    }
  }

  Future<void> generateAIDesign(String userId) async {
    if (state is! DesignLoaded) return;

    final currentState = state as DesignLoaded;
    emit(currentState.copyWith(isGeneratingAI: true, showAISuggestions: true));

    try {
      // Create design prompt
      final prompt = DesignPrompt(
        userInput:
            'Create a ${currentState.selectedGarmentType} in ${currentState.selectedFabric} with ${currentState.selectedPattern} pattern',
        stylePreferences: [
          currentState.selectedPattern,
          currentState.selectedGarmentType
        ],
        preferredColors: [_getColorName(currentState.selectedColor)],
        preferredFabric: currentState.selectedFabric,
        occasion: 'versatile',
        budget: 'medium',
      );

      // Generate AI suggestions
      final suggestions =
          await ServiceLocator.aiService.generateDesignSuggestions(
        prompt: prompt,
        userId: userId,
      );

      emit(currentState.copyWith(
        isGeneratingAI: false,
        aiSuggestions: suggestions,
      ));
    } catch (e) {
      emit(currentState.copyWith(isGeneratingAI: false));
      emit(DesignError(message: 'AI generation failed: ${e.toString()}'));

      // Restore the previous state after showing error
      emit(currentState.copyWith(isGeneratingAI: false));
    }
  }

  void applySuggestion(AIDesignSuggestion suggestion) {
    if (state is DesignLoaded) {
      final currentState = state as DesignLoaded;

      emit(currentState.copyWith(
        selectedColor: suggestion.suggestedColors.isNotEmpty
            ? _parseColor(suggestion.suggestedColors.first)
            : currentState.selectedColor,
        selectedFabric: suggestion.suggestedFabrics.isNotEmpty
            ? suggestion.suggestedFabrics.first
            : currentState.selectedFabric,
        selectedPattern: suggestion.suggestedPatterns.isNotEmpty
            ? suggestion.suggestedPatterns.first
            : currentState.selectedPattern,
        selectedGarmentType:
            suggestion.garmentType ?? currentState.selectedGarmentType,
      ));
    }
  }

  Future<void> saveDesign(String userId, String designName) async {
    if (state is! DesignLoaded) return;

    emit(const DesignLoading());

    try {
      final currentState = state as DesignLoaded;

      // Create garment model
      final garment = GarmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: designName,
        description: 'Custom ${currentState.selectedGarmentType} design',
        type: GarmentType.fromString(currentState.selectedGarmentType),
        colors: [_getColorName(currentState.selectedColor)],
        fabric: currentState.selectedFabric,
        pattern: currentState.selectedPattern,
        measurements: {},
        price: 0.0,
        status: GarmentStatus.draft,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to repository
      await ServiceLocator.garmentRepository.createGarment(garment);

      emit(DesignSaved(
        designId: garment.id,
        message: 'Design saved successfully',
      ));

      // Return to design state
      emit(currentState);
    } catch (e) {
      emit(DesignError(message: 'Failed to save design: ${e.toString()}'));
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.red) return 'red';
    if (color == Colors.green) return 'green';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.teal) return 'teal';
    if (color == Colors.indigo) return 'indigo';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.grey) return 'grey';
    if (color == Colors.black) return 'black';
    return 'blue'; // default
  }

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
        return Colors.grey;
      case 'black':
        return Colors.black;
      default:
        return Colors.blue;
    }
  }
}
