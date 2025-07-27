import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _refreshController;

  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All Orders';
  final String _selectedStatus = 'All Status';
  final String _selectedPriority = 'All Priority';
  bool _isGridView = false;
  List<TailorOrder> _orders = [];
  TailorOrder? _selectedOrder;

  final List<String> _filterOptions = [
    'All Orders',
    'Active Orders',
    'Pending Review',
    'Ready for Delivery',
    'Completed',
    'Overdue',
  ];

  final List<String> _statusOptions = [
    'All Status',
    'Received',
    'In Progress',
    'Pending Approval',
    'Ready',
    'Delivered',
  ];

  final List<String> _priorityOptions = [
    'All Priority',
    'Low',
    'Medium',
    'High',
    'Urgent',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    // Mock data - replace with actual API call
    _orders = List.generate(
      15,
      (index) => TailorOrder(
        id: 'ORD${(index + 1).toString().padLeft(3, '0')}',
        customerName: 'Customer ${index + 1}',
        customerAvatar: null,
        garmentType: [
          'Shirt',
          'Dress',
          'Suit',
          'Pants',
          'Jacket',
        ][index % 5],
        status: OrderStatus.values[index % OrderStatus.values.length],
        priority: OrderPriority.values[index % OrderPriority.values.length],
        orderDate: DateTime.now().subtract(Duration(days: index * 2)),
        dueDate: DateTime.now().add(Duration(days: 14 - index)),
        totalAmount: 150 + (index * 25),
        paidAmount:
            index % 3 == 0 ? 150 + (index * 25) : (150 + (index * 25)) * 0.5,
        progress: 0.2 + (index * 0.1),
        measurements: OrderMeasurements(),
        specialInstructions:
            index % 3 == 0 ? 'Special fabric requirements' : null,
        attachments: index % 4 == 0 ? ['design1.jpg', 'reference2.png'] : [],
        communicationHistory: [],
        workflowSteps: _generateWorkflowSteps(index),
      ),
    );
    setState(() {});
  }

  List<WorkflowStep> _generateWorkflowSteps(int orderIndex) {
    final steps = [
      WorkflowStep(
        'Order Received',
        true,
        DateTime.now().subtract(Duration(days: orderIndex * 2)),
      ),
      WorkflowStep(
        'Measurements Confirmed',
        orderIndex < 10,
        orderIndex < 10
            ? DateTime.now().subtract(Duration(days: orderIndex * 2 - 1))
            : null,
      ),
      WorkflowStep(
        'Cutting',
        orderIndex < 8,
        orderIndex < 8
            ? DateTime.now().subtract(Duration(days: orderIndex * 2 - 2))
            : null,
      ),
      WorkflowStep(
        'Stitching',
        orderIndex < 6,
        orderIndex < 6
            ? DateTime.now().subtract(Duration(days: orderIndex * 2 - 3))
            : null,
      ),
      WorkflowStep(
        'First Fitting',
        orderIndex < 4,
        orderIndex < 4
            ? DateTime.now().subtract(Duration(days: orderIndex * 2 - 4))
            : null,
      ),
      WorkflowStep(
        'Final Touches',
        orderIndex < 2,
        orderIndex < 2
            ? DateTime.now().subtract(Duration(days: orderIndex * 2 - 5))
            : null,
      ),
      WorkflowStep(
        'Quality Check',
        orderIndex == 0,
        orderIndex == 0
            ? DateTime.now().subtract(const Duration(days: 1))
            : null,
      ),
      WorkflowStep('Ready for Delivery', false, null),
    ];
    return steps;
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
                _buildAllOrdersTab(),
                _buildActiveOrdersTab(),
                _buildCalendarTab(),
                _buildAnalyticsTab(),
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
        'Order Management',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Refresh button
        IconButton(
          onPressed: _refreshOrders,
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

        // View toggle
        IconButton(
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          icon: Icon(
            _isGridView ? Icons.list : Icons.grid_view,
            color: Colors.grey[600],
          ),
        ),

        // More options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'export', child: Text('Export Orders')),
            const PopupMenuItem(
              value: 'templates',
              child: Text('Order Templates'),
            ),
            const PopupMenuItem(
              value: 'automation',
              child: Text('Workflow Automation'),
            ),
            const PopupMenuItem(
              value: 'reports',
              child: Text('Generate Report'),
            ),
          ],
        ),
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
                      hintText: 'Search orders, customers...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _searchOrders,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: IconButton(
                  onPressed: _showAdvancedFilters,
                  icon: Icon(Icons.tune, color: Colors.blue[600]),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue[600],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Active Orders',
              '${_orders.where((o) => o.status != OrderStatus.delivered).length}',
              Icons.assignment,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Due Today',
              '${_orders.where((o) => _isDueToday(o.dueDate)).length}',
              Icons.today,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Overdue',
              '${_orders.where((o) => _isOverdue(o.dueDate)).length}',
              Icons.warning,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Revenue',
              '\$${_orders.fold(0.0, (sum, o) => sum + o.paidAmount).toInt()}K',
              Icons.attach_money,
              Colors.green,
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
        labelColor: Colors.blue[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[600],
        tabs: const [
          Tab(text: 'All Orders'),
          Tab(text: 'Active'),
          Tab(text: 'Calendar'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildAllOrdersTab() {
    final filteredOrders = _getFilteredOrders();

    return RefreshIndicator(
      onRefresh: () async {
        _loadOrders();
      },
      child: _isGridView
          ? _buildGridView(filteredOrders)
          : _buildListView(filteredOrders),
    );
  }

  Widget _buildListView(List<TailorOrder> orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(orders[index]),
    );
  }

  Widget _buildGridView(List<TailorOrder> orders) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderGridCard(orders[index]),
    );
  }

  Widget _buildOrderCard(TailorOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _isOverdue(order.dueDate) ? Colors.red[200]! : Colors.grey[200]!,
          width: _isOverdue(order.dueDate) ? 2 : 1,
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
        onTap: () => _viewOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      order.customerName.substring(0, 1),
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          order.id,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          _getStatusColor(order.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Order details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.garmentType,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Due: ${_formatDate(order.dueDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isOverdue(order.dueDate)
                                ? Colors.red[600]
                                : Colors.grey[600],
                            fontWeight: _isOverdue(order.dueDate)
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${order.totalAmount.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (order.paidAmount < order.totalAmount)
                        Text(
                          'Paid: \$${order.paidAmount.toInt()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(order.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: order.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      order.progress < 0.3
                          ? Colors.red[400]!
                          : order.progress < 0.7
                              ? Colors.orange[400]!
                              : Colors.green[400]!,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateProgress(order),
                      icon: const Icon(Icons.update, size: 16),
                      label: const Text('Update'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _contactCustomer(order),
                      icon: const Icon(Icons.chat, size: 16),
                      label: const Text('Contact'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showOrderMenu(order),
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderGridCard(TailorOrder order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _isOverdue(order.dueDate) ? Colors.red[200]! : Colors.grey[200]!,
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
        onTap: () => _viewOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer avatar and status
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      order.customerName.substring(0, 1),
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(order.priority)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.priority.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(order.priority),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order info
              Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                order.garmentType,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              // Progress
              LinearProgressIndicator(
                value: order.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
              ),

              const SizedBox(height: 8),

              // Amount and due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${order.totalAmount.toInt()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _formatDate(order.dueDate),
                    style: TextStyle(
                      fontSize: 10,
                      color: _isOverdue(order.dueDate)
                          ? Colors.red[600]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrdersTab() {
    final activeOrders = _orders
        .where((order) => order.status != OrderStatus.delivered)
        .toList();
    return _buildListView(activeOrders);
  }

  Widget _buildCalendarTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Calendar View\n(Integration with calendar widget)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Analytics charts and metrics
          Text(
            'Order Analytics\n(Business intelligence dashboard)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
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
          heroTag: 'quick_update',
          onPressed: _quickUpdate,
          backgroundColor: Colors.green[600],
          child: const Icon(Icons.flash_on, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: _createNewOrder,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'New Order',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Helper methods
  List<TailorOrder> _getFilteredOrders() {
    return _orders.where((order) {
      // Apply filters based on selected options
      if (_selectedFilter != 'All Orders') {
        switch (_selectedFilter) {
          case 'Active Orders':
            return order.status != OrderStatus.delivered;
          case 'Pending Review':
            return order.status == OrderStatus.pendingApproval;
          case 'Ready for Delivery':
            return order.status == OrderStatus.ready;
          case 'Completed':
            return order.status == OrderStatus.delivered;
          case 'Overdue':
            return _isOverdue(order.dueDate);
        }
      }
      return true;
    }).toList();
  }

  bool _isDueToday(DateTime dueDate) {
    final today = DateTime.now();
    return dueDate.year == today.year &&
        dueDate.month == today.month &&
        dueDate.day == today.day;
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return Colors.blue[600]!;
      case OrderStatus.inProgress:
        return Colors.orange[600]!;
      case OrderStatus.pendingApproval:
        return Colors.purple[600]!;
      case OrderStatus.ready:
        return Colors.green[600]!;
      case OrderStatus.delivered:
        return Colors.grey[600]!;
    }
  }

  Color _getPriorityColor(OrderPriority priority) {
    switch (priority) {
      case OrderPriority.low:
        return Colors.green[600]!;
      case OrderPriority.medium:
        return Colors.orange[600]!;
      case OrderPriority.high:
        return Colors.red[600]!;
      case OrderPriority.urgent:
        return Colors.purple[600]!;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else {
      return '${-difference.inDays} days overdue';
    }
  }

  void _searchOrders(String query) {
    // Implement search functionality
  }

  void _refreshOrders() {
    _refreshController.forward().then((_) {
      _loadOrders();
      _refreshController.reset();
    });
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content:
            const Text('Advanced filtering options will be implemented here.'),
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

  void _viewOrderDetails(TailorOrder order) {
    setState(() {
      _selectedOrder = order;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) =>
            _buildOrderDetailsSheet(order, scrollController),
      ),
    );
  }

  Widget _buildOrderDetailsSheet(
    TailorOrder order,
    ScrollController scrollController,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Order information
            Text(
              '${order.id} - ${order.customerName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // Workflow steps
            const Text(
              'Progress Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            ...order.workflowSteps.map((step) => _buildWorkflowStep(step)),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateProgress(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'Update Progress',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _contactCustomer(order),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Contact Customer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowStep(WorkflowStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: step.isCompleted ? Colors.green[600] : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: step.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: step.isCompleted ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                if (step.completedAt != null)
                  Text(
                    'Completed ${_formatDate(step.completedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateProgress(TailorOrder order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating progress for ${order.id}...')),
    );
  }

  void _contactCustomer(TailorOrder order) {
    context.push(
      '${RouteEnum.customerCommunicationHub.rawValue}?customer=${order.customerName}',
    );
  }

  void _showOrderMenu(TailorOrder order) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Order'),
              onTap: () {
                context.pop();
                _editOrder(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                context.pop();
                _viewOrderDetails(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Message Customer'),
              onTap: () {
                context.pop();
                _contactCustomer(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Generate Invoice'),
              onTap: () {
                context.pop();
                _generateInvoice(order);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editOrder(TailorOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Order'),
        content: const Text('Order editing form will be implemented here.'),
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

  void _generateInvoice(TailorOrder order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating invoice for ${order.id}...')),
    );
  }

  void _createNewOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Order'),
        content:
            const Text('New order creation form will be implemented here.'),
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

  void _quickUpdate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Update'),
        content: const Text('Quick update options for multiple orders.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportOrders();
        break;
      case 'templates':
        _showOrderTemplates();
        break;
      case 'automation':
        _showWorkflowAutomation();
        break;
      case 'reports':
        _generateReport();
        break;
    }
  }

  void _exportOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting orders to CSV...')),
    );
  }

  void _showOrderTemplates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Templates'),
        content: const Text('Manage your order templates for quick creation.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showWorkflowAutomation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workflow Automation'),
        content: const Text('Configure automated workflow rules and triggers.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating order management report...')),
    );
  }
}

// Data models
class TailorOrder {
  final String id;
  final String customerName;
  final String? customerAvatar;
  final String garmentType;
  final OrderStatus status;
  final OrderPriority priority;
  final DateTime orderDate;
  final DateTime dueDate;
  final double totalAmount;
  final double paidAmount;
  final double progress;
  final OrderMeasurements measurements;
  final String? specialInstructions;
  final List<String> attachments;
  final List<String> communicationHistory;
  final List<WorkflowStep> workflowSteps;

  TailorOrder({
    required this.id,
    required this.customerName,
    this.customerAvatar,
    required this.garmentType,
    required this.status,
    required this.priority,
    required this.orderDate,
    required this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.progress,
    required this.measurements,
    this.specialInstructions,
    required this.attachments,
    required this.communicationHistory,
    required this.workflowSteps,
  });
}

class OrderMeasurements {
  // Add measurement fields as needed
  OrderMeasurements();
}

class WorkflowStep {
  final String name;
  final bool isCompleted;
  final DateTime? completedAt;

  WorkflowStep(this.name, this.isCompleted, this.completedAt);
}

enum OrderStatus { received, inProgress, pendingApproval, ready, delivered }

enum OrderPriority { low, medium, high, urgent }
