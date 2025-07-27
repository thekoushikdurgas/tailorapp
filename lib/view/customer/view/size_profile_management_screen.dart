import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class SizeProfileManagementScreen extends StatefulWidget {
  const SizeProfileManagementScreen({super.key});

  @override
  State<SizeProfileManagementScreen> createState() =>
      _SizeProfileManagementScreenState();
}

class _SizeProfileManagementScreenState
    extends State<SizeProfileManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _scanController;
  late AnimationController _pulseController;

  bool _isScanning = false;
  bool _hasBodyScan = false;
  String _selectedMeasurementSystem = 'Imperial';
  String _selectedBodyType = 'Not Set';
  List<MeasurementRecord> _measurementHistory = [];
  BodyProfile? _currentProfile;

  final List<String> _measurementSystems = ['Imperial', 'Metric'];
  final List<String> _bodyTypes = [
    'Not Set',
    'Rectangle',
    'Triangle',
    'Inverted Triangle',
    'Hourglass',
    'Apple',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _loadMeasurementData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadMeasurementData() {
    // Mock data - replace with actual API call
    _currentProfile = BodyProfile(
      height: 175,
      weight: 70,
      bodyType: 'Hourglass',
      measurements: {
        'Chest/Bust': 95.0,
        'Waist': 75.0,
        'Hips': 100.0,
        'Shoulder Width': 42.0,
        'Sleeve Length': 60.0,
        'Neck': 38.0,
        'Inseam': 81.0,
        'Thigh': 58.0,
      },
      lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
      confidenceScore: 0.92,
    );

    _measurementHistory = List.generate(
      6,
      (index) => MeasurementRecord(
        date: DateTime.now().subtract(Duration(days: index * 30)),
        measurements: {
          'Chest/Bust': 95.0 + (index * 0.5),
          'Waist': 75.0 + (index * 0.3),
          'Hips': 100.0 + (index * 0.4),
        },
        source: index % 3 == 0
            ? 'AI Scan'
            : index % 2 == 0
                ? 'Manual Entry'
                : 'Tailor Measured',
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Profile overview
          if (_currentProfile != null) _buildProfileOverview(),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMeasurementsTab(),
                _buildBodyScanTab(),
                _buildHistoryTab(),
                _buildInsightsTab(),
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
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: const Text(
        'Size Profile',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _shareProfile,
          icon: Icon(Icons.share, color: Colors.grey[600]),
        ),
        IconButton(
          onPressed: _exportMeasurements,
          icon: Icon(Icons.download, color: Colors.grey[600]),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Text('Measurement Settings'),
            ),
            const PopupMenuItem(
              value: 'sync',
              child: Text('Sync with Wearables'),
            ),
            const PopupMenuItem(
              value: 'privacy',
              child: Text('Privacy Settings'),
            ),
            const PopupMenuItem(
              value: 'help',
              child: Text('Measurement Guide'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Body silhouette visualization
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: CustomPaint(
                        size: const Size(60, 100),
                        painter:
                            BodySilhouettePainter(_currentProfile!.bodyType),
                      ),
                    ),
                    if (_hasBodyScan)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            shape: BoxShape.circle,
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
              ),

              const SizedBox(width: 20),

              // Profile stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Accuracy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _currentProfile!.confidenceScore,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _currentProfile!.confidenceScore > 0.8
                                  ? Colors.green[600]!
                                  : Colors.orange[600]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(_currentProfile!.confidenceScore * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuickStat(
                          'Height',
                          '${_currentProfile!.height}cm',
                        ),
                        const SizedBox(width: 20),
                        _buildQuickStat(
                          'Weight',
                          '${_currentProfile!.weight}kg',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: ${_formatDate(_currentProfile!.lastUpdated)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startBodyScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'AI Body Scan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _manualMeasurement,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.straighten, size: 18),
                  label: const Text('Manual Entry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[600],
        tabs: const [
          Tab(text: 'Measurements'),
          Tab(text: 'Body Scan'),
          Tab(text: 'History'),
          Tab(text: 'Insights'),
        ],
      ),
    );
  }

  Widget _buildMeasurementsTab() {
    if (_currentProfile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Measurement system selector
          Row(
            children: [
              const Text(
                'Measurement System:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedMeasurementSystem,
                items: _measurementSystems
                    .map(
                      (system) =>
                          DropdownMenuItem(value: system, child: Text(system)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMeasurementSystem = value!;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Body measurements
          const Text(
            'Body Measurements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          ..._currentProfile!.measurements.entries
              .map((entry) => _buildMeasurementItem(entry.key, entry.value)),

          const SizedBox(height: 24),

          // Body type selection
          Container(
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
                  'Body Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedBodyType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _bodyTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBodyType = value!;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Body type helps with garment fit recommendations',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementItem(String name, double value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to edit measurement',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)} cm',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => _editMeasurement(name, value),
            icon: Icon(Icons.edit, color: Colors.grey[600], size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyScanTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Scan area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isScanning) ...[
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 280,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(200, 280),
                              painter: ScanLinesPainter(_scanController.value),
                            ),
                            Icon(
                              Icons.person,
                              size: 120,
                              color: Colors.blue[200],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Text(
                          'Scanning your body...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600]!.withValues(
                              alpha: 0.5 + _pulseController.value * 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please stay still while we capture your measurements',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Icon(
                      Icons.camera_alt,
                      size: 80,
                      color: Colors.blue[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'AI Body Scanning',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Get precise measurements using our AI-powered body scanning technology',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates,
                                color: Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Scanning Tips',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...[
                            '• Wear fitted clothing',
                            '• Stand in good lighting',
                            '• Keep arms slightly away from body',
                            '• Face the camera directly',
                          ].map(
                            (tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                tip,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Scan button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isScanning ? _stopBodyScan : _startBodyScan,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isScanning ? Colors.red[600] : Colors.blue[600],
                padding: const EdgeInsets.all(16),
              ),
              icon: Icon(
                _isScanning ? Icons.stop : Icons.camera_alt,
                color: Colors.white,
              ),
              label: Text(
                _isScanning ? 'Stop Scanning' : 'Start AI Scan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart section
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
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
                  'Measurement Trends',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(6, (index) {
                      final height = 50.0 + (index * 10.0);
                      return Container(
                        width: 30,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.blue[400]!, Colors.blue[600]!],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['6M', '5M', '4M', '3M', '2M', '1M']
                      .map(
                        (month) => Text(
                          month,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // History list
          const Text(
            'Measurement History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          ..._measurementHistory.map(_buildHistoryItem),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(MeasurementRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSourceColor(record.source).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  record.source,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getSourceColor(record.source),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(record.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...record.measurements.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
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
                    '${entry.value.toStringAsFixed(1)} cm',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
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

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fit recommendations
          _buildInsightCard(
            'Fit Recommendations',
            'Based on your body type and measurements',
            Icons.recommend,
            Colors.blue,
            [
              'Consider tapered fit for bottoms',
              'Structured shoulders work well for you',
              'High-waisted styles are recommended',
            ],
          ),

          const SizedBox(height: 16),

          // Size accuracy
          _buildInsightCard(
            'Size Accuracy',
            'How confident we are in your measurements',
            Icons.verified,
            Colors.green,
            [
              'Upper body: 95% accurate',
              'Lower body: 88% accurate',
              'Overall confidence: 92%',
            ],
          ),

          const SizedBox(height: 16),

          // Measurement tips
          _buildInsightCard(
            'Measurement Tips',
            'Improve accuracy with these suggestions',
            Icons.tips_and_updates,
            Colors.orange,
            [
              'Update measurements monthly',
              'Use AI scanning for best results',
              'Measure at consistent times',
            ],
          ),

          const SizedBox(height: 16),

          // Size evolution
          _buildInsightCard(
            'Size Evolution',
            'Your measurement changes over time',
            Icons.timeline,
            Colors.purple,
            [
              'Waist decreased by 2cm in 3 months',
              'Chest measurements stable',
              'Overall body composition improving',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<String> insights,
  ) {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
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

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'compare',
          onPressed: _compareMeasurements,
          backgroundColor: Colors.purple[600],
          child: const Icon(Icons.compare_arrows, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: _shareWithTailor,
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.share),
          label: const Text(
            'Share with Tailor',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getSourceColor(String source) {
    switch (source) {
      case 'AI Scan':
        return Colors.blue[600]!;
      case 'Manual Entry':
        return Colors.orange[600]!;
      case 'Tailor Measured':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  void _startBodyScan() {
    setState(() {
      _isScanning = true;
    });

    _scanController.forward();

    // Simulate scan completion
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _hasBodyScan = true;
        });
        _scanController.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Body scan completed! Measurements updated.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _stopBodyScan() {
    setState(() {
      _isScanning = false;
    });
    _scanController.reset();
  }

  void _manualMeasurement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Measurement'),
        content: const Text(
          'Manual measurement entry form will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: () => context.pop(), child: const Text('Save')),
        ],
      ),
    );
  }

  void _editMeasurement(String name, double value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $name'),
        content: TextFormField(
          initialValue: value.toString(),
          decoration: const InputDecoration(
            labelText: 'Measurement (cm)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: () => context.pop(), child: const Text('Save')),
        ],
      ),
    );
  }

  void _shareProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing size profile...')),
    );
  }

  void _exportMeasurements() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting measurements to PDF...')),
    );
  }

  void _shareWithTailor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share with Tailor'),
        content: const Text(
          'Share your measurements with your preferred tailor for accurate garment fitting.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _compareMeasurements() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compare Measurements'),
        content: const Text(
          'Compare your current measurements with previous records.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        _showMeasurementSettings();
        break;
      case 'sync':
        _syncWithWearables();
        break;
      case 'privacy':
        _showPrivacySettings();
        break;
      case 'help':
        _showMeasurementGuide();
        break;
    }
  }

  void _showMeasurementSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Measurement Settings'),
        content:
            const Text('Configure your measurement preferences and units.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _syncWithWearables() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing with connected wearable devices...'),
      ),
    );
  }

  void _showPrivacySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text('Control who can access your measurement data.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMeasurementGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Measurement Guide'),
        content: const Text('Learn how to take accurate body measurements.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Custom painters and data models
class BodySilhouettePainter extends CustomPainter {
  final String bodyType;

  BodySilhouettePainter(this.bodyType);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    // Simple body outline based on body type
    switch (bodyType) {
      case 'Hourglass':
        path.moveTo(size.width * 0.5, size.height * 0.1);
        path.quadraticBezierTo(
          size.width * 0.7,
          size.height * 0.3,
          size.width * 0.6,
          size.height * 0.5,
        );
        path.quadraticBezierTo(
          size.width * 0.8,
          size.height * 0.7,
          size.width * 0.6,
          size.height * 0.9,
        );
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.95,
          size.width * 0.4,
          size.height * 0.9,
        );
        path.quadraticBezierTo(
          size.width * 0.2,
          size.height * 0.7,
          size.width * 0.4,
          size.height * 0.5,
        );
        path.quadraticBezierTo(
          size.width * 0.3,
          size.height * 0.3,
          size.width * 0.5,
          size.height * 0.1,
        );
        break;
      default:
        // Generic body shape
        path.addOval(
          Rect.fromLTWH(
            size.width * 0.3,
            size.height * 0.2,
            size.width * 0.4,
            size.height * 0.6,
          ),
        );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanLinesPainter extends CustomPainter {
  final double progress;

  ScanLinesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[400]!
      ..strokeWidth = 2;

    final currentY = size.height * progress;

    // Draw scanning lines
    for (int i = 0; i < 5; i++) {
      final y = currentY + (i * 10);
      if (y <= size.height) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint..color = Colors.blue[400]!.withValues(alpha: 1.0 - (i * 0.2)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Data models
class BodyProfile {
  final double height;
  final double weight;
  final String bodyType;
  final Map<String, double> measurements;
  final DateTime lastUpdated;
  final double confidenceScore;

  BodyProfile({
    required this.height,
    required this.weight,
    required this.bodyType,
    required this.measurements,
    required this.lastUpdated,
    required this.confidenceScore,
  });
}

class MeasurementRecord {
  final DateTime date;
  final Map<String, double> measurements;
  final String source;

  MeasurementRecord({
    required this.date,
    required this.measurements,
    required this.source,
  });
}
