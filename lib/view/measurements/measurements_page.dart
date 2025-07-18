import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/models/garment_model.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/init/navigation/navigation_route.dart';

class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({super.key});

  @override
  State<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isEditing = false;
  bool _isSaving = false;

  BodyMeasurements? _currentMeasurements;
  Map<String, double> _sizeRecommendations = {};
  Map<String, dynamic> _bodyAnalysis = {};

  String _selectedUnit = 'cm';

  // Form controllers for manual input
  final Map<String, TextEditingController> _controllers = {
    'height': TextEditingController(),
    'weight': TextEditingController(),
    'chest': TextEditingController(),
    'waist': TextEditingController(),
    'hips': TextEditingController(),
    'shoulders': TextEditingController(),
    'armLength': TextEditingController(),
    'inseam': TextEditingController(),
    'neck': TextEditingController(),
    'bust': TextEditingController(),
    'thigh': TextEditingController(),
  };

  final List<Map<String, dynamic>> _measurementGuides = [
    {
      'name': 'Chest/Bust',
      'description': 'Measure around the fullest part of your chest/bust',
      'instruction': 'Keep the tape parallel to the floor and breathe normally',
      'icon': Icons.straighten,
      'tips': [
        'Wear a well-fitting bra if measuring bust',
        'Don\'t pull the tape too tight',
        'Take measurement at the end of a normal exhale'
      ]
    },
    {
      'name': 'Waist',
      'description': 'Measure around your natural waistline',
      'instruction': 'This is typically the narrowest part of your torso',
      'icon': Icons.radio_button_unchecked,
      'tips': [
        'Stand naturally, don\'t suck in',
        'The tape should be snug but not tight',
        'Measure at your natural waist, not your belt line'
      ]
    },
    {
      'name': 'Hips',
      'description': 'Measure around the fullest part of your hips',
      'instruction': 'Usually 7-9 inches below your natural waistline',
      'icon': Icons.radio_button_unchecked,
      'tips': [
        'Include your buttocks in the measurement',
        'Keep feet together',
        'Ensure tape is parallel to the floor'
      ]
    },
    {
      'name': 'Shoulders',
      'description': 'Measure from shoulder point to shoulder point',
      'instruction':
          'Across the back from the edge of one shoulder to the other',
      'icon': Icons.straighten,
      'tips': [
        'Have someone help with this measurement',
        'Stand naturally with arms at your sides',
        'Measure across the back, not the front'
      ]
    },
    {
      'name': 'Arm Length',
      'description': 'Measure from shoulder to wrist',
      'instruction':
          'With arm slightly bent, measure from shoulder point to wrist bone',
      'icon': Icons.straighten,
      'tips': [
        'Bend your arm slightly at the elbow',
        'Measure the outside of your arm',
        'End at the wrist bone, not the hand'
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMeasurements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMeasurements() async {
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final customer = authState.customerProfile;
        if (customer?.measurements != null) {
          _currentMeasurements = customer!.measurements;
          _populateControllers();
          await _calculateRecommendations();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading measurements: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateControllers() {
    if (_currentMeasurements == null) return;

    final measurements = _currentMeasurements!;
    _selectedUnit = measurements.unit;

    _controllers['height']?.text = measurements.height?.toString() ?? '';
    _controllers['weight']?.text = measurements.weight?.toString() ?? '';
    _controllers['chest']?.text = measurements.chest?.toString() ?? '';
    _controllers['waist']?.text = measurements.waist?.toString() ?? '';
    _controllers['hips']?.text = measurements.hips?.toString() ?? '';
    _controllers['shoulders']?.text = measurements.shoulders?.toString() ?? '';
    _controllers['armLength']?.text = measurements.armLength?.toString() ?? '';
    _controllers['inseam']?.text = measurements.inseam?.toString() ?? '';
    _controllers['neck']?.text = measurements.neck?.toString() ?? '';
    _controllers['bust']?.text = measurements.bust?.toString() ?? '';
    _controllers['thigh']?.text = measurements.thigh?.toString() ?? '';
  }

  Future<void> _calculateRecommendations() async {
    if (_currentMeasurements == null) return;

    try {
      // Calculate size recommendations for different garment types
      final shirtRecommendations =
          await ServiceLocator.mlKitService.calculateSizeRecommendations(
        measurements: _currentMeasurements!,
        garmentType: GarmentType.shirt,
      );

      final dressRecommendations =
          await ServiceLocator.mlKitService.calculateSizeRecommendations(
        measurements: _currentMeasurements!,
        garmentType: GarmentType.dress,
      );

      setState(() {
        _sizeRecommendations = {
          ...shirtRecommendations,
          ...dressRecommendations,
        };
        _bodyAnalysis = {
          'bodyShape': 'Rectangle',
          'bmi': 22.5,
          'recommendations': [
            'Well-proportioned measurements',
            'Most garment styles will suit you well',
            'Consider fitted styles to highlight your balanced proportions'
          ]
        };
      });
    } catch (e) {
      debugPrint('Error calculating recommendations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Tab Bar
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.blue[600],
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: Colors.blue[600],
                    tabs: const [
                      Tab(text: 'Current'),
                      Tab(text: 'Input'),
                      Tab(text: 'Analysis'),
                      Tab(text: 'Guide'),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCurrentMeasurementsTab(),
                      _buildInputTab(),
                      _buildAnalysisTab(),
                      _buildGuideTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Body Measurements',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      actions: [
        if (_currentMeasurements != null && _tabController.index == 0)
          IconButton(
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
              if (_isEditing) {
                _tabController.animateTo(1); // Switch to input tab
              }
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancel' : 'Edit',
          ),
        IconButton(
          onPressed: () => NavigationRoute.openVirtualFitting(context),
          icon: const Icon(Icons.camera_alt),
          tooltip: 'Virtual Measuring',
        ),
      ],
    );
  }

  Widget _buildCurrentMeasurementsTab() {
    if (_currentMeasurements == null) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last Updated Info
          _buildLastUpdatedCard(),
          const SizedBox(height: 20),

          // Measurements Grid
          _buildMeasurementsGrid(),
          const SizedBox(height: 20),

          // Size Recommendations Preview
          if (_sizeRecommendations.isNotEmpty) _buildSizeRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.straighten,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Measurements Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your body measurements to get personalized size recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(1),
                  icon: const Icon(Icons.edit),
                  label: const Text('Manual Input'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => NavigationRoute.openVirtualFitting(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('AR Capture'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedCard() {
    final lastUpdated = _currentMeasurements?.lastUpdated ?? DateTime.now();
    final daysDiff = DateTime.now().difference(lastUpdated).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: daysDiff > 90 ? Colors.orange[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              daysDiff > 90 ? Icons.warning : Icons.check_circle,
              color: daysDiff > 90 ? Colors.orange[700] : Colors.green[700],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Updated',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$daysDiff days ago',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (daysDiff > 90)
                  Text(
                    'Consider updating your measurements',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsGrid() {
    final measurements = _currentMeasurements!;
    final measurementItems = [
      {
        'label': 'Height',
        'value': measurements.height,
        'unit': measurements.unit
      },
      {'label': 'Weight', 'value': measurements.weight, 'unit': 'kg'},
      {
        'label': 'Chest',
        'value': measurements.chest,
        'unit': measurements.unit
      },
      {
        'label': 'Waist',
        'value': measurements.waist,
        'unit': measurements.unit
      },
      {'label': 'Hips', 'value': measurements.hips, 'unit': measurements.unit},
      {
        'label': 'Shoulders',
        'value': measurements.shoulders,
        'unit': measurements.unit
      },
      {
        'label': 'Arm Length',
        'value': measurements.armLength,
        'unit': measurements.unit
      },
      {'label': 'Neck', 'value': measurements.neck, 'unit': measurements.unit},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Measurements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: measurementItems.length,
          itemBuilder: (context, index) {
            final item = measurementItems[index];
            return _buildMeasurementCard(
              item['label'] as String,
              item['value'] as double?,
              item['unit'] as String,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMeasurementCard(String label, double? value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value != null ? value.toStringAsFixed(1) : 'N/A',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (value != null)
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSizeRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
              const Text(
                'Size Recommendations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_sizeRecommendations.containsKey('recommendedChest'))
            _buildRecommendationRow(
              'Shirt Chest',
              _sizeRecommendations['recommendedChest']!,
              _currentMeasurements!.unit,
            ),
          if (_sizeRecommendations.containsKey('recommendedWaist'))
            _buildRecommendationRow(
              'Waist',
              _sizeRecommendations['recommendedWaist']!,
              _currentMeasurements!.unit,
            ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _tabController.animateTo(2),
            child: Row(
              children: [
                Text(
                  'View detailed analysis',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.blue[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unit Selection
          _buildUnitSelector(),
          const SizedBox(height: 24),

          // Input Form
          _buildInputForm(),
          const SizedBox(height: 32),

          // Save Button
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildUnitSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Measurement Unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Centimeters (cm)'),
                  value: 'cm',
                  groupValue: _selectedUnit,
                  onChanged: (value) => setState(() => _selectedUnit = value!),
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Inches (in)'),
                  value: 'in',
                  groupValue: _selectedUnit,
                  onChanged: (value) => setState(() => _selectedUnit = value!),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    final inputFields = [
      {'key': 'height', 'label': 'Height', 'hint': 'Enter your height'},
      {
        'key': 'weight',
        'label': 'Weight (kg)',
        'hint': 'Enter your weight in kg'
      },
      {'key': 'chest', 'label': 'Chest/Bust', 'hint': 'Around fullest part'},
      {'key': 'waist', 'label': 'Waist', 'hint': 'Natural waistline'},
      {'key': 'hips', 'label': 'Hips', 'hint': 'Around fullest part'},
      {
        'key': 'shoulders',
        'label': 'Shoulders',
        'hint': 'Shoulder to shoulder'
      },
      {'key': 'armLength', 'label': 'Arm Length', 'hint': 'Shoulder to wrist'},
      {'key': 'neck', 'label': 'Neck', 'hint': 'Around neck base'},
      {'key': 'inseam', 'label': 'Inseam', 'hint': 'Inner leg length'},
      {'key': 'thigh', 'label': 'Thigh', 'hint': 'Around fullest part'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Measurements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...inputFields.map((field) {
            final key = field['key'] as String;
            final label = field['label'] as String;
            final hint = field['hint'] as String;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: _controllers[key],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: label,
                  hintText: hint,
                  suffixText: key == 'weight' ? 'kg' : _selectedUnit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveMeasurements,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Saving...'),
                ],
              )
            : const Text(
                'Save Measurements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    if (_currentMeasurements == null) {
      return const Center(
        child: Text('No measurements available for analysis'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body Analysis
          if (_bodyAnalysis.isNotEmpty) _buildBodyAnalysisCard(),
          const SizedBox(height: 20),

          // Size Recommendations
          _buildDetailedSizeRecommendations(),
          const SizedBox(height: 20),

          // Fit Suggestions
          if (_bodyAnalysis.containsKey('recommendations'))
            _buildFitSuggestions(),
        ],
      ),
    );
  }

  Widget _buildBodyAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                size: 20,
                color: Colors.purple[600],
              ),
              const SizedBox(width: 8),
              const Text(
                'Body Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_bodyAnalysis.containsKey('bodyShape'))
            _buildAnalysisRow('Body Shape', _bodyAnalysis['bodyShape']),
          if (_bodyAnalysis.containsKey('bmi'))
            _buildAnalysisRow('BMI', _bodyAnalysis['bmi'].toStringAsFixed(1)),
          if (_bodyAnalysis.containsKey('weightCategory'))
            _buildAnalysisRow(
                'Weight Category', _bodyAnalysis['weightCategory']),
        ],
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.purple[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSizeRecommendations() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.straighten,
                size: 20,
                color: Colors.green[600],
              ),
              const SizedBox(width: 8),
              const Text(
                'Detailed Size Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._sizeRecommendations.entries.map((entry) {
            return _buildDetailedRecommendationRow(
              entry.key,
              entry.value,
              _currentMeasurements!.unit,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailedRecommendationRow(
      String key, double value, String unit) {
    String label = key
        .replaceAll('recommended', '')
        .replaceAll('min', 'Min ')
        .replaceAll('max', 'Max ')
        .replaceAll('Length', ' Length')
        .replaceAll('Size', ' Size');

    // Capitalize first letter
    if (label.isNotEmpty) {
      label = label[0].toUpperCase() + label.substring(1);
    }

    MaterialColor color = Colors.blue;
    if (key.startsWith('min')) {
      color = Colors.orange;
    } else if (key.startsWith('max')) {
      color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${value.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitSuggestions() {
    final recommendations =
        _bodyAnalysis['recommendations'] as List<String>? ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb,
                size: 20,
                color: Colors.amber[600],
              ),
              const SizedBox(width: 8),
              const Text(
                'Fit Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Measurement Guide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow these guides for accurate measurements',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ..._measurementGuides.map((guide) {
            return _buildGuideCard(guide);
          }),
        ],
      ),
    );
  }

  Widget _buildGuideCard(Map<String, dynamic> guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  guide['icon'] as IconData,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  guide['name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            guide['description'] as String,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            guide['instruction'] as String,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tips:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...(guide['tips'] as List<String>).map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    if (_tabController.index == 1) {
      return const SizedBox
          .shrink(); // Hide FAB on input tab as we have a save button
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "virtual_measure",
          onPressed: () => NavigationRoute.openVirtualFitting(context),
          backgroundColor: Colors.purple[600],
          tooltip: 'Virtual Measuring',
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
        if (_currentMeasurements != null) ...[
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "edit_measurements",
            onPressed: () {
              setState(() => _isEditing = true);
              _tabController.animateTo(1);
            },
            backgroundColor: Colors.blue[600],
            tooltip: 'Edit Measurements',
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ],
    );
  }

  Future<void> _saveMeasurements() async {
    setState(() => _isSaving = true);

    try {
      final measurements = BodyMeasurements(
        height: double.tryParse(_controllers['height']?.text ?? ''),
        weight: double.tryParse(_controllers['weight']?.text ?? ''),
        chest: double.tryParse(_controllers['chest']?.text ?? ''),
        waist: double.tryParse(_controllers['waist']?.text ?? ''),
        hips: double.tryParse(_controllers['hips']?.text ?? ''),
        shoulders: double.tryParse(_controllers['shoulders']?.text ?? ''),
        armLength: double.tryParse(_controllers['armLength']?.text ?? ''),
        inseam: double.tryParse(_controllers['inseam']?.text ?? ''),
        neck: double.tryParse(_controllers['neck']?.text ?? ''),
        bust: double.tryParse(_controllers['bust']?.text ?? ''),
        thigh: double.tryParse(_controllers['thigh']?.text ?? ''),
        unit: _selectedUnit,
        lastUpdated: DateTime.now(),
      );

      // Save to repository
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        await ServiceLocator.customerRepository.updateMeasurements(
          authState.user.uid,
          measurements,
        );
      }

      setState(() {
        _currentMeasurements = measurements;
        _isEditing = false;
      });

      await _calculateRecommendations();

      // Switch to current measurements tab
      _tabController.animateTo(0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Measurements saved successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving measurements: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
