import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InventoryMaterialsScreen extends StatefulWidget {
  const InventoryMaterialsScreen({super.key});

  @override
  State<InventoryMaterialsScreen> createState() =>
      _InventoryMaterialsScreenState();
}

class _InventoryMaterialsScreenState extends State<InventoryMaterialsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _scanController;
  late AnimationController _restockController;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _inventoryScrollController = ScrollController();

  List<InventoryItem> _inventoryItems = [];
  List<InventoryItem> _filteredItems = [];
  List<MaterialSupplier> _suppliers = [];
  List<PurchaseOrder> _purchaseOrders = [];
  List<MaterialTransaction> _transactions = [];
  List<InventoryAlert> _alerts = [];

  String _selectedCategory = 'All';
  String _selectedLocation = 'All Locations';
  String _selectedStatus = 'All Status';
  String _sortBy = 'Stock Level';
  bool _showLowStock = false;
  bool _isScanning = false;

  final List<String> _categories = [
    'All',
    'Fabrics',
    'Threads',
    'Buttons',
    'Zippers',
    'Accessories',
    'Tools',
    'Equipment',
  ];

  final List<String> _locations = [
    'All Locations',
    'Main Workshop',
    'Storage Room',
    'Cutting Area',
    'Sewing Floor',
    'Finishing Section',
  ];

  final List<String> _statusOptions = [
    'All Status',
    'In Stock',
    'Low Stock',
    'Out of Stock',
    'On Order',
    'Reserved',
  ];

  final List<String> _sortOptions = [
    'Stock Level',
    'Last Updated',
    'Value',
    'Usage Frequency',
    'Alphabetical',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _restockController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadInventoryData();
    _loadSuppliers();
    _loadPurchaseOrders();
    _loadTransactions();
    _loadAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scanController.dispose();
    _restockController.dispose();
    _searchController.dispose();
    _inventoryScrollController.dispose();
    super.dispose();
  }

  void _loadInventoryData() {
    // Mock data - replace with actual API call
    _inventoryItems = List.generate(
      50,
      (index) => InventoryItem(
        id: 'INV${(index + 1).toString().padLeft(3, '0')}',
        name: _getItemName(index),
        description:
            'High-quality ${_getItemName(index).toLowerCase()} for professional tailoring',
        category: _categories[(index % (_categories.length - 1)) + 1],
        subcategory: _getSubcategory(index),
        sku: 'SKU${(index + 1).toString().padLeft(6, '0')}',
        barcode: '${1234567890 + index}',
        currentStock: (index % 10 == 0) ? 0 : 10 + (index * 3),
        minimumStock: 5 + (index % 10),
        maximumStock: 100 + (index * 5),
        reorderPoint: 15 + (index % 5),
        reorderQuantity: 50 + (index * 2),
        unit: _getUnit(index),
        unitCost: 5.0 + (index * 2.5),
        totalValue: (5.0 + (index * 2.5)) * (10 + (index * 3)),
        supplier: 'Supplier ${(index % 8) + 1}',
        location: _locations[(index % (_locations.length - 1)) + 1],
        lastUpdated: DateTime.now().subtract(Duration(hours: index % 48)),
        lastRestocked: DateTime.now().subtract(Duration(days: index % 30)),
        expirationDate: index % 4 == 0
            ? DateTime.now().add(Duration(days: 30 + (index * 10)))
            : null,
        batchNumber: index % 3 == 0 ? 'BATCH${index + 1}' : null,
        isTracked: index % 5 != 0,
        isReserved: index % 7 == 0,
        reservedQuantity: index % 7 == 0 ? 5 + (index % 10) : 0,
        usageFrequency:
            UsageFrequency.values[index % UsageFrequency.values.length],
        tags: _getTags(index),
        images: ['https://picsum.photos/400/300?random=$index'],
        notes: index % 5 == 0 ? 'Special handling required' : null,
        criticality:
            ItemCriticality.values[index % ItemCriticality.values.length],
        storageConditions: _getStorageConditions(index),
        qualityGrade: QualityGrade.values[index % QualityGrade.values.length],
        movementHistory: _generateMovementHistory(index),
      ),
    );

    _applyFilters();
    setState(() {});
  }

  String _getItemName(int index) {
    final names = [
      'Cotton Thread',
      'Silk Fabric',
      'Metal Zipper',
      'Pearl Button',
      'Sewing Needle',
      'Measuring Tape',
      'Fabric Scissors',
      'Iron',
      'Cutting Mat',
      'Seam Ripper',
      'Thimble',
      'Pin Cushion',
    ];
    return names[index % names.length];
  }

  String _getSubcategory(int index) {
    switch (index % 4) {
      case 0:
        return 'Basic';
      case 1:
        return 'Premium';
      case 2:
        return 'Professional';
      case 3:
        return 'Specialty';
      default:
        return 'Standard';
    }
  }

  String _getUnit(int index) {
    switch (index % 6) {
      case 0:
        return 'pieces';
      case 1:
        return 'meters';
      case 2:
        return 'yards';
      case 3:
        return 'sets';
      case 4:
        return 'boxes';
      case 5:
        return 'rolls';
      default:
        return 'units';
    }
  }

  List<String> _getTags(int index) {
    final allTags = [
      'Premium',
      'Imported',
      'Eco-Friendly',
      'Professional',
      'Limited',
      'Popular',
    ];
    return allTags.take((index % 3) + 1).toList();
  }

  String _getStorageConditions(int index) {
    final conditions = [
      'Room Temperature',
      'Cool & Dry',
      'Climate Controlled',
      'Moisture Protected',
    ];
    return conditions[index % conditions.length];
  }

  List<ItemMovement> _generateMovementHistory(int index) {
    return List.generate(
      3,
      (i) => ItemMovement(
        id: 'MOV${index}_$i',
        type: MovementType.values[i % MovementType.values.length],
        quantity: 5 + i,
        timestamp: DateTime.now().subtract(Duration(days: i + 1)),
        reference: 'REF${index}_$i',
        notes: 'Movement ${i + 1}',
      ),
    );
  }

  void _loadSuppliers() {
    _suppliers = List.generate(
      8,
      (index) => MaterialSupplier(
        id: 'SUP${index + 1}',
        name: 'Supplier ${index + 1}',
        contactPerson: 'Contact Person ${index + 1}',
        email: 'supplier${index + 1}@example.com',
        phone: '+1-555-${(2000 + index).toString()}',
        address: '${index + 1} Supplier Street, City, State',
        website: 'www.supplier${index + 1}.com',
        rating: 3.5 + ((index % 5) * 0.3),
        isActive: index % 6 != 0,
        paymentTerms: '${[15, 30, 45, 60][index % 4]} days',
        deliveryTime: Duration(days: 3 + (index % 7)),
        minimumOrderValue: 100.0 + (index * 50),
        categories: _categories.take((index % 3) + 2).toList(),
        certifications: _getCertifications(index),
        lastOrderDate: DateTime.now().subtract(Duration(days: index * 5)),
        totalOrderValue: (index + 1) * 5000.0,
        onTimeDeliveryRate: 0.85 + ((index % 3) * 0.05),
        qualityRating: 4.0 + ((index % 2) * 0.5),
        notes: index % 4 == 0 ? 'Preferred supplier' : null,
      ),
    );
  }

  List<String> _getCertifications(int index) {
    final certs = [
      'ISO 9001',
      'OEKO-TEX',
      'Fair Trade',
      'Organic',
      'Sustainable',
    ];
    return certs.take((index % 3) + 1).toList();
  }

  void _loadPurchaseOrders() {
    _purchaseOrders = List.generate(
      12,
      (index) => PurchaseOrder(
        id: 'PO${(index + 1).toString().padLeft(4, '0')}',
        supplierId: 'SUP${(index % 8) + 1}',
        supplierName: 'Supplier ${(index % 8) + 1}',
        orderDate: DateTime.now().subtract(Duration(days: index * 3)),
        expectedDelivery: DateTime.now().add(Duration(days: 7 + (index % 14))),
        status: OrderStatus.values[index % OrderStatus.values.length],
        totalAmount: 500.0 + (index * 150),
        currency: 'USD',
        items: List.generate(
          (index % 3) + 2,
          (i) => OrderItem(
            itemId: 'INV${(i + 1).toString().padLeft(3, '0')}',
            itemName: _getItemName(i),
            quantity: 10 + (i * 5),
            unitPrice: 5.0 + (i * 2),
            totalPrice: (5.0 + (i * 2)) * (10 + (i * 5)),
          ),
        ),
        paymentStatus:
            PaymentStatus.values[index % PaymentStatus.values.length],
        notes: index % 5 == 0 ? 'Rush order' : null,
        createdBy: 'Tailor 1',
        approvedBy: index % 3 == 0 ? 'Manager' : null,
      ),
    );
  }

  void _loadTransactions() {
    _transactions = List.generate(
      20,
      (index) => MaterialTransaction(
        id: 'TXN${(index + 1).toString().padLeft(4, '0')}',
        itemId: 'INV${((index % 50) + 1).toString().padLeft(3, '0')}',
        itemName: _getItemName(index % 12),
        type: TransactionType.values[index % TransactionType.values.length],
        quantity: (index % 2 == 0 ? 1 : -1) * (5 + (index % 15)),
        unitCost: 5.0 + (index * 1.5),
        totalCost: (5.0 + (index * 1.5)) * (5 + (index % 15)),
        timestamp: DateTime.now().subtract(Duration(hours: index * 6)),
        reference: 'REF${index + 1}',
        location: _locations[(index % (_locations.length - 1)) + 1],
        performedBy: 'User ${(index % 3) + 1}',
        notes: index % 4 == 0 ? 'Bulk transaction' : null,
        batchNumber: index % 3 == 0 ? 'BATCH${index + 1}' : null,
      ),
    );
  }

  void _loadAlerts() {
    _alerts = [
      InventoryAlert(
        id: 'ALERT1',
        type: AlertType.lowStock,
        itemId: 'INV001',
        itemName: 'Cotton Thread',
        message: 'Cotton Thread is running low (2 remaining)',
        severity: AlertSeverity.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      InventoryAlert(
        id: 'ALERT2',
        type: AlertType.outOfStock,
        itemId: 'INV010',
        itemName: 'Silk Fabric',
        message: 'Silk Fabric is out of stock',
        severity: AlertSeverity.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
      ),
      InventoryAlert(
        id: 'ALERT3',
        type: AlertType.expiring,
        itemId: 'INV025',
        itemName: 'Specialty Glue',
        message: 'Specialty Glue expires in 5 days',
        severity: AlertSeverity.low,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: true,
      ),
    ];
  }

  void _applyFilters() {
    _filteredItems = _inventoryItems.where((item) {
      final categoryMatch =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final locationMatch = _selectedLocation == 'All Locations' ||
          item.location == _selectedLocation;

      bool statusMatch = true;
      switch (_selectedStatus) {
        case 'In Stock':
          statusMatch = item.currentStock > item.minimumStock;
          break;
        case 'Low Stock':
          statusMatch =
              item.currentStock <= item.minimumStock && item.currentStock > 0;
          break;
        case 'Out of Stock':
          statusMatch = item.currentStock == 0;
          break;
        case 'On Order':
          statusMatch = _purchaseOrders.any(
            (po) =>
                po.items.any((poi) => poi.itemId == item.id) &&
                po.status == OrderStatus.pending,
          );
          break;
        case 'Reserved':
          statusMatch = item.isReserved;
          break;
      }

      final lowStockMatch =
          !_showLowStock || item.currentStock <= item.minimumStock;

      return categoryMatch && locationMatch && statusMatch && lowStockMatch;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'Last Updated':
        _filteredItems.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        break;
      case 'Value':
        _filteredItems.sort((a, b) => b.totalValue.compareTo(a.totalValue));
        break;
      case 'Usage Frequency':
        _filteredItems.sort(
          (a, b) => a.usageFrequency.index.compareTo(b.usageFrequency.index),
        );
        break;
      case 'Alphabetical':
        _filteredItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      default: // Stock Level
        _filteredItems.sort((a, b) => a.currentStock.compareTo(b.currentStock));
    }
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

          // Quick stats
          _buildQuickStats(),

          // Alerts banner
          if (_alerts.where((a) => !a.isRead).isNotEmpty) _buildAlertsBar(),

          // Tab bar
          _buildTabBar(),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryTab(),
                _buildSuppliersTab(),
                _buildOrdersTab(),
                _buildTransactionsTab(),
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
        'Inventory & Materials',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Barcode scanner
        IconButton(
          onPressed: _startBarcodeScanner,
          icon: AnimatedBuilder(
            animation: _scanController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isScanning ? 1.0 + (_scanController.value * 0.2) : 1.0,
                child: Icon(
                  Icons.qr_code_scanner,
                  color: _isScanning ? Colors.blue[600] : Colors.grey[600],
                ),
              );
            },
          ),
        ),

        // Auto-restock
        IconButton(
          onPressed: _triggerAutoRestock,
          icon: Icon(Icons.autorenew, color: Colors.grey[600]),
        ),

        // Export data
        IconButton(
          onPressed: _exportInventoryData,
          icon: Icon(Icons.download, color: Colors.grey[600]),
        ),

        // More options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'import', child: Text('Import Data')),
            const PopupMenuItem(
              value: 'backup',
              child: Text('Backup Inventory'),
            ),
            const PopupMenuItem(value: 'audit', child: Text('Audit Trail')),
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name, SKU, or barcode...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _searchItems,
            ),
          ),

          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Category', _selectedCategory, _categories),
                const SizedBox(width: 8),
                _buildFilterChip('Location', _selectedLocation, _locations),
                const SizedBox(width: 8),
                _buildFilterChip('Status', _selectedStatus, _statusOptions),
                const SizedBox(width: 8),
                _buildFilterChip('Sort', _sortBy, _sortOptions),
                const SizedBox(width: 8),
                FilterChip(
                  label:
                      const Text('Low Stock', style: TextStyle(fontSize: 12)),
                  selected: _showLowStock,
                  onSelected: (selected) {
                    setState(() {
                      _showLowStock = selected;
                      _applyFilters();
                    });
                  },
                  selectedColor: Colors.orange[100],
                  checkmarkColor: Colors.orange[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, List<String> options) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option, style: const TextStyle(fontSize: 12)),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        setState(() {
          switch (label) {
            case 'Category':
              _selectedCategory = newValue!;
              break;
            case 'Location':
              _selectedLocation = newValue!;
              break;
            case 'Status':
              _selectedStatus = newValue!;
              break;
            case 'Sort':
              _sortBy = newValue!;
              break;
          }
          _applyFilters();
        });
      },
    );
  }

  Widget _buildQuickStats() {
    final totalItems = _inventoryItems.length;
    final lowStockItems = _inventoryItems
        .where((item) => item.currentStock <= item.minimumStock)
        .length;
    final outOfStockItems =
        _inventoryItems.where((item) => item.currentStock == 0).length;
    final totalValue =
        _inventoryItems.fold(0.0, (sum, item) => sum + item.totalValue);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Items',
              '$totalItems',
              Icons.inventory,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Low Stock',
              '$lowStockItems',
              Icons.warning,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Out of Stock',
              '$outOfStockItems',
              Icons.error,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Value',
              '\$${totalValue.toStringAsFixed(0)}',
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsBar() {
    final unreadAlerts = _alerts.where((a) => !a.isRead).toList();

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
              '${unreadAlerts.length} alert${unreadAlerts.length != 1 ? 's' : ''} need attention',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: _showAlertsDialog,
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
        labelColor: Colors.green[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.green[600],
        isScrollable: true,
        tabs: const [
          Tab(text: 'Inventory'),
          Tab(text: 'Suppliers'),
          Tab(text: 'Orders'),
          Tab(text: 'Transactions'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadInventoryData();
      },
      child: _filteredItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _inventoryScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                return _buildInventoryCard(_filteredItems[index]);
              },
            ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final stockPercentage = item.maximumStock > 0
        ? (item.currentStock / item.maximumStock).clamp(0.0, 1.0)
        : 0.0;
    final isLowStock = item.currentStock <= item.minimumStock;
    final isOutOfStock = item.currentStock == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red[200]!
              : isLowStock
                  ? Colors.orange[200]!
                  : Colors.grey[200]!,
          width: isOutOfStock || isLowStock ? 2 : 1,
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
        onTap: () => _viewItemDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header row
              Row(
                children: [
                  // Item icon/image
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item.category)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(item.category),
                      color: _getCategoryColor(item.category),
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (item.isReserved)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'RESERVED',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'SKU: ${item.sku} • ${item.category}',
                          style: TextStyle(
                            fontSize: 12,
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
                                color: _getCriticalityColor(item.criticality)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.criticality.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: _getCriticalityColor(item.criticality),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.location,
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

                  // Stock status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.currentStock}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock
                              ? Colors.red[600]
                              : isLowStock
                                  ? Colors.orange[600]
                                  : Colors.green[600],
                        ),
                      ),
                      Text(
                        item.unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '\$${item.totalValue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stock level indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock Level',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(stockPercentage * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: stockPercentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutOfStock
                          ? Colors.red[600]!
                          : isLowStock
                              ? Colors.orange[600]!
                              : Colors.green[600]!,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Min: ${item.minimumStock}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Max: ${item.maximumStock}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _adjustStock(item),
                      icon: const Icon(Icons.edit, size: 16),
                      label:
                          const Text('Adjust', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _moveItem(item),
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Move', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isLowStock || isOutOfStock)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _reorderItem(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const Text(
                          'Reorder',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
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

  Widget _buildSuppliersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suppliers.length,
      itemBuilder: (context, index) {
        return _buildSupplierCard(_suppliers[index]);
      },
    );
  }

  Widget _buildSupplierCard(MaterialSupplier supplier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    supplier.isActive ? Colors.green[100] : Colors.grey[100],
                child: Text(
                  supplier.name.substring(0, 1),
                  style: TextStyle(
                    color: supplier.isActive
                        ? Colors.green[600]
                        : Colors.grey[600],
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
                      supplier.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      supplier.contactPerson,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          supplier.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: supplier.isActive
                                ? Colors.green[100]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            supplier.isActive ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: supplier.isActive
                                  ? Colors.green[600]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _contactSupplier(supplier),
                icon: Icon(Icons.message, color: Colors.blue[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSupplierStat(
                  'Delivery',
                  '${supplier.deliveryTime.inDays}d',
                ),
              ),
              Expanded(
                child: _buildSupplierStat(
                  'On-Time',
                  '${(supplier.onTimeDeliveryRate * 100).toInt()}%',
                ),
              ),
              Expanded(
                child: _buildSupplierStat(
                  'Quality',
                  supplier.qualityRating.toStringAsFixed(1),
                ),
              ),
              Expanded(
                child: _buildSupplierStat(
                  'Orders',
                  '\$${(supplier.totalOrderValue / 1000).toStringAsFixed(0)}k',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _purchaseOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_purchaseOrders[index]);
      },
    );
  }

  Widget _buildOrderCard(PurchaseOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PO ${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      order.supplierName,
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getOrderStatusColor(order.status)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getOrderStatusColor(order.status),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Expected: ${_formatDate(order.expectedDelivery)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '${order.items.length} item${order.items.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(_transactions[index]);
      },
    );
  }

  Widget _buildTransactionCard(MaterialTransaction transaction) {
    final isInbound = transaction.type == TransactionType.received ||
        transaction.type == TransactionType.purchased;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isInbound ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isInbound ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isInbound ? Icons.add : Icons.remove,
              color: isInbound ? Colors.green[600] : Colors.red[600],
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.itemName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${transaction.type.name.toUpperCase()} • ${transaction.performedBy}',
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
                '${isInbound ? '+' : ''}${transaction.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isInbound ? Colors.green[600] : Colors.red[600],
                ),
              ),
              Text(
                _formatTime(transaction.timestamp),
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

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Analytics',
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
                Icon(Icons.analytics, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Advanced Analytics Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Charts, trends, and insights coming soon',
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
          heroTag: 'quick_add',
          onPressed: _quickAddItem,
          backgroundColor: Colors.blue[600],
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: _createPurchaseOrder,
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.shopping_cart),
          label: const Text(
            'New Order',
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
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or add new items',
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
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fabrics':
        return Colors.blue[600]!;
      case 'Threads':
        return Colors.purple[600]!;
      case 'Buttons':
        return Colors.orange[600]!;
      case 'Zippers':
        return Colors.green[600]!;
      case 'Accessories':
        return Colors.pink[600]!;
      case 'Tools':
        return Colors.brown[600]!;
      case 'Equipment':
        return Colors.grey[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Fabrics':
        return Icons.texture;
      case 'Threads':
        return Icons.linear_scale;
      case 'Buttons':
        return Icons.circle;
      case 'Zippers':
        return Icons.vertical_align_center;
      case 'Accessories':
        return Icons.star;
      case 'Tools':
        return Icons.build;
      case 'Equipment':
        return Icons.precision_manufacturing;
      default:
        return Icons.inventory;
    }
  }

  Color _getCriticalityColor(ItemCriticality criticality) {
    switch (criticality) {
      case ItemCriticality.low:
        return Colors.green[600]!;
      case ItemCriticality.medium:
        return Colors.orange[600]!;
      case ItemCriticality.high:
        return Colors.red[600]!;
      case ItemCriticality.critical:
        return Colors.purple[600]!;
    }
  }

  Color _getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange[600]!;
      case OrderStatus.confirmed:
        return Colors.blue[600]!;
      case OrderStatus.shipped:
        return Colors.purple[600]!;
      case OrderStatus.delivered:
        return Colors.green[600]!;
      case OrderStatus.cancelled:
        return Colors.red[600]!;
    }
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

  void _searchItems(String query) {
    // Implement item search logic
  }

  void _startBarcodeScanner() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      _scanController.repeat();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcode scanner activated')),
      );
    } else {
      _scanController.stop();
    }
  }

  void _triggerAutoRestock() {
    _restockController.forward().then((_) {
      _restockController.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-restock triggered for low stock items'),
        ),
      );
    });
  }

  void _exportInventoryData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting inventory data...')),
    );
  }

  void _showAlertsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventory Alerts'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _alerts.length,
            itemBuilder: (context, index) {
              final alert = _alerts[index];
              return ListTile(
                leading: Icon(
                  _getAlertIcon(alert.type),
                  color: _getAlertSeverityColor(alert.severity),
                ),
                title: Text(alert.message),
                subtitle: Text(_formatTime(alert.timestamp)),
                trailing: alert.isRead
                    ? const Icon(Icons.check, color: Colors.green)
                    : const Icon(Icons.circle, color: Colors.red, size: 8),
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

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Icons.warning;
      case AlertType.outOfStock:
        return Icons.error;
      case AlertType.expiring:
        return Icons.schedule;
      case AlertType.overstock:
        return Icons.trending_up;
    }
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

  void _viewItemDetails(InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text('SKU: ${item.sku}'),
                Text('Category: ${item.category}'),
                Text('Location: ${item.location}'),
                Text('Current Stock: ${item.currentStock} ${item.unit}'),
                Text('Value: \$${item.totalValue.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _adjustStock(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Stock - ${item.name}'),
        content: const Text('Stock adjustment form will be implemented here.'),
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

  void _moveItem(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Move Item - ${item.name}'),
        content:
            const Text('Item location transfer form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: () => context.pop(), child: const Text('Move')),
        ],
      ),
    );
  }

  void _reorderItem(InventoryItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Creating reorder for ${item.name}...')),
    );
  }

  void _contactSupplier(MaterialSupplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${supplier.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(supplier.phone),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(supplier.email),
              onTap: () {},
            ),
          ],
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

  void _quickAddItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Add Item'),
        content:
            const Text('Quick item addition form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: () => context.pop(), child: const Text('Add')),
        ],
      ),
    );
  }

  void _createPurchaseOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Purchase Order'),
        content: const Text(
          'Purchase order creation form will be implemented here.',
        ),
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'import':
        _importData();
        break;
      case 'backup':
        _backupInventory();
        break;
      case 'audit':
        _showAuditTrail();
        break;
      case 'settings':
        _showSettings();
        break;
    }
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Importing inventory data...')),
    );
  }

  void _backupInventory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating inventory backup...')),
    );
  }

  void _showAuditTrail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audit Trail'),
        content: const Text('Inventory audit trail will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Inventory Settings'),
        content: const Text('Inventory management settings.'),
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
class InventoryItem {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final String sku;
  final String barcode;
  final int currentStock;
  final int minimumStock;
  final int maximumStock;
  final int reorderPoint;
  final int reorderQuantity;
  final String unit;
  final double unitCost;
  final double totalValue;
  final String supplier;
  final String location;
  final DateTime lastUpdated;
  final DateTime lastRestocked;
  final DateTime? expirationDate;
  final String? batchNumber;
  final bool isTracked;
  final bool isReserved;
  final int reservedQuantity;
  final UsageFrequency usageFrequency;
  final List<String> tags;
  final List<String> images;
  final String? notes;
  final ItemCriticality criticality;
  final String storageConditions;
  final QualityGrade qualityGrade;
  final List<ItemMovement> movementHistory;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.sku,
    required this.barcode,
    required this.currentStock,
    required this.minimumStock,
    required this.maximumStock,
    required this.reorderPoint,
    required this.reorderQuantity,
    required this.unit,
    required this.unitCost,
    required this.totalValue,
    required this.supplier,
    required this.location,
    required this.lastUpdated,
    required this.lastRestocked,
    this.expirationDate,
    this.batchNumber,
    required this.isTracked,
    required this.isReserved,
    required this.reservedQuantity,
    required this.usageFrequency,
    required this.tags,
    required this.images,
    this.notes,
    required this.criticality,
    required this.storageConditions,
    required this.qualityGrade,
    required this.movementHistory,
  });
}

class MaterialSupplier {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final String website;
  final double rating;
  final bool isActive;
  final String paymentTerms;
  final Duration deliveryTime;
  final double minimumOrderValue;
  final List<String> categories;
  final List<String> certifications;
  final DateTime lastOrderDate;
  final double totalOrderValue;
  final double onTimeDeliveryRate;
  final double qualityRating;
  final String? notes;

  MaterialSupplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    required this.website,
    required this.rating,
    required this.isActive,
    required this.paymentTerms,
    required this.deliveryTime,
    required this.minimumOrderValue,
    required this.categories,
    required this.certifications,
    required this.lastOrderDate,
    required this.totalOrderValue,
    required this.onTimeDeliveryRate,
    required this.qualityRating,
    this.notes,
  });
}

class PurchaseOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  final DateTime expectedDelivery;
  final OrderStatus status;
  final double totalAmount;
  final String currency;
  final List<OrderItem> items;
  final PaymentStatus paymentStatus;
  final String? notes;
  final String createdBy;
  final String? approvedBy;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    required this.expectedDelivery,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.items,
    required this.paymentStatus,
    this.notes,
    required this.createdBy,
    this.approvedBy,
  });
}

class OrderItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class MaterialTransaction {
  final String id;
  final String itemId;
  final String itemName;
  final TransactionType type;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final DateTime timestamp;
  final String reference;
  final String location;
  final String performedBy;
  final String? notes;
  final String? batchNumber;

  MaterialTransaction({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.timestamp,
    required this.reference,
    required this.location,
    required this.performedBy,
    this.notes,
    this.batchNumber,
  });
}

class InventoryAlert {
  final String id;
  final AlertType type;
  final String itemId;
  final String itemName;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  InventoryAlert({
    required this.id,
    required this.type,
    required this.itemId,
    required this.itemName,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.isRead,
  });
}

class ItemMovement {
  final String id;
  final MovementType type;
  final int quantity;
  final DateTime timestamp;
  final String reference;
  final String notes;

  ItemMovement({
    required this.id,
    required this.type,
    required this.quantity,
    required this.timestamp,
    required this.reference,
    required this.notes,
  });
}

enum UsageFrequency { low, medium, high, critical }

enum ItemCriticality { low, medium, high, critical }

enum QualityGrade { standard, premium, luxury }

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

enum PaymentStatus { pending, paid, overdue }

enum TransactionType {
  received,
  used,
  purchased,
  returned,
  adjusted,
  transferred
}

enum AlertType { lowStock, outOfStock, expiring, overstock }

enum AlertSeverity { low, medium, high }

enum MovementType { inbound, outbound, transfer, adjustment }
