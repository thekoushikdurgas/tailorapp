import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;

  String _selectedTimeRange = 'Last 30 Days';
  final bool _isRealTimeMode = true;

  final List<String> _timeRanges = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last Year',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Executive Summary Cards
          _buildExecutiveSummary(),

          // Tabbed Content
          _buildTabBar(),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildUsersTab(),
                _buildRevenueTab(),
                _buildSystemTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildQuickActionsFAB(),
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
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[600]!, Colors.blue[600]!],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        // Real-time indicator
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isRealTimeMode
                          ? Colors.green[600]!.withValues(
                              alpha: 0.5 + _pulseController.value * 0.5,
                            )
                          : Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isRealTimeMode ? Colors.green[600] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Time range selector
        PopupMenuButton<String>(
          icon: Icon(Icons.date_range, color: Colors.grey[600]),
          onSelected: (value) => setState(() => _selectedTimeRange = value),
          itemBuilder: (context) =>
              _timeRanges.map((range) => PopupMenuItem(value: range, child: Text(range))).toList(),
        ),

        // System alerts
        IconButton(
          onPressed: () {
            context.push(RouteEnum.notificationsCenter.rawValue);
          },
          icon: Stack(
            children: [
              Icon(Icons.notifications_outlined, color: Colors.grey[600]),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Admin profile
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  _showAdminProfile(context);
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.purple[100],
                  child: Icon(
                    Icons.person,
                    color: Colors.purple[600],
                    size: 20,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExecutiveSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildKPICard(
              'Total Users',
              '12,450',
              '+15.3%',
              Icons.people,
              Colors.blue,
              true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKPICard(
              'Revenue',
              '\$248K',
              '+23.1%',
              Icons.trending_up,
              Colors.green,
              true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKPICard(
              'Active Orders',
              '3,247',
              '+8.7%',
              Icons.shopping_bag,
              Colors.orange,
              true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKPICard(
              'System Health',
              '99.8%',
              '+0.1%',
              Icons.health_and_safety,
              Colors.purple,
              true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    bool isPositive,
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green[600] : Colors.red[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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
        isScrollable: true,
        labelColor: Colors.purple[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.purple[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Users'),
          Tab(text: 'Revenue'),
          Tab(text: 'System'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business metrics charts
          _buildSectionHeader('Business Performance', Icons.trending_up),
          const SizedBox(height: 16),
          _buildPerformanceChart(),
          const SizedBox(height: 24),

          // Geographic analytics
          _buildSectionHeader('Geographic Usage', Icons.public),
          const SizedBox(height: 16),
          _buildGeographicChart(),
          const SizedBox(height: 24),

          // Recent activity
          _buildSectionHeader('Recent Platform Activity', Icons.history_edu),
          const SizedBox(height: 16),
          _buildRecentActivity(),
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
          // User statistics
          _buildSectionHeader('User Statistics', Icons.people),
          const SizedBox(height: 16),
          _buildUserStats(),
          const SizedBox(height: 24),

          // User activity
          _buildSectionHeader('User Activity Monitor', Icons.monitor),
          const SizedBox(height: 16),
          _buildUserActivityMonitor(),
          const SizedBox(height: 24),

          // Quick actions
          _buildSectionHeader('User Management Actions', Icons.settings),
          const SizedBox(height: 16),
          _buildUserManagementActions(),
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
          // Revenue charts
          _buildSectionHeader('Revenue Analytics', Icons.attach_money),
          const SizedBox(height: 16),
          _buildRevenueChart(),
          const SizedBox(height: 24),

          // Financial forecasting
          _buildSectionHeader('Financial Forecasting', Icons.timeline),
          const SizedBox(height: 16),
          _buildFinancialForecast(),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System health
          _buildSectionHeader('System Health', Icons.health_and_safety),
          const SizedBox(height: 16),
          _buildSystemHealth(),
          const SizedBox(height: 24),

          // A/B testing
          _buildSectionHeader('A/B Testing', Icons.science),
          const SizedBox(height: 16),
          _buildABTesting(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Predictive analytics
          _buildSectionHeader('Predictive Analytics', Icons.psychology),
          const SizedBox(height: 16),
          _buildPredictiveAnalytics(),
          const SizedBox(height: 24),

          // Custom reports
          _buildSectionHeader('Custom Reports', Icons.bar_chart),
          const SizedBox(height: 16),
          _buildCustomReports(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.purple[600], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.purple[800],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
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
            'Revenue Growth Trend',
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
              children: List.generate(7, (index) {
                final height = 50.0 + (index * 15.0);
                return Container(
                  width: 20,
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
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map(
                  (day) => Text(
                    day,
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
    );
  }

  Widget _buildGeographicChart() {
    return Container(
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
            'Global User Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.public,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGeographicItem('North America', '45%', Colors.blue),
                    _buildGeographicItem('Europe', '32%', Colors.green),
                    _buildGeographicItem('Asia', '18%', Colors.orange),
                    _buildGeographicItem('Others', '5%', Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicItem(String region, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$region: $percentage',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      ActivityItem(
        'New user registration spike',
        '2 min ago',
        Icons.person_add,
        Colors.green,
      ),
      ActivityItem(
        'Payment processing delay',
        '5 min ago',
        Icons.warning,
        Colors.orange,
      ),
      ActivityItem(
        'Server maintenance completed',
        '1 hour ago',
        Icons.build,
        Colors.blue,
      ),
      ActivityItem(
        'New feature deployed',
        '3 hours ago',
        Icons.rocket_launch,
        Colors.purple,
      ),
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
        children: activities.map((activity) => _buildActivityItem(activity)).toList(),
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: activity.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(activity.icon, color: activity.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  activity.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Users',
            '8,247',
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'New Signups',
            '145',
            Icons.person_add,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Churn Rate',
            '2.3%',
            Icons.trending_down,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
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
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivityMonitor() {
    return Container(
      height: 150,
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
      child: const Center(
        child: Text(
          'Real-time user activity heatmap\n(Advanced analytics visualization)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildUserManagementActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.push(RouteEnum.userManagementRoles.rawValue);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.all(16),
            ),
            icon: const Icon(Icons.people, color: Colors.white),
            label: const Text(
              'Manage Users',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showBulkActions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              padding: const EdgeInsets.all(16),
            ),
            icon: const Icon(Icons.batch_prediction, color: Colors.white),
            label: const Text(
              'Bulk Actions',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return Container(
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
      child: const Center(
        child: Text(
          'Advanced Revenue Analytics Chart\n(Monthly/Quarterly/Yearly views)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialForecast() {
    return Container(
      height: 150,
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
      child: const Center(
        child: Text(
          'AI-Powered Financial Forecasting\n(Predictive revenue modeling)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSystemHealth() {
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
        children: [
          _buildHealthMetric('API Response Time', '125ms', Colors.green),
          _buildHealthMetric('Database Performance', '98.7%', Colors.green),
          _buildHealthMetric('CDN Delivery', '99.9%', Colors.green),
          _buildHealthMetric('Error Rate', '0.02%', Colors.green),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String metric, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildABTesting() {
    return Container(
      height: 150,
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
      child: const Center(
        child: Text(
          'A/B Testing Management\n(Feature flag control & experiment results)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPredictiveAnalytics() {
    return Container(
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
      child: const Center(
        child: Text(
          'AI-Powered Predictive Analytics\n(Machine learning insights & forecasting)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomReports() {
    return Container(
      height: 150,
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
      child: const Center(
        child: Text(
          'Custom Report Builder\n(Drag & drop analytics dashboard)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsFAB() {
    return FloatingActionButton.extended(
      onPressed: _showQuickActions,
      backgroundColor: Colors.purple[600],
      foregroundColor: Colors.white,
      icon: const Icon(Icons.flash_on),
      label: const Text(
        'Quick Actions',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  // Helper methods
  void _showAdminProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Profile'),
        content: const Text('Admin profile management and settings.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickActionItem('Users', Icons.people, () {
                  context.pop();
                  context.push(RouteEnum.userManagementRoles.rawValue);
                }),
                _buildQuickActionItem('Analytics', Icons.analytics, () {
                  context.pop();
                  context.push(RouteEnum.platformAnalyticsInsights.rawValue);
                }),
                _buildQuickActionItem('Settings', Icons.settings, () {
                  context.pop();
                  context.push(RouteEnum.systemConfigurationSettings.rawValue);
                }),
                _buildQuickActionItem('Reports', Icons.assessment, () {
                  context.pop();
                  _generateReport();
                }),
                _buildQuickActionItem('Backup', Icons.backup, () {
                  context.pop();
                  _initiateBackup();
                }),
                _buildQuickActionItem('Support', Icons.support_agent, () {
                  context.pop();
                  context.push(RouteEnum.universalSupport.rawValue);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.purple[600], size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkActions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Actions'),
        content: const Text('Perform bulk operations on users, orders, or content.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Execute'),
          ),
        ],
      ),
    );
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating comprehensive report...')),
    );
  }

  void _initiateBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Initiating system backup...')),
    );
  }
}

class ActivityItem {
  final String title;
  final String time;
  final IconData icon;
  final Color color;

  ActivityItem(this.title, this.time, this.icon, this.color);
}
