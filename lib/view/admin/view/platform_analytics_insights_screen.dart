import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tailorapp/core/cubit/auth_cubit.dart';
// import 'package:tailorapp/view/_product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class PlatformAnalyticsInsightsScreen extends StatefulWidget {
  const PlatformAnalyticsInsightsScreen({super.key});

  @override
  State<PlatformAnalyticsInsightsScreen> createState() => _PlatformAnalyticsInsightsScreenState();
}

class _PlatformAnalyticsInsightsScreenState extends State<PlatformAnalyticsInsightsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshController;
  late AnimationController _chartController;

  final ScrollController _dashboardScrollController = ScrollController();

  List<AnalyticsMetric> _kpiMetrics = [];
  List<ChartData> _revenueData = [];
  List<ChartData> _userGrowthData = [];
  List<ChartData> _orderVolumeData = [];
  List<GeographicData> _geographicData = [];
  List<PlatformInsight> _insights = [];
  List<PerformanceAlert> _performanceAlerts = [];

  String _selectedTimeRange = 'Last 30 Days';
  String _selectedMetric = 'Revenue';
  String _selectedComparison = 'Previous Period';
  bool _isRealTimeMode = false;
  bool _showPredictions = true;

  final List<String> _timeRanges = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'Last 6 Months',
    'Last Year',
    'Custom Range',
  ];

  final List<String> _metricOptions = [
    'Revenue',
    'Orders',
    'Users',
    'Conversion Rate',
    'AOV',
    'Customer Satisfaction',
  ];

  final List<String> _comparisonOptions = [
    'Previous Period',
    'Previous Year',
    'Industry Average',
    'Target Goals',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _loadAnalyticsData();
    _startRealTimeUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _chartController.dispose();
    _dashboardScrollController.dispose();
    super.dispose();
  }

  void _loadAnalyticsData() {
    _loadKPIMetrics();
    _loadChartData();
    _loadGeographicData();
    _loadInsights();
    _loadPerformanceAlerts();
    setState(() {});
  }

  void _loadKPIMetrics() {
    _kpiMetrics = [
      AnalyticsMetric(
        id: 'revenue',
        name: 'Total Revenue',
        value: 847250.0,
        previousValue: 782340.0,
        unit: 'USD',
        format: 'currency',
        icon: Icons.attach_money,
        color: Colors.green,
        trend: MetricTrend.up,
        changePercentage: 8.3,
        target: 900000.0,
        category: MetricCategory.financial,
        description: 'Total platform revenue including commissions',
        isGood: true,
      ),
      AnalyticsMetric(
        id: 'orders',
        name: 'Total Orders',
        value: 12847.0,
        previousValue: 11920.0,
        unit: 'orders',
        format: 'number',
        icon: Icons.shopping_bag,
        color: Colors.blue,
        trend: MetricTrend.up,
        changePercentage: 7.8,
        target: 15000.0,
        category: MetricCategory.business,
        description: 'Total orders placed on the platform',
        isGood: true,
      ),
      AnalyticsMetric(
        id: 'users',
        name: 'Active Users',
        value: 45672.0,
        previousValue: 42100.0,
        unit: 'users',
        format: 'number',
        icon: Icons.people,
        color: Colors.purple,
        trend: MetricTrend.up,
        changePercentage: 8.5,
        target: 50000.0,
        category: MetricCategory.users,
        description: 'Monthly active users across all roles',
        isGood: true,
      ),
      AnalyticsMetric(
        id: 'conversion',
        name: 'Conversion Rate',
        value: 3.2,
        previousValue: 2.8,
        unit: '%',
        format: 'percentage',
        icon: Icons.trending_up,
        color: Colors.orange,
        trend: MetricTrend.up,
        changePercentage: 14.3,
        target: 4.0,
        category: MetricCategory.performance,
        description: 'Visitor to customer conversion rate',
        isGood: true,
      ),
      AnalyticsMetric(
        id: 'aov',
        name: 'Average Order Value',
        value: 285.40,
        previousValue: 267.20,
        unit: 'USD',
        format: 'currency',
        icon: Icons.receipt_long,
        color: Colors.teal,
        trend: MetricTrend.up,
        changePercentage: 6.8,
        target: 300.0,
        category: MetricCategory.financial,
        description: 'Average value per order',
        isGood: true,
      ),
      AnalyticsMetric(
        id: 'satisfaction',
        name: 'Customer Satisfaction',
        value: 4.7,
        previousValue: 4.5,
        unit: '/5',
        format: 'rating',
        icon: Icons.star,
        color: Colors.amber,
        trend: MetricTrend.up,
        changePercentage: 4.4,
        target: 4.8,
        category: MetricCategory.quality,
        description: 'Average customer rating across all services',
        isGood: true,
      ),
      AnalyticsMetric(
        id: 'churn',
        name: 'Churn Rate',
        value: 2.3,
        previousValue: 2.8,
        unit: '%',
        format: 'percentage',
        icon: Icons.trending_down,
        color: Colors.red,
        trend: MetricTrend.down,
        changePercentage: -17.9,
        target: 2.0,
        category: MetricCategory.users,
        description: 'Monthly customer churn rate',
        isGood: true,
      ),
      AnalyticsMetric(
        id: 'ltv',
        name: 'Customer LTV',
        value: 1247.80,
        previousValue: 1190.50,
        unit: 'USD',
        format: 'currency',
        icon: Icons.account_balance_wallet,
        color: Colors.indigo,
        trend: MetricTrend.up,
        changePercentage: 4.8,
        target: 1400.0,
        category: MetricCategory.financial,
        description: 'Average customer lifetime value',
        isGood: true,
      ),
    ];
  }

  void _loadChartData() {
    // Revenue data for the last 30 days
    _revenueData = List.generate(
      30,
      (index) => ChartData(
        date: DateTime.now().subtract(Duration(days: 29 - index)),
        value: 25000 + (index * 1000) + (index % 7 * 2000),
        category: 'Revenue',
      ),
    );

    // User growth data
    _userGrowthData = List.generate(
      30,
      (index) => ChartData(
        date: DateTime.now().subtract(Duration(days: 29 - index)),
        value: 1000 + (index * 50) + (index % 5 * 100),
        category: 'Users',
      ),
    );

    // Order volume data
    _orderVolumeData = List.generate(
      30,
      (index) => ChartData(
        date: DateTime.now().subtract(Duration(days: 29 - index)),
        value: 400 + (index * 10) + (index % 3 * 50),
        category: 'Orders',
      ),
    );
  }

  void _loadGeographicData() {
    _geographicData = [
      GeographicData('United States', 'US', 35.2, 847250, Colors.blue[700]!),
      GeographicData('Canada', 'CA', 12.8, 308450, Colors.blue[600]!),
      GeographicData('United Kingdom', 'UK', 8.5, 204820, Colors.blue[500]!),
      GeographicData('Germany', 'DE', 7.2, 173400, Colors.blue[400]!),
      GeographicData('France', 'FR', 5.9, 142170, Colors.blue[300]!),
      GeographicData('Australia', 'AU', 4.8, 115640, Colors.blue[200]!),
      GeographicData('Japan', 'JP', 4.2, 101220, Colors.blue[100]!),
      GeographicData('Others', 'XX', 21.4, 515546, Colors.grey[400]!),
    ];
  }

  void _loadInsights() {
    _insights = [
      PlatformInsight(
        id: 'INS001',
        title: 'Revenue Growth Acceleration',
        description:
            'Revenue growth has accelerated by 23% this month, primarily driven by increased premium service adoption.',
        category: InsightCategory.opportunity,
        severity: InsightSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        actionable: true,
        recommendation: 'Consider expanding premium service marketing to capture additional growth.',
        metrics: ['revenue', 'orders'],
        confidence: 0.89,
      ),
      PlatformInsight(
        id: 'INS002',
        title: 'Customer Acquisition Cost Optimization',
        description: 'CAC has decreased by 15% while maintaining quality, indicating improved marketing efficiency.',
        category: InsightCategory.efficiency,
        severity: InsightSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        actionable: true,
        recommendation: 'Reallocate budget from underperforming channels to optimize further.',
        metrics: ['users', 'conversion'],
        confidence: 0.76,
      ),
      PlatformInsight(
        id: 'INS003',
        title: 'Seasonal Demand Pattern Detected',
        description: 'Analytics show a 40% increase in formal wear orders, likely due to upcoming wedding season.',
        category: InsightCategory.trend,
        severity: InsightSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        actionable: true,
        recommendation: 'Prepare inventory and tailor capacity for increased formal wear demand.',
        metrics: ['orders'],
        confidence: 0.82,
      ),
      PlatformInsight(
        id: 'INS004',
        title: 'Geographic Expansion Opportunity',
        description: 'Organic search traffic from Mexico and Brazil has increased 200% with minimal conversion.',
        category: InsightCategory.opportunity,
        severity: InsightSeverity.low,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        actionable: true,
        recommendation: 'Consider localization and market entry strategy for Latin America.',
        metrics: ['users'],
        confidence: 0.68,
      ),
    ];
  }

  void _loadPerformanceAlerts() {
    _performanceAlerts = [
      PerformanceAlert(
        id: 'ALERT001',
        title: 'Server Response Time Spike',
        description: 'Average response time increased to 850ms (threshold: 500ms)',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isResolved: false,
        affectedMetrics: ['user_experience', 'conversion'],
        recommendedAction: 'Scale server resources or optimize database queries',
      ),
      PerformanceAlert(
        id: 'ALERT002',
        title: 'Low Inventory Warning',
        description: '12 popular fabric types below reorder threshold',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isResolved: false,
        affectedMetrics: ['orders', 'satisfaction'],
        recommendedAction: 'Trigger automatic reorders for critical inventory items',
      ),
    ];
  }

  void _startRealTimeUpdates() {
    // Simulate real-time updates
    if (_isRealTimeMode) {
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && _isRealTimeMode) {
          _loadAnalyticsData();
          _startRealTimeUpdates();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Controls and filters
          _buildControlsBar(),

          // Performance alerts
          if (_performanceAlerts.where((a) => !a.isResolved).isNotEmpty) _buildAlertsBar(),

          // Tab bar
          _buildTabBar(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildRevenueTab(),
                _buildUsersTab(),
                _buildOperationsTab(),
                _buildInsightsTab(),
                _buildReportsTab(),
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
        'Platform Analytics',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Real-time mode toggle
        IconButton(
          onPressed: _toggleRealTimeMode,
          icon: AnimatedBuilder(
            animation: _refreshController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _isRealTimeMode ? _refreshController.value * 2 * 3.14159 : 0,
                child: Icon(
                  _isRealTimeMode ? Icons.sync : Icons.sync_disabled,
                  color: _isRealTimeMode ? Colors.green[600] : Colors.grey[600],
                ),
              );
            },
          ),
        ),

        // Export data
        IconButton(
          onPressed: _exportAnalytics,
          icon: Icon(Icons.download, color: Colors.grey[600]),
        ),

        // Settings
        IconButton(
          onPressed: _showAnalyticsSettings,
          icon: Icon(Icons.settings, color: Colors.grey[600]),
        ),

        // More options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'custom_dashboard',
              child: Text('Custom Dashboard'),
            ),
            const PopupMenuItem(
              value: 'schedule_reports',
              child: Text('Schedule Reports'),
            ),
            const PopupMenuItem(
              value: 'data_sources',
              child: Text('Data Sources'),
            ),
            const PopupMenuItem(value: 'api_access', child: Text('API Access')),
          ],
        ),
      ],
    );
  }

  Widget _buildControlsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Time range and comparison controls
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTimeRange,
                  decoration: InputDecoration(
                    labelText: 'Time Range',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _timeRanges
                      .map(
                        (range) => DropdownMenuItem(
                          value: range,
                          child: Text(
                            range,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeRange = value!;
                      _loadAnalyticsData();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedComparison,
                  decoration: InputDecoration(
                    labelText: 'Compare To',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _comparisonOptions
                      .map(
                        (comparison) => DropdownMenuItem(
                          value: comparison,
                          child: Text(
                            comparison,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedComparison = value!;
                      _loadAnalyticsData();
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Additional controls
          Row(
            children: [
              FilterChip(
                label: const Text(
                  'Show Predictions',
                  style: TextStyle(fontSize: 12),
                ),
                selected: _showPredictions,
                onSelected: (selected) {
                  setState(() {
                    _showPredictions = selected;
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[600],
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(
                  'Real-time: ${_isRealTimeMode ? 'ON' : 'OFF'}',
                  style: const TextStyle(fontSize: 12),
                ),
                selected: _isRealTimeMode,
                onSelected: (selected) => _toggleRealTimeMode(),
                selectedColor: Colors.green[100],
                checkmarkColor: Colors.green[600],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsBar() {
    final activeAlerts = _performanceAlerts.where((a) => !a.isResolved).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${activeAlerts.length} performance alert${activeAlerts.length != 1 ? 's' : ''} require attention',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _showPerformanceAlerts,
            child: Text(
              'View All',
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.indigo[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.indigo[600],
        isScrollable: true,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Revenue'),
          Tab(text: 'Users'),
          Tab(text: 'Operations'),
          Tab(text: 'Insights'),
          Tab(text: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshController.forward().then((_) {
          _loadAnalyticsData();
          _refreshController.reset();
        });
      },
      child: SingleChildScrollView(
        controller: _dashboardScrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Grid
            _buildKPIGrid(),

            const SizedBox(height: 24),

            // Key Charts
            _buildKeyChartsSection(),

            const SizedBox(height: 24),

            // Geographic Distribution
            _buildGeographicSection(),

            const SizedBox(height: 24),

            // Recent Insights
            _buildRecentInsightsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Performance Indicators',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: _kpiMetrics.length,
          itemBuilder: (context, index) {
            return _buildKPICard(_kpiMetrics[index]);
          },
        ),
      ],
    );
  }

  Widget _buildKPICard(AnalyticsMetric metric) {
    final progressToTarget = metric.target != null ? (metric.value / metric.target!).clamp(0.0, 1.0) : 0.0;

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
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: metric.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(metric.icon, color: metric.color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: metric.isGood
                      ? (metric.trend == MetricTrend.up ? Colors.green[100] : Colors.red[100])
                      : (metric.trend == MetricTrend.up ? Colors.red[100] : Colors.green[100]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      metric.trend == MetricTrend.up ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: metric.isGood
                          ? (metric.trend == MetricTrend.up ? Colors.green[600] : Colors.red[600])
                          : (metric.trend == MetricTrend.up ? Colors.red[600] : Colors.green[600]),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${metric.changePercentage.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: metric.isGood
                            ? (metric.trend == MetricTrend.up ? Colors.green[600] : Colors.red[600])
                            : (metric.trend == MetricTrend.up ? Colors.red[600] : Colors.green[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Value
          Text(
            _formatMetricValue(metric),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // Name
          Text(
            metric.name,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 8),

          // Progress to target
          if (metric.target != null) ...[
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progressToTarget,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(metric.color),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progressToTarget * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Target: ${_formatValue(metric.target!, metric.format, metric.unit)}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKeyChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Trends',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
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
            children: [
              Row(
                children: [
                  const Text(
                    'Revenue Trend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _selectedMetric,
                    underline: const SizedBox.shrink(),
                    items: _metricOptions
                        .map(
                          (metric) => DropdownMenuItem(
                            value: metric,
                            child: Text(
                              metric,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMetric = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AnimatedBuilder(
                  animation: _chartController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: LineChartPainter(
                        _revenueData,
                        _chartController.value,
                      ),
                      size: const Size(double.infinity, double.infinity),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeographicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Geographic Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              Row(
                children: [
                  const Text(
                    'Revenue by Region',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _selectedTimeRange,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._geographicData.map((data) => _buildGeographicItem(data)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeographicItem(GeographicData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                data.countryCode == 'XX' ? '•••' : data.countryCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.country,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '\$${data.revenue.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: data.percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'AI-Powered Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _tabController.animateTo(4),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._insights.take(3).map((insight) => _buildInsightCard(insight)),
      ],
    );
  }

  Widget _buildInsightCard(PlatformInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getInsightCategoryColor(insight.category).withValues(alpha: 0.3),
        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getInsightCategoryColor(insight.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  insight.category.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getInsightCategoryColor(insight.category),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.psychology, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${(insight.confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          if (insight.actionable && insight.recommendation != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.recommendation!,
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

  Widget _buildRevenueTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
            child: const Column(
              children: [
                Icon(Icons.bar_chart, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Detailed Revenue Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Advanced revenue breakdown and forecasting',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
            child: const Column(
              children: [
                Icon(Icons.people_alt, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'User Behavior Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'User engagement, retention, and lifecycle analysis',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operations Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
            child: const Column(
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Operational Efficiency',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Production metrics, fulfillment, and quality analytics',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _insights.length,
      itemBuilder: (context, index) {
        return _buildInsightCard(_insights[index]);
      },
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scheduled Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
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
            child: const Column(
              children: [
                Icon(Icons.assignment, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Automated Reporting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Custom reports and automated delivery schedules',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
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
          heroTag: 'create_alert',
          onPressed: _createCustomAlert,
          backgroundColor: Colors.orange[600],
          child: const Icon(Icons.notification_add, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: _generateReport,
          backgroundColor: Colors.indigo[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.analytics),
          label: const Text(
            'Generate Report',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _formatMetricValue(AnalyticsMetric metric) {
    return _formatValue(metric.value, metric.format, metric.unit);
  }

  String _formatValue(double value, String format, String unit) {
    switch (format) {
      case 'currency':
        return '\$${value.toStringAsFixed(0)}';
      case 'percentage':
        return '${value.toStringAsFixed(1)}%';
      case 'rating':
        return '${value.toStringAsFixed(1)}$unit';
      case 'number':
        if (value >= 1000000) {
          return '${(value / 1000000).toStringAsFixed(1)}M';
        } else if (value >= 1000) {
          return '${(value / 1000).toStringAsFixed(1)}K';
        } else {
          return value.toStringAsFixed(0);
        }
      default:
        return value.toStringAsFixed(0);
    }
  }

  Color _getInsightCategoryColor(InsightCategory category) {
    switch (category) {
      case InsightCategory.opportunity:
        return Colors.green[600]!;
      case InsightCategory.trend:
        return Colors.blue[600]!;
      case InsightCategory.efficiency:
        return Colors.purple[600]!;
      case InsightCategory.risk:
        return Colors.red[600]!;
    }
  }

  void _toggleRealTimeMode() {
    setState(() {
      _isRealTimeMode = !_isRealTimeMode;
    });

    if (_isRealTimeMode) {
      _refreshController.repeat();
      _startRealTimeUpdates();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Real-time mode enabled')),
      );
    } else {
      _refreshController.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Real-time mode disabled')),
      );
    }
  }

  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting analytics data...')),
    );
  }

  void _showAnalyticsSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics Settings'),
        content: const Text('Configure analytics preferences and data sources.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPerformanceAlerts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Performance Alerts'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _performanceAlerts.length,
            itemBuilder: (context, index) {
              final alert = _performanceAlerts[index];
              return ListTile(
                leading: Icon(
                  Icons.warning,
                  color: _getAlertSeverityColor(alert.severity),
                ),
                title: Text(alert.title),
                subtitle: Text(alert.description),
                trailing: alert.isResolved
                    ? const Icon(Icons.check, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red),
              );
            },
          ),
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

  Color _getAlertSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue[600]!;
      case AlertSeverity.medium:
        return Colors.orange[600]!;
      case AlertSeverity.high:
        return Colors.red[600]!;
    }
  }

  void _createCustomAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Alert'),
        content: const Text('Configure custom performance alerts and thresholds.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _generateReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Report'),
        content: const Text(
          'Select metrics and time range for custom report generation.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'custom_dashboard':
        _showCustomDashboard();
        break;
      case 'schedule_reports':
        _showScheduleReports();
        break;
      case 'data_sources':
        _showDataSources();
        break;
      case 'api_access':
        _showApiAccess();
        break;
    }
  }

  void _showCustomDashboard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Dashboard'),
        content: const Text('Create personalized dashboard layouts.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showScheduleReports() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Reports'),
        content: const Text('Set up automated report delivery.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataSources() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Sources'),
        content: const Text('Configure data sources and integrations.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showApiAccess() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Access'),
        content: const Text('Generate API keys for external integrations.'),
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

// Custom painter for line charts
class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double animationValue;

  LineChartPainter(this.data, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue[600]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue[600]!.withValues(alpha: 0.3),
          Colors.blue[600]!.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].value - minValue) / valueRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final animatedX = x * animationValue;
        path.lineTo(animatedX, y);
        fillPath.lineTo(animatedX, y);
      }
    }

    fillPath.lineTo(size.width * animationValue, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Data models
class AnalyticsMetric {
  final String id;
  final String name;
  final double value;
  final double previousValue;
  final String unit;
  final String format;
  final IconData icon;
  final Color color;
  final MetricTrend trend;
  final double changePercentage;
  final double? target;
  final MetricCategory category;
  final String description;
  final bool isGood;

  AnalyticsMetric({
    required this.id,
    required this.name,
    required this.value,
    required this.previousValue,
    required this.unit,
    required this.format,
    required this.icon,
    required this.color,
    required this.trend,
    required this.changePercentage,
    this.target,
    required this.category,
    required this.description,
    required this.isGood,
  });
}

class ChartData {
  final DateTime date;
  final double value;
  final String category;

  ChartData({
    required this.date,
    required this.value,
    required this.category,
  });
}

class GeographicData {
  final String country;
  final String countryCode;
  final double percentage;
  final double revenue;
  final Color color;

  GeographicData(
    this.country,
    this.countryCode,
    this.percentage,
    this.revenue,
    this.color,
  );
}

class PlatformInsight {
  final String id;
  final String title;
  final String description;
  final InsightCategory category;
  final InsightSeverity severity;
  final DateTime timestamp;
  final bool actionable;
  final String? recommendation;
  final List<String> metrics;
  final double confidence;

  PlatformInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.timestamp,
    required this.actionable,
    this.recommendation,
    required this.metrics,
    required this.confidence,
  });
}

class PerformanceAlert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isResolved;
  final List<String> affectedMetrics;
  final String recommendedAction;

  PerformanceAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.timestamp,
    required this.isResolved,
    required this.affectedMetrics,
    required this.recommendedAction,
  });
}

enum MetricTrend { up, down }

enum MetricCategory { financial, business, users, performance, quality }

enum InsightCategory { opportunity, trend, efficiency, risk }

enum InsightSeverity { low, medium, high }

enum AlertSeverity { low, medium, high }
