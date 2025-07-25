import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/models/garment_model.dart';

class VirtualFittingPage extends StatefulWidget {
  const VirtualFittingPage({super.key});

  @override
  State<VirtualFittingPage> createState() => _VirtualFittingPageState();
}

class _VirtualFittingPageState extends State<VirtualFittingPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessingMeasurements = false;
  bool _showMeasurementGuide = true;
  bool _cameraPermissionGranted = false;
  String? _cameraError;

  // ML Kit components
  late PoseDetector _poseDetector;
  List<Pose> _poses = [];
  bool _isDetectingPose = false;

  late TabController _tabController;
  int _currentStep = 0;

  final List<String> _measurementSteps = [
    'Stand straight against a wall',
    'Arms at your sides',
    'Keep phone steady',
    'Full body in frame',
    'Stay still for measurement',
  ];

  final Map<String, double> _measurements = {};
  final Map<String, double> _sizeRecommendations = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializePoseDetector();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tabController.dispose();
    _poseDetector.close();
    super.dispose();
  }

  void _initializePoseDetector() {
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        setState(() {
          _cameras = cameras;
          _cameraPermissionGranted = true;
        });
        await _initializeCamera();
      } else {
        setState(() {
          _cameraError = 'No cameras available on this device';
        });
      }
    } catch (e) {
      setState(() {
        _cameraError = 'Camera permission denied: ${e.toString()}';
      });
    }
  }

  Future<void> _initializeCamera() async {
    if (!_cameraPermissionGranted || _cameras == null || _cameras!.isEmpty) {
      return;
    }

    try {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraError = null;
        });

        // Start pose detection stream
        _startPoseDetection();
      }
    } catch (e) {
      setState(() {
        _cameraError = 'Camera initialization failed: ${e.toString()}';
      });
    }
  }

  void _startPoseDetection() {
    if (!_isCameraInitialized || _cameraController == null) return;

    _cameraController!.startImageStream((CameraImage image) {
      if (!_isDetectingPose) {
        _isDetectingPose = true;
        _detectPoseInImage(image).then((_) {
          _isDetectingPose = false;
        });
      }
    });
  }

  Future<void> _detectPoseInImage(CameraImage image) async {
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final poses = await _poseDetector.processImage(inputImage);

      if (mounted) {
        setState(() {
          _poses = poses;
        });
      }
    } catch (e) {
      debugPrint('Pose detection error: $e');
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final camera = _cameras!.first;
      final rotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation,
      );
      if (rotation == null) return null;

      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      final bytesPerRow = image.planes.first.bytesPerRow;
      final bytes = image.planes.first.bytes;

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('Input image creation error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
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
                Tab(text: 'Measure'),
                Tab(text: 'Try On'),
                Tab(text: 'Results'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMeasurementTab(),
                _buildTryOnTab(),
                _buildResultsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Virtual Fitting Room',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {
            _showHelpDialog();
          },
          icon: const Icon(Icons.help_outline, color: Colors.white),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _showMeasurementGuide = !_showMeasurementGuide;
            });
          },
          icon: Icon(
            _showMeasurementGuide ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementTab() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Camera View or Error State
          if (_cameraError != null)
            _buildErrorState()
          else if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            _buildCameraPlaceholder(),

          // Pose Detection Overlay
          if (_showMeasurementGuide && _poses.isNotEmpty) _buildPoseOverlay(),

          // Basic Measurement Guide
          if (_showMeasurementGuide && _poses.isEmpty)
            _buildMeasurementOverlay(),

          // Measurement Instructions
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: _buildMeasurementInstructions(),
          ),

          // Pose Detection Status
          if (_poses.isNotEmpty)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: _buildPoseStatus(),
            ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: _buildMeasurementControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildTryOnTab() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Virtual Try-On',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // AR Visualization Mockup
            _buildARVisualization(),
            const SizedBox(height: 24),

            // Garment Selection
            _buildGarmentSelection(),
            const SizedBox(height: 24),

            // Fit Analysis
            _buildFitAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTab() {
    return Container(
      color: Colors.grey[50],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fitting Results',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Size Recommendations
            _buildSizeRecommendations(),
            const SizedBox(height: 24),

            // Measurements Display
            _buildMeasurementsDisplay(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Initializing Camera...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _cameraError ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry Camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoseOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: PoseOverlayPainter(_poses),
      ),
    );
  }

  Widget _buildPoseStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Body Detected - ${_poses.length} pose(s)',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BodyOutlinePainter(),
      ),
    );
  }

  Widget _buildMeasurementInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${_currentStep + 1} of ${_measurementSteps.length}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _measurementSteps[_currentStep],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementControls() {
    return Row(
      children: [
        // Toggle Guide
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showMeasurementGuide = !_showMeasurementGuide;
              });
            },
            icon: Icon(
              _showMeasurementGuide ? Icons.visibility_off : Icons.visibility,
            ),
            label: Text(_showMeasurementGuide ? 'Hide Guide' : 'Show Guide'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Capture Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessingMeasurements ? null : _captureMeasurements,
            icon: _isProcessingMeasurements
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.camera),
            label:
                Text(_isProcessingMeasurements ? 'Processing...' : 'Capture'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildARVisualization() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // AR Background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/intro/ar_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // AR Overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.view_in_ar,
                  size: 60,
                  color: Colors.blue[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'AR Try-On Experience',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'See how garments fit in real-time',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGarmentSelection() {
    final garments = [
      {'name': 'Classic Shirt', 'type': 'shirt', 'color': Colors.blue},
      {'name': 'Summer Dress', 'type': 'dress', 'color': Colors.purple},
      {'name': 'Business Suit', 'type': 'suit', 'color': Colors.grey},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Garment to Try',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: garments.length,
            itemBuilder: (context, index) {
              final garment = garments[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            (garment['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (garment['color'] as Color)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.checkroom,
                        size: 40,
                        color: garment['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      garment['name'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFitAnalysis() {
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
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              const Text(
                'Fit Analysis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFitMetric('Shoulder Fit', 95, Colors.green),
          _buildFitMetric('Chest Fit', 88, Colors.orange),
          _buildFitMetric('Length', 92, Colors.green),
          _buildFitMetric('Overall Fit', 91, Colors.green),
        ],
      ),
    );
  }

  Widget _buildFitMetric(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$score%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeRecommendations() {
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
                'Size Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSizeRecommendation(
            'Shirt',
            'Medium (M)',
            'Perfect fit based on your measurements',
          ),
          _buildSizeRecommendation(
            'Dress',
            'Size 8',
            'Recommended for your body type',
          ),
          _buildSizeRecommendation(
            'Suit',
            'Large (L)',
            'Consider slim fit for better appearance',
          ),
        ],
      ),
    );
  }

  Widget _buildSizeRecommendation(String garment, String size, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  garment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Recommended: $size',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsDisplay() {
    final measurements = {
      'Chest': '38 inches',
      'Waist': '32 inches',
      'Hip': '36 inches',
      'Shoulder': '16 inches',
      'Height': '5\'8"',
    };

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
                color: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              const Text(
                'Your Measurements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...measurements.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _saveToProfile();
            },
            icon: const Icon(Icons.save),
            label: const Text('Save to Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _shareResults();
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Results'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _captureMeasurements() async {
    setState(() {
      _isProcessingMeasurements = true;
    });

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 3));

    // Move to next step or complete
    if (_currentStep < _measurementSteps.length - 1) {
      setState(() {
        _currentStep++;
        _isProcessingMeasurements = false;
      });
    } else {
      // Complete measurement process
      await _processMeasurements();
      _tabController.animateTo(2); // Go to results tab
    }
  }

  Future<void> _processMeasurements() async {
    setState(() {
      _isProcessingMeasurements = true;
    });

    // Extract measurements from pose landmarks if available
    if (_poses.isNotEmpty) {
      final measuredValues = _calculateBodyMeasurementsFromPose(_poses.first);
      setState(() {
        _measurements.addAll(measuredValues);
      });
    } else {
      // Fallback to simulated measurements if no pose detected
      setState(() {
        _measurements['chest'] = 38.0 + (DateTime.now().millisecond % 5);
        _measurements['waist'] = 32.0 + (DateTime.now().millisecond % 4);
        _measurements['hip'] = 36.0 + (DateTime.now().millisecond % 3);
        _measurements['shoulder'] = 16.0 + (DateTime.now().millisecond % 2);
        _measurements['height'] =
            68.0 + (DateTime.now().millisecond % 6); // inches
      });
    }

    // Get size recommendations from AI service
    try {
      final bodyMeasurements = BodyMeasurements(
        chest: _measurements['chest']!,
        waist: _measurements['waist']!,
        hips: _measurements['hip']!,
        height: _measurements['height']!,
        shoulders: _measurements['shoulder']!,
        unit: 'in', // inches
        lastUpdated: DateTime.now(),
      );

      final recommendations =
          await ServiceLocator.mlKitService.calculateSizeRecommendations(
        measurements: bodyMeasurements,
        garmentType: GarmentType.shirt,
      );

      setState(() {
        _sizeRecommendations.addAll(recommendations);
        _isProcessingMeasurements = false;
      });
    } catch (e) {
      debugPrint('Size recommendation error: $e');
      setState(() {
        _isProcessingMeasurements = false;
      });
    }
  }

  Map<String, double> _calculateBodyMeasurementsFromPose(Pose pose) {
    final measurements = <String, double>{};

    try {
      // Extract key landmarks
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
      final nose = pose.landmarks[PoseLandmarkType.nose];
      final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];

      // Calculate shoulder width
      if (leftShoulder != null && rightShoulder != null) {
        final shoulderWidth = _calculateDistance(
          leftShoulder.x,
          leftShoulder.y,
          rightShoulder.x,
          rightShoulder.y,
        );
        measurements['shoulder'] = (shoulderWidth * 0.025)
            .clamp(14.0, 20.0); // Convert to inches approx
      }

      // Calculate chest (estimate based on shoulder width)
      if (measurements['shoulder'] != null) {
        measurements['chest'] =
            (measurements['shoulder']! * 2.2).clamp(32.0, 50.0);
      }

      // Calculate waist (estimate based on hip width)
      if (leftHip != null && rightHip != null) {
        final hipWidth = _calculateDistance(
          leftHip.x,
          leftHip.y,
          rightHip.x,
          rightHip.y,
        );
        measurements['waist'] = (hipWidth * 0.02).clamp(28.0, 42.0);
        measurements['hip'] = (hipWidth * 0.022).clamp(32.0, 46.0);
      }

      // Calculate height (nose to ankle)
      if (nose != null && leftAnkle != null) {
        final bodyHeight = _calculateDistance(
          nose.x,
          nose.y,
          leftAnkle.x,
          leftAnkle.y,
        );
        measurements['height'] =
            (bodyHeight * 0.01).clamp(60.0, 78.0); // Convert to inches approx
      }
    } catch (e) {
      debugPrint('Measurement calculation error: $e');
      // Return default measurements if calculation fails
      measurements['chest'] = 38.0;
      measurements['waist'] = 32.0;
      measurements['hip'] = 36.0;
      measurements['shoulder'] = 16.0;
      measurements['height'] = 68.0;
    }

    return measurements;
  }

  double _calculateDistance(double x1, double y1, double x2, double y2) {
    return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
  }

  void _saveToProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Measurements saved to your profile'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing fitting results...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Virtual Fitting Help'),
        content: const Text(
          'Follow these steps:\n\n'
          '1. Measure: Stand straight and capture your body measurements\n'
          '2. Try On: Visualize how garments fit using AR\n'
          '3. Results: Review size recommendations and measurements\n\n'
          'For best results, ensure good lighting and stand against a plain background.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for body outline guide
class BodyOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final bodyHeight = size.height * 0.6;
    final bodyWidth = size.width * 0.3;

    // Draw body outline
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: bodyWidth,
        height: bodyHeight,
      ),
      const Radius.circular(20),
    );

    canvas.drawRRect(bodyRect, paint);

    // Draw head circle
    canvas.drawCircle(
      Offset(center.dx, center.dy - bodyHeight / 2 - 30),
      25,
      paint,
    );

    // Draw measurement lines
    final dashedPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal measurement lines
    final measurements = [
      center.dy - bodyHeight / 4, // Chest
      center.dy, // Waist
      center.dy + bodyHeight / 4, // Hip
    ];

    for (final y in measurements) {
      canvas.drawLine(
        Offset(center.dx - bodyWidth / 2 - 20, y),
        Offset(center.dx + bodyWidth / 2 + 20, y),
        dashedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for pose detection overlay
class PoseOverlayPainter extends CustomPainter {
  final List<Pose> poses;

  PoseOverlayPainter(this.poses);

  @override
  void paint(Canvas canvas, Size size) {
    if (poses.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      // Draw pose landmarks as points
      for (final landmark in pose.landmarks.values) {
        if (landmark.x >= 0 && landmark.y >= 0) {
          canvas.drawCircle(
            Offset(landmark.x, landmark.y),
            6,
            pointPaint,
          );
        }
      }

      // Draw skeleton connections
      _drawPoseConnections(canvas, pose, paint);
    }
  }

  void _drawPoseConnections(Canvas canvas, Pose pose, Paint paint) {
    // Define key pose connections
    final connections = [
      // Head to shoulders
      [PoseLandmarkType.nose, PoseLandmarkType.leftShoulder],
      [PoseLandmarkType.nose, PoseLandmarkType.rightShoulder],

      // Shoulders to body
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],

      // Arms
      [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
      [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],

      // Torso
      [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
      [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
      [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],

      // Legs
      [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
      [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
      [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
      [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    ];

    for (final connection in connections) {
      final startLandmark = pose.landmarks[connection[0]];
      final endLandmark = pose.landmarks[connection[1]];

      if (startLandmark != null && endLandmark != null) {
        if (startLandmark.x >= 0 &&
            startLandmark.y >= 0 &&
            endLandmark.x >= 0 &&
            endLandmark.y >= 0) {
          canvas.drawLine(
            Offset(startLandmark.x, startLandmark.y),
            Offset(endLandmark.x, endLandmark.y),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is PoseOverlayPainter && oldDelegate.poses != poses;
  }
}
