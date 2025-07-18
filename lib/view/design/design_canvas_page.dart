import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/view/design/widgets/design_canvas_painter.dart';
import 'package:tailorapp/view/design/widgets/fabric_selector.dart';
import 'package:tailorapp/view/design/widgets/color_palette_widget.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/models/ai_design_suggestion.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/init/navigation/navigation_route.dart';

class DesignCanvasPage extends StatefulWidget {
  const DesignCanvasPage({super.key});

  @override
  State<DesignCanvasPage> createState() => _DesignCanvasPageState();
}

class _DesignCanvasPageState extends State<DesignCanvasPage> {
  String selectedGarmentType = 'shirt';
  Color selectedColor = Colors.blue[700]!;
  String selectedFabric = 'Cotton';
  String selectedPattern = 'Solid';
  bool showAISuggestions = false;
  bool isGeneratingAI = false;
  List<Offset> designPoints = [];
  List<AIDesignSuggestion> aiSuggestions = [];

  // Enhanced drawing tools
  String selectedTool = 'pen';
  double brushSize = 3.0;
  bool isErasing = false;
  List<List<Offset>> strokeHistory = [];
  int currentStrokeIndex = -1;

  final List<String> garmentTypes = [
    'shirt',
    'dress',
    'suit',
    'jacket',
    'trousers',
    'skirt'
  ];

  final List<String> drawingTools = [
    'pen',
    'brush',
    'pencil',
    'marker',
    'eraser'
  ];

  final List<Color> colorPalette = [
    Colors.blue[700]!,
    const Color(0xFF001F3F), // Navy
    Colors.indigo,
    Colors.purple[700]!,
    Colors.teal[700]!,
    Colors.green[700]!,
    Colors.amber[700]!,
    Colors.orange[700]!,
    Colors.red[700]!,
    Colors.brown[700]!,
    Colors.grey[700]!,
    Colors.black87,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Left Panel - Tools and Options
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildLeftPanel(),
          ),

          // Main Canvas Area
          Expanded(
            child: _buildMainCanvas(),
          ),

          // Right Panel - AI Suggestions (conditional)
          if (showAISuggestions) ...[
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: _buildAISuggestionsPanel(),
            ),
          ],
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Create Design',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        IconButton(
          onPressed: () =>
              setState(() => showAISuggestions = !showAISuggestions),
          icon: Icon(
            Icons.auto_awesome,
            color: showAISuggestions ? Colors.blue[600] : Colors.grey[600],
          ),
          tooltip: 'AI Suggestions',
        ),
        IconButton(
          onPressed: _saveDesign,
          icon: const Icon(Icons.save_outlined),
          tooltip: 'Save Design',
        ),
        IconButton(
          onPressed: _exportDesign,
          icon: const Icon(Icons.download_outlined),
          tooltip: 'Export Design',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLeftPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('GARMENT TYPE'),
          const SizedBox(height: 12),
          _buildGarmentTypeSelector(),
          const SizedBox(height: 24),

          _buildSectionTitle('FABRIC'),
          const SizedBox(height: 12),
          FabricSelector(
            selectedFabric: selectedFabric,
            onFabricChanged: (fabric) =>
                setState(() => selectedFabric = fabric),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('COLORS'),
          const SizedBox(height: 12),
          ColorPaletteWidget(
            colors: colorPalette,
            selectedColor: selectedColor,
            onColorChanged: (color) => setState(() => selectedColor = color),
          ),
          const SizedBox(height: 24),

          _buildSectionTitle('PATTERN'),
          const SizedBox(height: 12),
          _buildPatternSelector(),
          const SizedBox(height: 32),

          // Drawing Tools Section
          _buildSectionTitle('DRAWING TOOLS'),
          const SizedBox(height: 12),
          _buildDrawingToolsSelector(),
          const SizedBox(height: 16),
          _buildBrushSizeSelector(),
          const SizedBox(height: 32),

          // AI Generation Section
          _buildAIGenerationSection(),
        ],
      ),
    );
  }

  Widget _buildMainCanvas() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Canvas toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.palette, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Design Canvas - ${selectedGarmentType.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Text(
                  '${designPoints.length} strokes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Main drawing area
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: GestureDetector(
                onPanStart: (details) {
                  // Start new stroke
                  setState(() {
                    strokeHistory.add([]);
                    currentStrokeIndex++;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    final point = details.localPosition;
                    designPoints.add(point);

                    // Add to current stroke
                    if (strokeHistory.isNotEmpty) {
                      strokeHistory.last.add(point);
                    }
                  });
                },
                onPanEnd: (details) {
                  // Add a separator to end stroke
                  setState(() {
                    designPoints.add(Offset.infinite);
                  });
                },
                child: CustomPaint(
                  painter: DesignCanvasPainter(
                    garmentType: selectedGarmentType,
                    selectedColor: selectedColor,
                    selectedFabric: selectedFabric,
                    selectedPattern: selectedPattern,
                    designPoints: designPoints,
                    brushSize: brushSize,
                    selectedTool: selectedTool,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestionsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[600]!, Colors.purple[600]!],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loading or suggestions content
          if (isGeneratingAI) ...[
            _buildLoadingState(),
          ] else if (aiSuggestions.isEmpty) ...[
            _buildEmptyState(),
          ] else ...[
            Expanded(
              child: _buildSuggestionsList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Generating AI Suggestions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is creating personalized designs for your $selectedGarmentType...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.lightbulb_outline,
              size: 28,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Get AI Suggestions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click "Generate" to get personalized design recommendations based on your preferences.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: aiSuggestions.length,
      itemBuilder: (context, index) {
        final suggestion = aiSuggestions[index];
        return _buildSuggestionCard(suggestion);
      },
    );
  }

  Widget _buildSuggestionCard(AIDesignSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with confidence
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(suggestion.confidenceScore * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            suggestion.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Colors and Fabrics
          if (suggestion.suggestedColors.isNotEmpty) ...[
            Text(
              'Colors',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: suggestion.suggestedColors.take(3).map((color) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    color,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[700],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _applySuggestion(suggestion),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply to Design',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIGenerationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              Text(
                'AI Design Assistant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Get personalized design suggestions based on your selections',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isGeneratingAI ? null : _generateAIDesign,
              icon: isGeneratingAI
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(isGeneratingAI ? 'Generating...' : 'Generate Ideas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGarmentTypeSelector() {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: garmentTypes.length,
        itemBuilder: (context, index) {
          final type = garmentTypes[index];
          final isSelected = selectedGarmentType == type;

          return GestureDetector(
            onTap: () => setState(() => selectedGarmentType = type),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.blue[700] : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatternSelector() {
    final patterns = ['Solid', 'Stripes', 'Checkered', 'Polka Dots'];

    return Column(
      children: patterns.map((pattern) {
        final isSelected = selectedPattern == pattern;
        return GestureDetector(
          onTap: () => setState(() => selectedPattern = pattern),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  pattern,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.blue[700] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDrawingToolsSelector() {
    return Column(
      children: drawingTools.map((tool) {
        final isSelected = selectedTool == tool;
        IconData toolIcon;

        switch (tool) {
          case 'pen':
            toolIcon = Icons.edit;
            break;
          case 'brush':
            toolIcon = Icons.brush;
            break;
          case 'pencil':
            toolIcon = Icons.create;
            break;
          case 'marker':
            toolIcon = Icons.format_paint;
            break;
          case 'eraser':
            toolIcon = Icons.auto_fix_off;
            break;
          default:
            toolIcon = Icons.edit;
        }

        return GestureDetector(
          onTap: () => setState(() {
            selectedTool = tool;
            isErasing = tool == 'eraser';
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue[300]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  toolIcon,
                  size: 20,
                  color: isSelected ? Colors.blue[700] : Colors.grey[600],
                ),
                const SizedBox(width: 12),
                Text(
                  tool.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.blue[700] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBrushSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BRUSH SIZE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: brushSize,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                activeColor: Colors.blue[600],
                onChanged: (value) {
                  setState(() {
                    brushSize = value;
                  });
                },
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${brushSize.toInt()}px',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        // Brush preview
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Text(
                'Preview:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: brushSize * 2,
                height: brushSize * 2,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "undo",
          onPressed: _undoStroke,
          backgroundColor: Colors.orange[600],
          tooltip: 'Undo',
          child: const Icon(Icons.undo, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "clear",
          onPressed: _clearCanvas,
          backgroundColor: Colors.red[600],
          tooltip: 'Clear Canvas',
          child: const Icon(Icons.clear, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: "try_on",
          onPressed: _tryOnVirtually,
          backgroundColor: Colors.purple[600],
          tooltip: 'Virtual Try-On',
          child: const Icon(Icons.view_in_ar, color: Colors.white),
        ),
      ],
    );
  }

  void _generateAIDesign() async {
    setState(() {
      isGeneratingAI = true;
      showAISuggestions = true;
    });

    // Store scaffold messenger before async call
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Get current user from auth
      final authState = context.read<AuthCubit>().state;
      String userId = 'guest';
      if (authState is AuthAuthenticated) {
        userId = authState.user.uid;
      }

      // Create design prompt
      final prompt = DesignPrompt(
        userInput:
            'Create a $selectedGarmentType in $selectedFabric with $selectedPattern pattern',
        stylePreferences: [selectedPattern, selectedGarmentType],
        preferredColors: [_getColorName(selectedColor)],
        preferredFabric: selectedFabric,
        occasion: 'versatile',
        budget: 'medium',
      );

      // Generate AI suggestions using the real service
      final suggestions =
          await ServiceLocator.aiService.generateDesignSuggestions(
        prompt: prompt,
        userId: userId,
      );

      if (mounted) {
        setState(() {
          isGeneratingAI = false;
          aiSuggestions = suggestions;
        });

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                '${suggestions.length} AI suggestions generated for $selectedGarmentType'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isGeneratingAI = false);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('AI generation failed: ${e.toString()}'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getColorName(Color color) {
    if (color == Colors.blue[700]) return 'blue';
    if (color == const Color(0xFF001F3F)) return 'navy';
    if (color == Colors.indigo) return 'indigo';
    if (color == Colors.purple[700]) return 'purple';
    if (color == Colors.teal[700]) return 'teal';
    if (color == Colors.green[700]) return 'green';
    if (color == Colors.amber[700]) return 'amber';
    if (color == Colors.orange[700]) return 'orange';
    if (color == Colors.red[700]) return 'red';
    if (color == Colors.brown[700]) return 'brown';
    if (color == Colors.grey[700]) return 'grey';
    if (color == Colors.black87) return 'black';
    return 'blue'; // default
  }

  void _applySuggestion(AIDesignSuggestion suggestion) {
    setState(() {
      // Apply colors if available
      if (suggestion.suggestedColors.isNotEmpty) {
        selectedColor = _parseColor(suggestion.suggestedColors.first);
      }

      // Apply fabric if available
      if (suggestion.suggestedFabrics.isNotEmpty) {
        selectedFabric = suggestion.suggestedFabrics.first;
      }

      // Apply pattern if available
      if (suggestion.suggestedPatterns.isNotEmpty) {
        selectedPattern = suggestion.suggestedPatterns.first;
      }

      // Apply garment type if specified
      if (suggestion.garmentType != null &&
          garmentTypes.contains(suggestion.garmentType)) {
        selectedGarmentType = suggestion.garmentType!;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied: ${suggestion.title}'),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Could implement undo functionality
          },
        ),
      ),
    );
  }

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'navy':
        return const Color(0xFF001F3F);
      case 'blue':
        return Colors.blue[700]!;
      case 'purple':
        return Colors.purple[700]!;
      case 'green':
        return Colors.green[700]!;
      case 'red':
        return Colors.red[700]!;
      case 'black':
        return Colors.black87;
      default:
        return Colors.blue[700]!;
    }
  }

  void _undoStroke() {
    if (strokeHistory.isNotEmpty && currentStrokeIndex >= 0) {
      setState(() {
        strokeHistory.removeAt(currentStrokeIndex);
        currentStrokeIndex--;

        // Rebuild design points from stroke history
        designPoints.clear();
        for (var stroke in strokeHistory) {
          designPoints.addAll(stroke);
          if (stroke.isNotEmpty) {
            designPoints.add(Offset.infinite); // Stroke separator
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stroke undone'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearCanvas() {
    setState(() {
      designPoints.clear();
      strokeHistory.clear();
      currentStrokeIndex = -1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Canvas cleared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _tryOnVirtually() {
    NavigationRoute.openVirtualFitting(context);
  }

  void _saveDesign() {
    // TODO: Implement actual save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Design saved to your profile'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportDesign() {
    // TODO: Implement actual export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Design exported as image'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
