import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshController;

  UserRole? _userRole;
  List<AppNotification> _notifications = [];
  List<AppNotification> _filteredNotifications = [];
  String _selectedFilter = 'All';
  bool _showUnreadOnly = false;

  final List<String> _filterOptions = [
    'All',
    'Orders',
    'Messages',
    'System',
    'Marketing',
    'Updates',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadUserRole();
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _loadUserRole() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _userRole = authState.userRole;
      });
    }
  }

  void _loadNotifications() {
    // Mock data with role-specific notifications
    final baseNotifications = [
      AppNotification(
        id: 'notif_1',
        title: 'Welcome to TailorApp!',
        message: 'Thank you for joining our platform. Let\'s get started!',
        type: NotificationType.system,
        priority: NotificationPriority.medium,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        category: 'Welcome',
        actionUrl: RouteEnum.intro.rawValue,
        icon: Icons.waving_hand,
        color: Colors.blue,
      ),
      AppNotification(
        id: 'notif_2',
        title: 'Security Update',
        message: 'Your account security has been enhanced with new features.',
        type: NotificationType.security,
        priority: NotificationPriority.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        category: 'Security',
        icon: Icons.security,
        color: Colors.orange,
      ),
    ];

    final roleNotifications = <AppNotification>[];

    switch (_userRole) {
      case UserRole.customer:
        roleNotifications.addAll([
          AppNotification(
            id: 'notif_3',
            title: 'Order Update',
            message: 'Your order #ORD001 is now in progress!',
            type: NotificationType.order,
            priority: NotificationPriority.high,
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            isRead: false,
            category: 'Orders',
            actionUrl: RouteEnum.customerOrderTimeline.rawValue,
            icon: Icons.shopping_bag,
            color: Colors.green,
          ),
          AppNotification(
            id: 'notif_4',
            title: 'New Design Suggestion',
            message: 'AI has found 3 new designs that match your style!',
            type: NotificationType.recommendation,
            priority: NotificationPriority.medium,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            isRead: false,
            category: 'AI Suggestions',
            actionUrl: RouteEnum.designWishlist.rawValue,
            icon: Icons.auto_awesome,
            color: Colors.purple,
          ),
          AppNotification(
            id: 'notif_5',
            title: 'Virtual Fitting Ready',
            message: 'Try on your new design with AR technology!',
            type: NotificationType.feature,
            priority: NotificationPriority.medium,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            isRead: true,
            category: 'Features',
            actionUrl: RouteEnum.virtualFitting.rawValue,
            icon: Icons.view_in_ar,
            color: Colors.teal,
          ),
        ]);
        break;

      case UserRole.tailor:
        roleNotifications.addAll([
          AppNotification(
            id: 'notif_6',
            title: 'New Order Received',
            message:
                'Customer John Doe has placed a new order for a custom suit.',
            type: NotificationType.order,
            priority: NotificationPriority.urgent,
            timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
            isRead: false,
            category: 'Orders',
            actionUrl: RouteEnum.orderManagement.rawValue,
            icon: Icons.assignment,
            color: Colors.red,
          ),
          AppNotification(
            id: 'notif_7',
            title: 'Customer Message',
            message: 'Sarah Johnson sent you a message about her dress order.',
            type: NotificationType.message,
            priority: NotificationPriority.high,
            timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            isRead: false,
            category: 'Messages',
            actionUrl: RouteEnum.customerCommunicationHub.rawValue,
            icon: Icons.chat,
            color: Colors.blue,
          ),
          AppNotification(
            id: 'notif_8',
            title: 'Payment Received',
            message: 'Payment of \$250 received for order #ORD003.',
            type: NotificationType.payment,
            priority: NotificationPriority.medium,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: true,
            category: 'Payments',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ]);
        break;

      case UserRole.admin:
        roleNotifications.addAll([
          AppNotification(
            id: 'notif_9',
            title: 'System Alert',
            message: 'Server CPU usage exceeded 85% threshold.',
            type: NotificationType.system,
            priority: NotificationPriority.urgent,
            timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
            isRead: false,
            category: 'System',
            icon: Icons.warning,
            color: Colors.red,
          ),
          AppNotification(
            id: 'notif_10',
            title: 'User Registration Spike',
            message: '50+ new users registered in the last hour.',
            type: NotificationType.analytics,
            priority: NotificationPriority.medium,
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            isRead: false,
            category: 'Analytics',
            actionUrl: RouteEnum.platformAnalyticsInsights.rawValue,
            icon: Icons.trending_up,
            color: Colors.blue,
          ),
          AppNotification(
            id: 'notif_11',
            title: 'Revenue Milestone',
            message: 'Monthly revenue target achieved! \$50K reached.',
            type: NotificationType.milestone,
            priority: NotificationPriority.medium,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
            isRead: true,
            category: 'Milestones',
            icon: Icons.celebration,
            color: Colors.amber,
          ),
        ]);
        break;

      default:
        break;
    }

    setState(() {
      _notifications = [...baseNotifications, ...roleNotifications];
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredNotifications = _notifications.where((notification) {
      final matchesFilter = _selectedFilter == 'All' ||
          notification.category
              .toLowerCase()
              .contains(_selectedFilter.toLowerCase());
      final matchesReadStatus = !_showUnreadOnly || !notification.isRead;

      return matchesFilter && matchesReadStatus;
    }).toList();

    // Sort by timestamp (newest first)
    _filteredNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Summary cards
          _buildSummaryCards(),

          // Filters and controls
          _buildFiltersSection(),

          // Tab bar
          _buildTabBar(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsTab(),
                _buildActivityTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: Row(
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Refresh
        IconButton(
          onPressed: _refreshNotifications,
          icon: AnimatedBuilder(
            animation: _refreshController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _refreshController.value * 2 * 3.14159,
                child: Icon(Icons.refresh, color: Colors.grey[600]),
              );
            },
          ),
        ),

        // Mark all as read
        if (unreadCount > 0)
          IconButton(
            onPressed: _markAllAsRead,
            icon: Icon(Icons.done_all, color: Colors.grey[600]),
          ),

        // Search
        IconButton(
          onPressed: _showSearch,
          icon: Icon(Icons.search, color: Colors.grey[600]),
        ),

        // More options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'preferences',
              child: Text('Notification Preferences'),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Text('Export Notifications'),
            ),
            const PopupMenuItem(
              value: 'clear_old',
              child: Text('Clear Old Notifications'),
            ),
            const PopupMenuItem(
              value: 'test',
              child: Text('Send Test Notification'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final totalNotifications = _notifications.length;
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final urgentCount = _notifications
        .where((n) => n.priority == NotificationPriority.urgent && !n.isRead)
        .length;
    final todayCount =
        _notifications.where((n) => _isToday(n.timestamp)).length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total',
              '$totalNotifications',
              Icons.notifications,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Unread',
              '$unreadCount',
              Icons.mark_email_unread,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Urgent',
              '$urgentCount',
              Icons.priority_high,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Today',
              '$todayCount',
              Icons.today,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
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

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          // Filter dropdown
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              items: _filterOptions
                  .map(
                    (filter) =>
                        DropdownMenuItem(value: filter, child: Text(filter)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                  _applyFilters();
                });
              },
            ),
          ),

          const SizedBox(width: 12),

          // Unread only toggle
          Row(
            children: [
              Text(
                'Unread only',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Switch(
                value: _showUnreadOnly,
                onChanged: (value) {
                  setState(() {
                    _showUnreadOnly = value;
                    _applyFilters();
                  });
                },
              ),
            ],
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
        labelColor: Colors.blue[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[600],
        tabs: const [
          Tab(text: 'Notifications'),
          Tab(text: 'Activity'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshNotifications();
      },
      child: _filteredNotifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(_filteredNotifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: notification.isRead
                                  ? Colors.black87
                                  : Colors.blue[800],
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(notification.priority)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification.priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(notification.priority),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: notification.isRead
                            ? Colors.grey[700]
                            : Colors.black87,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Footer
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Actions
              Column(
                children: [
                  if (!notification.isRead)
                    IconButton(
                      onPressed: () => _markAsRead(notification),
                      icon: Icon(
                        Icons.mark_email_read,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                    onSelected: (action) =>
                        _handleNotificationAction(notification, action),
                    itemBuilder: (context) => [
                      if (!notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Text('Mark as Read'),
                        ),
                      if (notification.isRead)
                        const PopupMenuItem(
                          value: 'mark_unread',
                          child: Text('Mark as Unread'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      if (notification.actionUrl != null)
                        const PopupMenuItem(value: 'open', child: Text('Open')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Activity timeline
          ..._buildActivityTimeline(),
        ],
      ),
    );
  }

  List<Widget> _buildActivityTimeline() {
    final activities = [
      ActivityItem(
        'Logged in',
        DateTime.now().subtract(const Duration(minutes: 5)),
        Icons.login,
      ),
      ActivityItem(
        'Updated profile',
        DateTime.now().subtract(const Duration(hours: 1)),
        Icons.person,
      ),
      ActivityItem(
        'Viewed order details',
        DateTime.now().subtract(const Duration(hours: 2)),
        Icons.visibility,
      ),
      ActivityItem(
        'Received notification',
        DateTime.now().subtract(const Duration(hours: 3)),
        Icons.notifications,
      ),
    ];

    return activities
        .map(
          (activity) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(activity.icon, color: Colors.blue[600], size: 20),
                ),
                const SizedBox(width: 16),
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
                        _formatTime(activity.timestamp),
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
          ),
        )
        .toList();
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Notification preferences
          _buildSettingSection('Push Notifications', [
            _buildSettingToggle('Order Updates', true),
            _buildSettingToggle('Messages', true),
            _buildSettingToggle('System Alerts', true),
            _buildSettingToggle('Marketing', false),
          ]),

          const SizedBox(height: 24),

          _buildSettingSection('Email Notifications', [
            _buildSettingToggle('Daily Summary', true),
            _buildSettingToggle('Weekly Reports', false),
            _buildSettingToggle('Promotional Emails', false),
          ]),

          const SizedBox(height: 24),

          _buildSettingSection('Sound & Vibration', [
            _buildSettingToggle('Notification Sound', true),
            _buildSettingToggle('Vibration', true),
            _buildSettingItem('Ringtone', 'Default', () {}),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title, List<Widget> children) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingToggle(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // Handle toggle
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
          heroTag: 'compose',
          onPressed: _composeNotification,
          backgroundColor: Colors.blue[600],
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  // Helper methods
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green[600]!;
      case NotificationPriority.medium:
        return Colors.orange[600]!;
      case NotificationPriority.high:
        return Colors.red[600]!;
      case NotificationPriority.urgent:
        return Colors.purple[600]!;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _refreshNotifications() {
    _refreshController.forward().then((_) {
      _loadNotifications();
      _refreshController.reset();
    });
  }

  void _markAsRead(AppNotification notification) {
    setState(() {
      notification.isRead = true;
      _applyFilters();
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    if (notification.actionUrl != null) {
      context.push(notification.actionUrl!);
    }
  }

  void _handleNotificationAction(AppNotification notification, String action) {
    switch (action) {
      case 'mark_read':
        _markAsRead(notification);
        break;
      case 'mark_unread':
        setState(() {
          notification.isRead = false;
          _applyFilters();
        });
        break;
      case 'delete':
        setState(() {
          _notifications.remove(notification);
          _applyFilters();
        });
        break;
      case 'open':
        if (notification.actionUrl != null) {
          context.push(notification.actionUrl!);
        }
        break;
    }
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Notifications'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search notifications...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _composeNotification() {
    if (_userRole == UserRole.admin) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Send Notification'),
          content: const Text('Compose and send notifications to users.'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Send'),
            ),
          ],
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'preferences':
        _tabController.animateTo(2); // Switch to settings tab
        break;
      case 'export':
        _exportNotifications();
        break;
      case 'clear_old':
        _clearOldNotifications();
        break;
      case 'test':
        _sendTestNotification();
        break;
    }
  }

  void _exportNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting notifications...')),
    );
  }

  void _clearOldNotifications() {
    setState(() {
      _notifications.removeWhere(
        (n) =>
            n.isRead &&
            n.timestamp
                .isBefore(DateTime.now().subtract(const Duration(days: 7))),
      );
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Old notifications cleared')),
    );
  }

  void _sendTestNotification() {
    final testNotification = AppNotification(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Notification',
      message:
          'This is a test notification sent at ${DateTime.now().toLocal()}',
      type: NotificationType.system,
      priority: NotificationPriority.low,
      timestamp: DateTime.now(),
      isRead: false,
      category: 'Test',
      icon: Icons.bug_report,
      color: Colors.purple,
    );

    setState(() {
      _notifications.insert(0, testNotification);
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test notification sent')),
    );
  }
}

// Data models
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  bool isRead;
  final String category;
  final String? actionUrl;
  final IconData icon;
  final Color color;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    required this.isRead,
    required this.category,
    this.actionUrl,
    required this.icon,
    required this.color,
  });
}

class ActivityItem {
  final String title;
  final DateTime timestamp;
  final IconData icon;

  ActivityItem(this.title, this.timestamp, this.icon);
}

enum NotificationType {
  system,
  order,
  message,
  payment,
  security,
  recommendation,
  feature,
  analytics,
  milestone,
  marketing
}

enum NotificationPriority { low, medium, high, urgent }
