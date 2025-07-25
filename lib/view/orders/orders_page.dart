import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/models/order_model.dart';
import 'package:tailorapp/core/models/garment_model.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/services/service_locator.dart';
import 'package:tailorapp/core/init/navigation/navigation_route.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];
  String _selectedFilter = 'all';
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        // Get orders from repository
        final orders = await ServiceLocator.orderRepository.getCustomerOrders(
          authState.user.uid,
        );

        setState(() {
          _orders = orders;
        });
      } else {
        // Use mock data for unauthenticated state
        _orders = _getMockOrders();
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      // Fallback to mock data on error
      _orders = _getMockOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: $e'),
            backgroundColor: Colors.orange[600],
          ),
        );
      }
    }

    _filterOrders();
    setState(() => _isLoading = false);
  }

  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        id: 'ORD001',
        customerId: 'CUST001',
        customerName: 'John Doe',
        customerEmail: 'john.doe@example.com',
        items: const [
          OrderItem(
            id: 'ITEM001',
            garmentId: 'GAR001',
            garmentName: 'Custom Business Shirt',
            garmentType: GarmentType.shirt,
            quantity: 2,
            unitPrice: 89.99,
            totalPrice: 179.98,
            measurements: <String, double>{
              'chest': 42.0,
              'waist': 36.0,
              'shoulders': 18.0,
              'sleeveLength': 24.0,
            },
            customizations: <String, dynamic>{
              'features': ['French cuffs', 'Monogram'],
              'fabric': 'Premium Cotton',
              'color': 'Navy Blue',
              'pattern': 'Solid',
            },
          ),
        ],
        totalAmount: 179.98,
        taxAmount: 18.00,
        shippingAmount: 10.00,
        discountAmount: 0.0,
        finalAmount: 207.98,
        status: OrderStatus.sewing,
        paymentStatus: PaymentStatus.paid,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        estimatedCompletionDate: DateTime.now().add(const Duration(days: 10)),
        shippingAddress: const ShippingAddress(
          fullName: 'John Doe',
          addressLine1: '123 Main St',
          city: 'New York',
          state: 'NY',
          postalCode: '10001',
          country: 'USA',
        ),
        progressImages: const [],
        statusHistory: [
          OrderStatusUpdate(
            id: 'STATUS001',
            status: OrderStatus.pending,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            message: 'Order placed successfully',
          ),
          OrderStatusUpdate(
            id: 'STATUS002',
            status: OrderStatus.confirmed,
            timestamp: DateTime.now().subtract(const Duration(days: 4)),
            message: 'Payment confirmed, starting production',
          ),
          OrderStatusUpdate(
            id: 'STATUS003',
            status: OrderStatus.sewing,
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            message: 'Garment cutting completed, starting stitching',
          ),
        ],
      ),
      OrderModel(
        id: 'ORD002',
        customerId: 'CUST001',
        customerName: 'Jane Smith',
        customerEmail: 'jane.smith@example.com',
        items: const [
          OrderItem(
            id: 'ITEM002',
            garmentId: 'GAR002',
            garmentName: 'Evening Dress',
            garmentType: GarmentType.dress,
            quantity: 1,
            unitPrice: 199.99,
            totalPrice: 199.99,
            measurements: <String, double>{
              'bust': 36.0,
              'waist': 28.0,
              'hips': 38.0,
              'length': 42.0,
            },
            customizations: <String, dynamic>{
              'features': ['Beaded details', 'Custom length'],
              'fabric': 'Silk',
              'color': 'Black',
              'pattern': 'Solid',
              'style': 'Elegant',
            },
          ),
        ],
        totalAmount: 199.99,
        taxAmount: 20.00,
        shippingAmount: 15.00,
        discountAmount: 5.00,
        finalAmount: 229.99,
        status: OrderStatus.shipped,
        paymentStatus: PaymentStatus.paid,
        orderDate: DateTime.now().subtract(const Duration(days: 15)),
        estimatedCompletionDate: DateTime.now().add(const Duration(days: 2)),
        shippingAddress: const ShippingAddress(
          fullName: 'Jane Smith',
          addressLine1: '123 Main St',
          city: 'New York',
          state: 'NY',
          postalCode: '10001',
          country: 'USA',
        ),
        progressImages: const ['progress1.jpg', 'progress2.jpg'],
        statusHistory: [
          OrderStatusUpdate(
            id: 'STATUS004',
            status: OrderStatus.pending,
            timestamp: DateTime.now().subtract(const Duration(days: 15)),
            message: 'Order placed successfully',
          ),
          OrderStatusUpdate(
            id: 'STATUS005',
            status: OrderStatus.confirmed,
            timestamp: DateTime.now().subtract(const Duration(days: 14)),
            message: 'Payment confirmed',
          ),
          OrderStatusUpdate(
            id: 'STATUS006',
            status: OrderStatus.cutting,
            timestamp: DateTime.now().subtract(const Duration(days: 12)),
            message: 'Production started',
          ),
          OrderStatusUpdate(
            id: 'STATUS007',
            status: OrderStatus.qualityCheck,
            timestamp: DateTime.now().subtract(const Duration(days: 5)),
            message: 'Garment completed and quality checked',
          ),
          OrderStatusUpdate(
            id: 'STATUS008',
            status: OrderStatus.shipped,
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
            message: 'Package shipped via express delivery',
          ),
        ],
        metadata: const {'trackingNumber': 'TRK123456789'},
      ),
    ];
  }

  void _filterOrders() {
    _filteredOrders = _orders.where((order) {
      // Apply status filter
      final bool statusMatch =
          _selectedFilter == 'all' || order.status.value == _selectedFilter;

      // Apply search filter
      final bool searchMatch = _searchQuery.isEmpty ||
          order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.items.any(
            (item) => item.garmentName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()),
          );

      return statusMatch && searchMatch;
    }).toList();

    // Sort by creation date (newest first)
    _filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
  }

  void _onTabChanged(int index) {
    final filters = ['all', 'pending', 'sewing', 'shipped'];
    if (index < filters.length) {
      setState(() {
        _selectedFilter = filters[index];
        _filterOrders();
      });
    }
  }

  void _createNewOrder() {
    NavigationRoute.goDesignCanvas(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
            tooltip: 'Search Orders',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: _onTabChanged,
          labelColor: Colors.blue[700],
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue[700],
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Shipped'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: _filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(_filteredOrders[index]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewOrder,
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        label: const Text('New Order'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first custom garment',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createNewOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Start Designing'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              // Show first item details
              if (order.items.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getGarmentIcon(order.items.first.garmentType),
                        color: Colors.grey[600],
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.items.first.garmentName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${order.items.first.garmentType.name.toUpperCase()} - ${order.items.first.customizations['fabric'] ?? 'Custom fabric'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: \$${order.finalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order: ${_formatDate(order.orderDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (order.metadata?['trackingNumber'] != null)
                        IconButton(
                          icon: const Icon(Icons.track_changes),
                          onPressed: () => _showTrackingInfo(order),
                          tooltip: 'Track Package',
                        ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showOrderActions(order),
                      ),
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

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case OrderStatus.sewing:
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.teal[100]!;
        textColor = Colors.teal[800]!;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getGarmentIcon(GarmentType type) {
    switch (type) {
      case GarmentType.shirt:
        return Icons.checkroom;
      case GarmentType.dress:
        return Icons.woman;
      case GarmentType.suit:
        return Icons.business_center;
      case GarmentType.jacket:
        return Icons.ac_unit;
      case GarmentType.trousers:
        return Icons.man;
      case GarmentType.skirt:
        return Icons.woman_2;
      case GarmentType.blouse:
        return Icons.checkroom;
      case GarmentType.other:
        return Icons.checkroom;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${order.customerName}'),
            Text('Status: ${order.status.displayName}'),
            Text('Items: ${order.items.length}'),
            Text('Total: \$${order.finalAmount.toStringAsFixed(2)}'),
            Text('Date: ${_formatDate(order.orderDate)}'),
            if (order.estimatedCompletionDate != null)
              Text(
                'Est. Completion: ${_formatDate(order.estimatedCompletionDate!)}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTrackingInfo(OrderModel order) {
    final trackingNumber = order.metadata?['trackingNumber'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Order #${order.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (trackingNumber != null) ...[
              Text('Tracking Number: $trackingNumber'),
              const SizedBox(height: 16),
            ],
            const Text('Status History:'),
            const SizedBox(height: 8),
            ...order.statusHistory.map(
              (history) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.status.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (history.message != null)
                      Text(
                        history.message!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    Text(
                      _formatDate(history.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showOrderActions(OrderModel order) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _viewOrderDetails(order);
              },
            ),
            if (order.status == OrderStatus.pending)
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text('Cancel Order'),
                onTap: () {
                  Navigator.pop(context);
                  _cancelOrder(order);
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Order ID'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Order ID ${order.id} copied')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performCancelOrder(order);
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCancelOrder(OrderModel order) async {
    try {
      // Update order status to cancelled
      await ServiceLocator.orderRepository.updateOrderStatus(
        order.id,
        OrderStatus.cancelled,
        'Order cancelled by customer',
      );

      // Refresh orders list
      await _loadOrders();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.id} has been cancelled'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel order: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return AlertDialog(
          title: const Text('Search Orders'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter order ID or garment name...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => searchQuery = value,
            onSubmitted: (value) {
              Navigator.pop(context);
              _performSearch(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performSearch(searchQuery);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _filterOrders();
      });
      return;
    }

    setState(() {
      _searchQuery = query.trim();
      _isLoading = true;
    });

    try {
      final searchResults =
          await ServiceLocator.orderRepository.searchOrders(query);
      setState(() {
        _orders = searchResults;
        _filterOrders();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }
}
