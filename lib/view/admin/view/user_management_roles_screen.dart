import 'package:flutter/material.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:go_router/go_router.dart';

class UserManagementRolesScreen extends StatefulWidget {
  const UserManagementRolesScreen({super.key});

  @override
  State<UserManagementRolesScreen> createState() =>
      _UserManagementRolesScreenState();
}

class _UserManagementRolesScreenState extends State<UserManagementRolesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshController;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _usersScrollController = ScrollController();

  List<PlatformUser> _users = [];
  List<PlatformUser> _filteredUsers = [];
  List<RolePermission> _permissions = [];
  List<UserActivity> _recentActivity = [];
  String _selectedFilter = 'All Users';
  String _selectedRole = 'All Roles';
  String _selectedStatus = 'All Status';
  bool _isMultiSelectMode = false;
  List<PlatformUser> _selectedUsers = [];

  final List<String> _filterOptions = [
    'All Users',
    'Recently Added',
    'Active Users',
    'Inactive Users',
    'Pending Approval',
    'Flagged Users',
  ];

  final List<String> _roleOptions = [
    'All Roles',
    'Customer',
    'Tailor',
    'Admin',
    'Super Admin',
  ];

  final List<String> _statusOptions = [
    'All Status',
    'Active',
    'Inactive',
    'Suspended',
    'Pending',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadUsers();
    _loadPermissions();
    _loadRecentActivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _searchController.dispose();
    _usersScrollController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    // Mock data - replace with actual API call
    _users = List.generate(
      50,
      (index) => PlatformUser(
        id: 'USER${(index + 1).toString().padLeft(3, '0')}',
        email: 'user${index + 1}@example.com',
        firstName: 'User',
        lastName: '${index + 1}',
        role: UserRole.values[index % UserRole.values.length],
        status: UserStatus.values[index % UserStatus.values.length],
        avatar: null,
        phone: '+1-555-${(1000 + index).toString()}',
        joinDate: DateTime.now().subtract(Duration(days: index * 3)),
        lastLogin: index % 4 == 0
            ? null
            : DateTime.now().subtract(Duration(hours: index)),
        isOnline: index % 5 == 0,
        isVerified: index % 3 != 0,
        permissions: _generateUserPermissions(
          UserRole.values[index % UserRole.values.length],
        ),
        loginAttempts: index % 10,
        accountType: index % 4 == 0 ? AccountType.premium : AccountType.free,
        country: [
          'USA',
          'Canada',
          'UK',
          'Australia',
          'Germany',
        ][index % 5],
        city: [
          'New York',
          'Toronto',
          'London',
          'Sydney',
          'Berlin',
        ][index % 5],
        totalOrders: index * 2,
        totalSpent: (index + 1) * 150.0,
        riskScore: (index % 10) / 10.0,
        notes: index % 7 == 0 ? 'VIP Customer - Handle with priority' : null,
        tags: index % 5 == 0
            ? ['VIP', 'High Value']
            : index % 3 == 0
                ? ['New User']
                : [],
      ),
    );

    _applyFilters();
    setState(() {});
  }

  List<String> _generateUserPermissions(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return ['view_orders', 'create_orders', 'manage_profile'];
      case UserRole.tailor:
        return [
          'view_orders',
          'manage_orders',
          'communicate_customers',
          'manage_patterns',
        ];
      case UserRole.admin:
        return [
          'view_users',
          'manage_users',
          'view_analytics',
          'manage_content',
        ];
    }
  }

  void _loadPermissions() {
    _permissions = [
      RolePermission(
        'view_orders',
        'View Orders',
        'Access to view order information',
      ),
      RolePermission(
        'create_orders',
        'Create Orders',
        'Ability to place new orders',
      ),
      RolePermission(
        'manage_orders',
        'Manage Orders',
        'Full order management capabilities',
      ),
      RolePermission('view_users', 'View Users', 'Access to user directory'),
      RolePermission(
        'manage_users',
        'Manage Users',
        'User administration privileges',
      ),
      RolePermission(
        'view_analytics',
        'View Analytics',
        'Access to business analytics',
      ),
      RolePermission(
        'manage_content',
        'Manage Content',
        'Content management system access',
      ),
      RolePermission(
        'communicate_customers',
        'Customer Communication',
        'Direct customer communication',
      ),
      RolePermission(
        'manage_patterns',
        'Pattern Management',
        'Access to pattern library',
      ),
      RolePermission(
        'manage_profile',
        'Profile Management',
        'Personal profile management',
      ),
    ];
  }

  void _loadRecentActivity() {
    _recentActivity = List.generate(
      20,
      (index) => UserActivity(
        id: 'ACT${index + 1}',
        userId: 'USER${(index % 10) + 1}',
        userName: 'User ${(index % 10) + 1}',
        action: [
          'User logged in',
          'Profile updated',
          'Order placed',
          'Pattern downloaded',
          'Account suspended',
          'Role changed',
          'Password reset',
          'Email verified',
        ][index % 8],
        timestamp: DateTime.now().subtract(Duration(minutes: index * 10)),
        details: 'Additional details about the activity',
        ipAddress: '192.168.1.${100 + index}',
        deviceInfo: 'Chrome on Windows',
        riskLevel:
            ActivityRiskLevel.values[index % ActivityRiskLevel.values.length],
      ),
    );
  }

  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      final filterMatch = _selectedFilter == 'All Users' ||
          (_selectedFilter == 'Recently Added' && _isRecentlyAdded(user)) ||
          (_selectedFilter == 'Active Users' &&
              user.status == UserStatus.active) ||
          (_selectedFilter == 'Inactive Users' &&
              user.status == UserStatus.inactive) ||
          (_selectedFilter == 'Pending Approval' &&
              user.status == UserStatus.pending) ||
          (_selectedFilter == 'Flagged Users' && user.riskScore > 0.7);

      final roleMatch = _selectedRole == 'All Roles' ||
          (_selectedRole == 'Customer' && user.role == UserRole.customer) ||
          (_selectedRole == 'Tailor' && user.role == UserRole.tailor) ||
          (_selectedRole == 'Admin' && user.role == UserRole.admin) ||
          (_selectedRole == 'Super Admin' && user.role == UserRole.admin);

      final statusMatch = _selectedStatus == 'All Status' ||
          user.status.name.toLowerCase() == _selectedStatus.toLowerCase();

      return filterMatch && roleMatch && statusMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search and filters
          _buildSearchAndFilters(),

          // Stats overview
          _buildStatsOverview(),

          // Tab bar
          _buildTabBar(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildRolesTab(),
                _buildPermissionsTab(),
                _buildActivityTab(),
                _buildSecurityTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      bottomNavigationBar:
          _isMultiSelectMode ? _buildMultiSelectBottomBar() : null,
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
      title: Text(
        _isMultiSelectMode
            ? '${_selectedUsers.length} selected'
            : 'User Management',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isMultiSelectMode)
          TextButton(
            onPressed: _exitMultiSelectMode,
            child: const Text('Cancel'),
          )
        else ...[
          // Refresh
          IconButton(
            onPressed: _refreshUsers,
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

          // Export users
          IconButton(
            onPressed: _exportUsers,
            icon: Icon(Icons.download, color: Colors.grey[600]),
          ),

          // More options
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'bulk_actions',
                child: Text('Bulk Actions'),
              ),
              const PopupMenuItem(
                value: 'import_users',
                child: Text('Import Users'),
              ),
              const PopupMenuItem(value: 'audit_log', child: Text('Audit Log')),
              const PopupMenuItem(
                value: 'system_settings',
                child: Text('System Settings'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search bar
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search users by name, email, or ID...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _searchUsers,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: IconButton(
                  onPressed: _showAdvancedFilters,
                  icon: Icon(Icons.tune, color: Colors.purple[600]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filter dropdowns
          Row(
            children: [
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
                        (filter) => DropdownMenuItem(
                          value: filter,
                          child: Text(
                            filter,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
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
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  items: _roleOptions
                      .map(
                        (role) => DropdownMenuItem(
                          value: role,
                          child:
                              Text(role, style: const TextStyle(fontSize: 12)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  items: _statusOptions
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                      _applyFilters();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalUsers = _users.length;
    final activeUsers =
        _users.where((u) => u.status == UserStatus.active).length;
    final onlineUsers = _users.where((u) => u.isOnline).length;
    final pendingUsers =
        _users.where((u) => u.status == UserStatus.pending).length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Users',
              '$totalUsers',
              Icons.people,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Active',
              '$activeUsers',
              Icons.verified_user,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Online',
              '$onlineUsers',
              Icons.online_prediction,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              '$pendingUsers',
              Icons.pending,
              Colors.red,
            ),
          ),
        ],
      ),
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.purple[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.purple[600],
        isScrollable: true,
        tabs: const [
          Tab(text: 'Users'),
          Tab(text: 'Roles'),
          Tab(text: 'Permissions'),
          Tab(text: 'Activity'),
          Tab(text: 'Security'),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshUsers();
      },
      child: _filteredUsers.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _usersScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildUserCard(_filteredUsers[index]);
              },
            ),
    );
  }

  Widget _buildUserCard(PlatformUser user) {
    final isSelected = _selectedUsers.contains(user);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.purple[200]! : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _isMultiSelectMode
            ? _toggleUserSelection(user)
            : _viewUserDetails(user),
        onLongPress: () => _startMultiSelectMode(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection checkbox
              if (_isMultiSelectMode) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple[600] : Colors.white,
                    border: Border.all(
                      color:
                          isSelected ? Colors.purple[600]! : Colors.grey[400]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 16),
              ],

              // User avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        _getRoleColor(user.role).withValues(alpha: 0.1),
                    child: Text(
                      '${user.firstName.substring(0, 1)}${user.lastName.substring(0, 1)}',
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (user.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (user.accountType == AccountType.premium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[800],
                              ),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(user.status)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(user.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getRoleColor(user.role).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.role.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getRoleColor(user.role),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${user.country}, ${user.city}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (user.riskScore > 0.5) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.warning,
                            size: 14,
                            color: user.riskScore > 0.7
                                ? Colors.red[600]
                                : Colors.orange[600],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Joined: ${_formatDate(user.joinDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          user.lastLogin != null
                              ? 'Last: ${_formatTime(user.lastLogin!)}'
                              : 'Never logged in',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    if (user.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: user.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Actions
              if (!_isMultiSelectMode)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (action) => _handleUserAction(user, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Details'),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit User'),
                    ),
                    const PopupMenuItem(
                      value: 'impersonate',
                      child: Text('Impersonate'),
                    ),
                    if (user.status == UserStatus.active)
                      const PopupMenuItem(
                        value: 'suspend',
                        child: Text('Suspend'),
                      )
                    else
                      const PopupMenuItem(
                        value: 'activate',
                        child: Text('Activate'),
                      ),
                    const PopupMenuItem(
                      value: 'reset_password',
                      child: Text('Reset Password'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete User'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRolesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Roles Management',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...UserRole.values.map((role) => _buildRoleCard(role)),
        ],
      ),
    );
  }

  Widget _buildRoleCard(UserRole role) {
    final usersInRole = _users.where((u) => u.role == role).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getRoleColor(role).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRoleIcon(role),
                  color: _getRoleColor(role),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      role.description,
                      style: TextStyle(
                        fontSize: 14,
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
                    '$usersInRole',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(role),
                    ),
                  ),
                  Text(
                    'users',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Permissions preview
          Text(
            'Permissions:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: role.permissions
                .take(3)
                .map(
                  (permission) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      permission,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (role.permissions.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${role.permissions.length - 3} more',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editRolePermissions(role),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Permissions'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _viewRoleUsers(role),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getRoleColor(role),
                  ),
                  icon: const Icon(Icons.people, color: Colors.white, size: 16),
                  label: const Text(
                    'View Users',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Permissions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._permissions.map((permission) => _buildPermissionCard(permission)),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(RolePermission permission) {
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
          Text(
            permission.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            permission.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Permission ID: ${permission.id}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadRecentActivity();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _recentActivity.length,
        itemBuilder: (context, index) {
          return _buildActivityItem(_recentActivity[index]);
        },
      ),
    );
  }

  Widget _buildActivityItem(UserActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getActivityRiskColor(activity.riskLevel),
        ),
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityRiskColor(activity.riskLevel)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getActivityIcon(activity.action),
              color: _getActivityRiskColor(activity.riskLevel),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.action,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'User: ${activity.userName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'IP: ${activity.ipAddress} • ${activity.deviceInfo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getActivityRiskColor(activity.riskLevel)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity.riskLevel.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: _getActivityRiskColor(activity.riskLevel),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(activity.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Security metrics
          _buildSecurityMetrics(),

          const SizedBox(height: 24),

          // High risk users
          _buildHighRiskUsers(),
        ],
      ),
    );
  }

  Widget _buildSecurityMetrics() {
    final suspiciousLogins = _users.where((u) => u.loginAttempts > 5).length;
    final unverifiedUsers = _users.where((u) => !u.isVerified).length;
    final highRiskUsers = _users.where((u) => u.riskScore > 0.7).length;

    return Row(
      children: [
        Expanded(
          child: _buildSecurityCard(
            'Failed Logins',
            '$suspiciousLogins',
            Icons.security,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSecurityCard(
            'Unverified',
            '$unverifiedUsers',
            Icons.warning,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSecurityCard(
            'High Risk',
            '$highRiskUsers',
            Icons.dangerous,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard(
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
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

  Widget _buildHighRiskUsers() {
    final highRiskUsers = _users.where((u) => u.riskScore > 0.7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'High Risk Users',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (highRiskUsers.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 12),
                const Text(
                  'No high-risk users detected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          )
        else
          ...highRiskUsers.take(5).map(
                (user) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.red[100],
                        child: Text(
                          '${user.firstName.substring(0, 1)}${user.lastName.substring(0, 1)}',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Risk Score: ${(user.riskScore * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _reviewUser(user),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[600]!),
                        ),
                        child: const Text(
                          'Review',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildMultiSelectBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedUsers.isNotEmpty ? _bulkEditUsers : null,
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedUsers.isNotEmpty ? _bulkSuspendUsers : null,
                icon: const Icon(Icons.block),
                label: const Text('Suspend'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedUsers.isNotEmpty ? _bulkDeleteUsers : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                ),
                icon: const Icon(Icons.delete, color: Colors.white),
                label:
                    const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'bulk_import',
          onPressed: _importUsers,
          backgroundColor: Colors.green[600],
          child: const Icon(Icons.upload_file, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: _createUser,
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: const Text(
            'Add User',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isRecentlyAdded(PlatformUser user) {
    return user.joinDate
        .isAfter(DateTime.now().subtract(const Duration(days: 7)));
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Colors.blue[600]!;
      case UserRole.tailor:
        return Colors.green[600]!;
      case UserRole.admin:
        return Colors.purple[600]!;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.person;
      case UserRole.tailor:
        return Icons.design_services;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green[600]!;
      case UserStatus.inactive:
        return Colors.grey[600]!;
      case UserStatus.suspended:
        return Colors.red[600]!;
      case UserStatus.pending:
        return Colors.orange[600]!;
    }
  }

  Color _getActivityRiskColor(ActivityRiskLevel level) {
    switch (level) {
      case ActivityRiskLevel.low:
        return Colors.green[600]!;
      case ActivityRiskLevel.medium:
        return Colors.orange[600]!;
      case ActivityRiskLevel.high:
        return Colors.red[600]!;
    }
  }

  IconData _getActivityIcon(String action) {
    if (action.contains('login')) return Icons.login;
    if (action.contains('updated')) return Icons.edit;
    if (action.contains('order')) return Icons.shopping_bag;
    if (action.contains('download')) return Icons.download;
    if (action.contains('suspend')) return Icons.block;
    if (action.contains('role')) return Icons.admin_panel_settings;
    if (action.contains('password')) return Icons.lock;
    if (action.contains('verified')) return Icons.verified;
    return Icons.info;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _searchUsers(String query) {
    if (query.isEmpty) {
      _applyFilters();
      return;
    }

    setState(() {
      _filteredUsers = _users
          .where(
            (user) =>
                user.firstName.toLowerCase().contains(query.toLowerCase()) ||
                user.lastName.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()) ||
                user.id.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _refreshUsers() {
    _refreshController.forward().then((_) {
      _loadUsers();
      _refreshController.reset();
    });
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: const Text('Advanced filtering options for user management.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _startMultiSelectMode(PlatformUser user) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedUsers = [user];
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedUsers.clear();
    });
  }

  void _toggleUserSelection(PlatformUser user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  void _viewUserDetails(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.firstName} ${user.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Role: ${user.role.name}'),
            Text('Status: ${user.status.name}'),
            Text('Country: ${user.country}'),
            Text('Total Orders: ${user.totalOrders}'),
            Text('Total Spent: \$${user.totalSpent.toStringAsFixed(2)}'),
            if (user.notes != null) Text('Notes: ${user.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _editUser(user);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(PlatformUser user, String action) {
    switch (action) {
      case 'view':
        _viewUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'impersonate':
        _impersonateUser(user);
        break;
      case 'suspend':
        _suspendUser(user);
        break;
      case 'activate':
        _activateUser(user);
        break;
      case 'reset_password':
        _resetUserPassword(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _editUser(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: const Text('User editing form will be implemented here.'),
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

  void _impersonateUser(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Impersonate User'),
        content: Text(
          'Are you sure you want to impersonate ${user.firstName} ${user.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Impersonating ${user.firstName} ${user.lastName}',
                  ),
                ),
              );
            },
            child: const Text('Impersonate'),
          ),
        ],
      ),
    );
  }

  void _suspendUser(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Suspend User'),
        content: Text(
          'Are you sure you want to suspend ${user.firstName} ${user.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              setState(() {
                user.status = UserStatus.suspended;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.firstName} ${user.lastName} suspended'),
                ),
              );
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _activateUser(PlatformUser user) {
    setState(() {
      user.status = UserStatus.active;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.firstName} ${user.lastName} activated')),
    );
  }

  void _resetUserPassword(PlatformUser user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset sent to ${user.email}')),
    );
  }

  void _deleteUser(PlatformUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.firstName} ${user.lastName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              setState(() {
                _users.remove(user);
                _applyFilters();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editRolePermissions(UserRole role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${role.name} Permissions'),
        content:
            const Text('Role permissions editor will be implemented here.'),
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

  void _viewRoleUsers(UserRole role) {
    setState(() {
      _selectedRole =
          role.name.substring(0, 1).toUpperCase() + role.name.substring(1);
      _applyFilters();
      _tabController.animateTo(0); // Switch to users tab
    });
  }

  void _reviewUser(PlatformUser user) {
    _viewUserDetails(user);
  }

  void _bulkEditUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bulk Edit ${_selectedUsers.length} Users'),
        content: const Text('Bulk editing form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _bulkSuspendUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suspend ${_selectedUsers.length} Users'),
        content:
            const Text('Are you sure you want to suspend the selected users?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              setState(() {
                for (final user in _selectedUsers) {
                  user.status = UserStatus.suspended;
                }
                _selectedUsers.clear();
                _isMultiSelectMode = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selected users suspended')),
              );
            },
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _bulkDeleteUsers() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_selectedUsers.length} Users'),
        content: const Text(
          'Are you sure you want to delete the selected users? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              setState(() {
                for (final user in _selectedUsers) {
                  _users.remove(user);
                }
                _selectedUsers.clear();
                _isMultiSelectMode = false;
                _applyFilters();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selected users deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _createUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New User'),
        content: const Text('User creation form will be implemented here.'),
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

  void _importUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Importing users from CSV...')),
    );
  }

  void _exportUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting users to CSV...')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'bulk_actions':
        _startMultiSelectMode(_users.first);
        break;
      case 'import_users':
        _importUsers();
        break;
      case 'audit_log':
        _showAuditLog();
        break;
      case 'system_settings':
        _showSystemSettings();
        break;
    }
  }

  void _showAuditLog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audit Log'),
        content: const Text('System audit log will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSystemSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Settings'),
        content: const Text('User management system settings.'),
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

// Data models
class PlatformUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  UserStatus status;
  final String? avatar;
  final String phone;
  final DateTime joinDate;
  final DateTime? lastLogin;
  final bool isOnline;
  final bool isVerified;
  final List<String> permissions;
  final int loginAttempts;
  final AccountType accountType;
  final String country;
  final String city;
  final int totalOrders;
  final double totalSpent;
  final double riskScore;
  final String? notes;
  final List<String> tags;

  PlatformUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    this.avatar,
    required this.phone,
    required this.joinDate,
    this.lastLogin,
    required this.isOnline,
    required this.isVerified,
    required this.permissions,
    required this.loginAttempts,
    required this.accountType,
    required this.country,
    required this.city,
    required this.totalOrders,
    required this.totalSpent,
    required this.riskScore,
    this.notes,
    required this.tags,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class RolePermission {
  final String id;
  final String name;
  final String description;

  RolePermission(this.id, this.name, this.description);
}

class UserActivity {
  final String id;
  final String userId;
  final String userName;
  final String action;
  final DateTime timestamp;
  final String details;
  final String ipAddress;
  final String deviceInfo;
  final ActivityRiskLevel riskLevel;

  UserActivity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.action,
    required this.timestamp,
    required this.details,
    required this.ipAddress,
    required this.deviceInfo,
    required this.riskLevel,
  });
}

enum UserStatus { active, inactive, suspended, pending }

enum AccountType { free, premium, enterprise }

enum ActivityRiskLevel { low, medium, high }
