import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/models/shared_models.dart';
import 'package:tailorapp/core/models/ai_design_suggestion.dart';
import 'package:tailorapp/core/models/garment_model.dart';
// import 'package:tailorapp/core/services/ai_service.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/product/enum/route_enum.dart';

class StylePreferenceSetupScreen extends StatefulWidget {
  const StylePreferenceSetupScreen({super.key});

  @override
  State<StylePreferenceSetupScreen> createState() =>
      _StylePreferenceSetupScreenState();
}

class _StylePreferenceSetupScreenState
    extends State<StylePreferenceSetupScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  bool _isLoading = false;
  String? _analysisProgress;
  Map<String, dynamic>? _styleAnalysisResult;
  String? _generatedStyleDNA;

  // Style preference data
  final List<String> _selectedStyles = [];
  String? _selectedBodyType;
  final List<Color> _selectedColors = [];
  final List<String> _selectedOccasions = [];
  final List<String> _selectedFabrics = [];
  String? _budgetRange;
  String? _fitPreference;

  final List<String> _styleOptions = [
    'Classic',
    'Modern',
    'Minimalist',
    'Vintage',
    'Bohemian',
    'Elegant',
    'Casual',
    'Formal',
  ];

  final List<String> _bodyTypes = [
    'Slim',
    'Athletic',
    'Curvy',
    'Plus Size',
    'Petite',
    'Tall',
  ];

  final List<Color> _colorOptions = [
    Colors.black,
    Colors.white,
    Colors.grey[600]!,
    Colors.blue[600]!,
    Colors.red[600]!,
    Colors.green[600]!,
    Colors.purple[600]!,
    Colors.orange[600]!,
  ];

  final List<String> _occasionOptions = [
    'Work/Professional',
    'Casual Daily',
    'Evening Events',
    'Formal Occasions',
    'Wedding',
    'Travel',
    'Sports/Active',
    'Creative/Artistic',
  ];

  final List<String> _fabricOptions = [
    'Cotton',
    'Silk',
    'Wool',
    'Linen',
    'Polyester',
    'Cashmere',
    'Denim',
    'Leather',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: const Text(
          'Style Preferences',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _currentStep < 5 ? null : _completeSetup,
              child: Text(
                'Complete',
                style: TextStyle(
                  color: _currentStep < 5 ? Colors.grey[400] : Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStyleSelectionStep(),
                _buildBodyTypeStep(),
                _buildColorPreferenceStep(),
                _buildOccasionStep(),
                _buildFabricPreferenceStep(),
                _buildBudgetAndFitStep(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(6, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? Colors.blue[600]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Step ${_currentStep + 1} of 6',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelectionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What styles do you love?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that appeal to you. We\'ll use AI to understand your style DNA.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: _styleOptions.length,
              itemBuilder: (context, index) {
                final style = _styleOptions[index];
                final isSelected = _selectedStyles.contains(style);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedStyles.remove(style);
                      } else {
                        _selectedStyles.add(style);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[600] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        style,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your body type?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us recommend the most flattering fits and cuts.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // 3D Silhouette Visualization Preview
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple[50]!, Colors.blue[50]!],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSilhouettePreview(
                  'Slim',
                  Icons.person,
                  Colors.blue[400]!,
                ),
                _buildSilhouettePreview(
                  'Athletic',
                  Icons.fitness_center,
                  Colors.green[400]!,
                ),
                _buildSilhouettePreview(
                  'Curvy',
                  Icons.woman,
                  Colors.purple[400]!,
                ),
                _buildSilhouettePreview(
                  'Plus Size',
                  Icons.person,
                  Colors.orange[400]!,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Enhanced Body Type Selection
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemCount: _bodyTypes.length,
              itemBuilder: (context, index) {
                final bodyType = _bodyTypes[index];
                final isSelected = _selectedBodyType == bodyType;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBodyType = bodyType;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[50] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue[200]!.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue[600]
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getBodyTypeIcon(bodyType),
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 24,
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.green[500],
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          bodyType,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? Colors.blue[800] : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getBodyTypeDescription(bodyType),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilhouettePreview(String type, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          type,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  IconData _getBodyTypeIcon(String bodyType) {
    switch (bodyType) {
      case 'Slim':
        return Icons.person;
      case 'Athletic':
        return Icons.fitness_center;
      case 'Curvy':
        return Icons.woman;
      case 'Plus Size':
        return Icons.accessibility;
      case 'Petite':
        return Icons.person_pin;
      case 'Tall':
        return Icons.height;
      default:
        return Icons.person;
    }
  }

  String _getBodyTypeDescription(String bodyType) {
    switch (bodyType) {
      case 'Slim':
        return 'Lean build';
      case 'Athletic':
        return 'Muscular frame';
      case 'Curvy':
        return 'Defined waist';
      case 'Plus Size':
        return 'Fuller figure';
      case 'Petite':
        return 'Smaller frame';
      case 'Tall':
        return 'Longer proportions';
      default:
        return 'Body type';
    }
  }

  Widget _buildColorPreferenceStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your color palette',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose colors you love to wear. Our AI will suggest complementary combinations.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Enhanced Color Wheel Section
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[50]!, Colors.grey[100]!],
              ),
            ),
            child: Stack(
              children: [
                // Color wheel background
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.indigo,
                          Colors.purple,
                          Colors.red,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                // Center indicator
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.palette,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ),
                // Instructions overlay
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    'Tap colors below or explore the wheel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Enhanced Color Selection Grid
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Colors',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _colorOptions.length,
                    itemBuilder: (context, index) {
                      final color = _colorOptions[index];
                      final isSelected = _selectedColors.contains(color);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedColors.remove(color);
                            } else {
                              _selectedColors.add(color);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.black : Colors.grey[300]!,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Stack(
                            children: [
                              if (isSelected)
                                Center(
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              // Color name overlay
                              Positioned(
                                bottom: 4,
                                left: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getColorName(color),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Color psychology info
          if (_selectedColors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getColorPsychologyMessage(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.black) return 'Black';
    if (color == Colors.white) return 'White';
    if (color == Colors.grey[600]) return 'Grey';
    if (color == Colors.blue[600]) return 'Blue';
    if (color == Colors.red[600]) return 'Red';
    if (color == Colors.green[600]) return 'Green';
    if (color == Colors.purple[600]) return 'Purple';
    if (color == Colors.orange[600]) return 'Orange';
    return 'Color';
  }

  String _getColorPsychologyMessage() {
    final hasBlack = _selectedColors.contains(Colors.black);
    final hasBlue = _selectedColors.contains(Colors.blue[600]);
    final hasRed = _selectedColors.contains(Colors.red[600]);
    final hasGreen = _selectedColors.contains(Colors.green[600]);

    if (hasBlack && hasBlue) {
      return 'Classic and confident - perfect for professional settings';
    } else if (hasRed && hasBlack) {
      return 'Bold and powerful - great for making a statement';
    } else if (hasGreen && hasBlue) {
      return 'Calm and trustworthy - excellent for versatile wardrobes';
    } else if (hasBlue) {
      return 'Blue conveys trust, stability, and professionalism';
    } else if (hasRed) {
      return 'Red projects confidence, energy, and passion';
    } else if (hasGreen) {
      return 'Green represents balance, harmony, and growth';
    } else {
      return 'Your color choices reflect your unique personality';
    }
  }

  Widget _buildOccasionStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What occasions do you dress for?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the occasions you need clothes for most often.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _occasionOptions.length,
              itemBuilder: (context, index) {
                final occasion = _occasionOptions[index];
                final isSelected = _selectedOccasions.contains(occasion);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedOccasions.remove(occasion);
                        } else {
                          _selectedOccasions.add(occasion);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.purple[50] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.purple[600]!
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getOccasionIcon(occasion),
                            color: isSelected
                                ? Colors.purple[600]
                                : Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              occasion,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.purple[800]
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Colors.purple[600],
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabricPreferenceStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fabric preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose materials you enjoy wearing. We\'ll recommend the best options.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Fabric Categories
          SizedBox(
            height: 80,
            child: Row(
              children: [
                _buildFabricCategory('Natural', Icons.eco, Colors.green[400]!),
                const SizedBox(width: 12),
                _buildFabricCategory(
                  'Synthetic',
                  Icons.science,
                  Colors.blue[400]!,
                ),
                const SizedBox(width: 12),
                _buildFabricCategory(
                  'Blends',
                  Icons.merge_type,
                  Colors.purple[400]!,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Enhanced Fabric Selection with Texture Simulation
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _fabricOptions.length,
              itemBuilder: (context, index) {
                final fabric = _fabricOptions[index];
                final isSelected = _selectedFabrics.contains(fabric);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedFabrics.remove(fabric);
                      } else {
                        _selectedFabrics.add(fabric);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green[600] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected ? Colors.green[600]! : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    Colors.green[200]!.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Stack(
                      children: [
                        // Texture simulation background
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: _getFabricTextureGradient(fabric),
                          ),
                        ),

                        // Content overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isSelected
                                ? Colors.green[600]!.withValues(alpha: 0.9)
                                : Colors.white.withValues(alpha: 0.9),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getFabricIcon(fabric),
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  fabric,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getFabricDescription(fabric),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isSelected) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabricCategory(String name, IconData icon, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getFabricTextureGradient(String fabric) {
    switch (fabric) {
      case 'Cotton':
        return const LinearGradient(
          colors: [Color(0xFFF5F5DC), Color(0xFFE6E6FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Silk':
        return const LinearGradient(
          colors: [Color(0xFFFFF8DC), Color(0xFFE0E0E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Wool':
        return const LinearGradient(
          colors: [Color(0xFFF0F0F0), Color(0xFFD3D3D3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Linen':
        return const LinearGradient(
          colors: [Color(0xFFFAF0E6), Color(0xFFE6E6FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Denim':
        return const LinearGradient(
          colors: [Color(0xFF4169E1), Color(0xFF6495ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Leather':
        return const LinearGradient(
          colors: [Color(0xFF8B4513), Color(0xFFA0522D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFE0E0E0), Color(0xFFF0F0F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getFabricIcon(String fabric) {
    switch (fabric) {
      case 'Cotton':
        return Icons.local_florist;
      case 'Silk':
        return Icons.auto_awesome;
      case 'Wool':
        return Icons.pets;
      case 'Linen':
        return Icons.grass;
      case 'Polyester':
        return Icons.science;
      case 'Cashmere':
        return Icons.diamond;
      case 'Denim':
        return Icons.checkroom;
      case 'Leather':
        return Icons.shield;
      default:
        return Icons.texture;
    }
  }

  String _getFabricDescription(String fabric) {
    switch (fabric) {
      case 'Cotton':
        return 'Breathable & comfortable';
      case 'Silk':
        return 'Luxurious & smooth';
      case 'Wool':
        return 'Warm & insulating';
      case 'Linen':
        return 'Cool & airy';
      case 'Polyester':
        return 'Durable & wrinkle-free';
      case 'Cashmere':
        return 'Soft & premium';
      case 'Denim':
        return 'Sturdy & casual';
      case 'Leather':
        return 'Elegant & durable';
      default:
        return 'Quality material';
    }
  }

  Widget _buildBudgetAndFitStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Final preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us tailor recommendations to your budget and fit preferences.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Budget Range
          const Text(
            'Budget Range',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['Under \$100', '\$100-\$300', '\$300-\$500', '\$500+']
                .map(
                  (budget) => _buildSelectionChip(
                    budget,
                    _budgetRange == budget,
                    () => setState(() => _budgetRange = budget),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 32),

          // Fit Preference
          const Text(
            'Fit Preference',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: ['Slim Fit', 'Regular Fit', 'Loose Fit']
                .map(
                  (fit) => _buildSelectionChip(
                    fit,
                    _fitPreference == fit,
                    () => setState(() => _fitPreference = fit),
                  ),
                )
                .toList(),
          ),

          const Spacer(),

          // AI Analysis Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue[50]!, Colors.purple[50]!],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[600]!,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.auto_awesome,
                        color: Colors.blue[600],
                        size: 24,
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoading ? 'Analyzing...' : 'AI Style Analysis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        _analysisProgress ??
                            (_isLoading
                                ? 'Processing your style preferences...'
                                : 'Ready to generate your unique style DNA'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[600] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < 5 ? _nextStep : _completeSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentStep < 5 ? 'Next' : 'Complete Setup',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getOccasionIcon(String occasion) {
    switch (occasion) {
      case 'Work/Professional':
        return Icons.business_center;
      case 'Casual Daily':
        return Icons.weekend;
      case 'Evening Events':
        return Icons.nightlife;
      case 'Formal Occasions':
        return Icons.event;
      case 'Wedding':
        return Icons.favorite;
      case 'Travel':
        return Icons.flight;
      case 'Sports/Active':
        return Icons.fitness_center;
      case 'Creative/Artistic':
        return Icons.palette;
      default:
        return Icons.style;
    }
  }

  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _analysisProgress = 'Saving your style preferences...';
    });

    try {
      // Get current user from auth cubit
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('User not authenticated');
      }

      final userId = authState.user.id;

      // Convert color selections to hex strings for storage
      final colorStrings = _selectedColors
          .map((color) => '#${color.toARGB32().toRadixString(16).substring(2)}')
          .toList();

      // Create style preferences object
      final stylePreferences = StylePreferences(
        preferredStyles: _selectedStyles,
        preferredColors: colorStrings,
        preferredFabrics: _selectedFabrics,
        dislikedColors: const [], // Will be enhanced in future iterations
        dislikedFabrics: const [], // Will be enhanced in future iterations
        fitPreference: _fitPreference,
        budgetRange: _budgetRange,
        occasions: _selectedOccasions,
        customPreferences: {
          'bodyType': _selectedBodyType,
          'setupCompleted': true,
          'setupDate': DateTime.now().toIso8601String(),
          'version': '1.0',
        },
      );

      setState(() {
        _analysisProgress = 'Analyzing your style preferences...';
      });

      // Perform AI style analysis
      await _performAIStyleAnalysis(stylePreferences);

      setState(() {
        _analysisProgress = 'Generating your unique Style DNA...';
      });

      // Generate Style DNA based on analysis
      await _generateStyleDNA(stylePreferences);

      setState(() {
        _analysisProgress = 'Saving your profile...';
      });

      // Save encrypted preferences to Firestore
      await _saveEncryptedPreferences(userId, stylePreferences);

      setState(() {
        _analysisProgress = 'Creating personalized recommendations...';
      });

      // Generate initial design recommendations
      await _generateInitialRecommendations(userId, stylePreferences);

      setState(() {
        _isLoading = false;
        _analysisProgress = null;
      });

      // Show completion dialog and navigate
      if (mounted) {
        _showCompletionDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _analysisProgress = null;
      });

      DebugLogger.error('Failed to complete style setup: $e');

      if (mounted) {
        _showErrorDialog(
          'Failed to save your style preferences. Please try again.',
        );
      }
    }
  }

  Future<void> _performAIStyleAnalysis(StylePreferences preferences) async {
    try {
      final aiService = ServiceLocator.aiService;

      // Analyze color preferences using AI
      if (_selectedColors.isNotEmpty) {
        final colorAnalysis = await aiService.generateColorPalette(
          garmentType: 'general',
          occasion: _selectedOccasions.isNotEmpty
              ? _selectedOccasions.first
              : 'casual',
          preferredColors: preferences.preferredColors,
        );

        DebugLogger.info(
          'AI Color Analysis completed: ${colorAnalysis.length} colors suggested',
        );
      }

      // Analyze fabric suitability
      if (_selectedFabrics.isNotEmpty && _selectedOccasions.isNotEmpty) {
        for (final fabric in _selectedFabrics.take(2)) {
          final fabricAnalysis = await aiService.analyzeFabricSuitability(
            fabricType: fabric,
            garmentType: GarmentType.shirt, // Default analysis
            occasion: _selectedOccasions.first,
          );

          DebugLogger.info(
            'Fabric analysis for $fabric: Score ${fabricAnalysis['suitabilityScore']}',
          );
        }
      }

      _styleAnalysisResult = {
        'analysisComplete': true,
        'timestamp': DateTime.now().toIso8601String(),
        'preferences_analyzed': {
          'styles': _selectedStyles.length,
          'colors': _selectedColors.length,
          'fabrics': _selectedFabrics.length,
          'occasions': _selectedOccasions.length,
        },
      };

      DebugLogger.info('AI style analysis completed successfully');
    } catch (e) {
      DebugLogger.error('AI style analysis failed: $e');
      // Continue without AI analysis
      _styleAnalysisResult = {
        'analysisComplete': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> _generateStyleDNA(StylePreferences preferences) async {
    try {
      // Create a comprehensive style profile analysis
      final styleDNA = _createStyleDNA(preferences);
      _generatedStyleDNA = styleDNA;

      DebugLogger.info('Style DNA generated: ${styleDNA.substring(0, 50)}...');
    } catch (e) {
      DebugLogger.error('Style DNA generation failed: $e');
      _generatedStyleDNA = 'Classic-Modern-Versatile'; // Fallback
    }
  }

  String _createStyleDNA(StylePreferences preferences) {
    final dnaComponents = <String>[];

    // Analyze style preferences
    if (_selectedStyles.contains('Classic')) dnaComponents.add('CL');
    if (_selectedStyles.contains('Modern')) dnaComponents.add('MD');
    if (_selectedStyles.contains('Minimalist')) dnaComponents.add('MN');
    if (_selectedStyles.contains('Vintage')) dnaComponents.add('VT');
    if (_selectedStyles.contains('Bohemian')) dnaComponents.add('BH');
    if (_selectedStyles.contains('Elegant')) dnaComponents.add('EL');

    // Analyze color preferences
    final hasNeutrals = _selectedColors.any(
      (color) =>
          color == Colors.black ||
          color == Colors.white ||
          color == Colors.grey[600],
    );
    final hasBrights = _selectedColors.any(
      (color) =>
          color == Colors.red[600] ||
          color == Colors.blue[600] ||
          color == Colors.green[600],
    );

    if (hasNeutrals) dnaComponents.add('NT');
    if (hasBrights) dnaComponents.add('BR');

    // Analyze fit preference
    switch (_fitPreference) {
      case 'Slim Fit':
        dnaComponents.add('SF');
        break;
      case 'Regular Fit':
        dnaComponents.add('RF');
        break;
      case 'Loose Fit':
        dnaComponents.add('LF');
        break;
    }

    // Create final DNA string
    return dnaComponents.isEmpty
        ? 'VERSATILE-CLASSIC'
        : dnaComponents.join('-');
  }

  Future<void> _generateInitialRecommendations(
    String userId,
    StylePreferences preferences,
  ) async {
    try {
      final aiService = ServiceLocator.aiService;

      // Create a design prompt based on preferences
      final prompt = DesignPrompt(
        userInput:
            'Create personalized designs based on style preferences setup',
        stylePreferences: _selectedStyles,
        preferredColors: preferences.preferredColors,
        occasion:
            _selectedOccasions.isNotEmpty ? _selectedOccasions.first : 'casual',
        bodyMeasurements:
            null, // Will be filled later when measurements are taken
        budget: _budgetRange ?? 'medium',
        additionalRequirements: {
          'bodyType': _selectedBodyType,
          'fitPreference': _fitPreference,
          'preferredFabrics': _selectedFabrics,
        },
      );

      // Generate design suggestions (limit to 2 for setup)
      final suggestions = await aiService.generateDesignSuggestions(
        prompt: prompt,
        userId: userId,
      );

      DebugLogger.info(
        'Generated ${suggestions.length} initial design recommendations',
      );

      // Store suggestions for later use (could be saved to preferences)
      if (suggestions.isNotEmpty) {
        final recommendationIds = suggestions.map((s) => s.id).toList();
        DebugLogger.info('Initial recommendations: $recommendationIds');
      }
    } catch (e) {
      DebugLogger.error('Initial recommendations generation failed: $e');
      // Continue without recommendations
    }
  }

  Future<void> _saveEncryptedPreferences(
    String userId,
    StylePreferences preferences,
  ) async {
    try {
      // Enhance preferences with AI analysis results
      final enhancedPreferences = preferences.copyWith(
        customPreferences: {
          ...preferences.customPreferences ?? {},
          'aiAnalysis': _styleAnalysisResult,
          'styleDNA': _generatedStyleDNA,
          'setupCompleted': true,
          'setupDate': DateTime.now().toIso8601String(),
          'version': '2.0', // Updated version with AI analysis
        },
      );

      // For now, we'll save directly. In future iterations, we can add encryption
      final customerRepository = ServiceLocator.customerRepository;
      await customerRepository.updateStylePreferences(
        userId,
        enhancedPreferences,
      );

      DebugLogger.info(
        'Enhanced style preferences saved successfully for user: $userId',
      );
    } catch (e) {
      DebugLogger.error('Failed to save style preferences: $e');
      rethrow;
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            const Text('Style Profile Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your AI style DNA has been generated successfully!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            if (_generatedStyleDNA != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Style DNA:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _generatedStyleDNA!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'We\'ve analyzed your preferences and are ready to provide personalized recommendations.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RouteEnum.customerHome.rawValue);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Explore Your Wardrobe',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            const Text('Setup Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
