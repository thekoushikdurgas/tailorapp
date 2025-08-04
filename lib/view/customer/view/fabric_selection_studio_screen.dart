import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tailorapp/core/cubit/auth_cubit.dart';
// import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class FabricSelectionStudioScreen extends StatefulWidget {
  const FabricSelectionStudioScreen({super.key});

  @override
  State<FabricSelectionStudioScreen> createState() => _FabricSelectionStudioScreenState();
}

class _FabricSelectionStudioScreenState extends State<FabricSelectionStudioScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _arController;
  late AnimationController _shimmerController;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _fabricScrollController = ScrollController();
  final PageController _arPreviewController = PageController();

  List<FabricMaterial> _fabrics = [];
  List<FabricMaterial> _filteredFabrics = [];
  List<FabricCollection> _collections = [];
  List<FabricSample> _samples = [];
  FabricMaterial? _selectedFabric;
  String _selectedCategory = 'All';
  final String _selectedPriceRange = 'All Prices';
  String _selectedSustainability = 'All';
  String _sortBy = 'Popularity';
  bool _isGridView = true;
  bool _isArMode = false;
  bool _showFilters = false;
  final double _minPrice = 0;
  final double _maxPrice = 500;
  RangeValues _priceRange = const RangeValues(0, 500);

  final List<String> _categories = [
    'All',
    'Cotton',
    'Silk',
    'Wool',
    'Linen',
    'Denim',
    'Synthetic',
    'Blends',
  ];

  final List<String> _sustainabilityOptions = [
    'All',
    'Organic',
    'Recycled',
    'Eco-Friendly',
    'Sustainable',
  ];

  final List<String> _sortOptions = [
    'Popularity',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
    'Best Rating',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _arController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _loadFabrics();
    _loadCollections();
    _loadSamples();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _arController.dispose();
    _shimmerController.dispose();
    _searchController.dispose();
    _fabricScrollController.dispose();
    _arPreviewController.dispose();
    super.dispose();
  }

  void _loadFabrics() {
    // Mock data - replace with actual API call
    _fabrics = List.generate(
      40,
      (index) => FabricMaterial(
        id: 'FAB${(index + 1).toString().padLeft(3, '0')}',
        name: '${_getFabricName(index)} Premium',
        description: 'High-quality ${_getFabricName(index).toLowerCase()} fabric with excellent drape and comfort',
        category: _categories[(index % (_categories.length - 1)) + 1],
        subcategory: _getSubcategory(index),
        price: 25.0 + (index * 8.5),
        pricePerMeter: 15.0 + (index * 5.2),
        currency: 'USD',
        imageUrl: 'https://picsum.photos/400/300?random=$index',
        textureImageUrl: 'https://picsum.photos/200/200?random=${index + 100}',
        supplier: 'Supplier ${(index % 5) + 1}',
        origin: ['Italy', 'India', 'Japan', 'Turkey', 'China'][index % 5],
        weight: 150 + (index * 10),
        width: 140 + (index % 20),
        composition: _getComposition(index),
        careInstructions: [
          'Machine wash cold',
          'Tumble dry low',
          'Iron medium heat',
        ],
        sustainability: _getSustainability(index),
        inStock: index % 7 != 0,
        stockQuantity: index % 7 != 0 ? 50 + (index * 3) : 0,
        minimumOrder: 1.0 + (index % 3),
        leadTime: Duration(days: 3 + (index % 10)),
        rating: 3.5 + ((index % 5) * 0.3),
        reviewCount: (index + 1) * 12,
        tags: _getTags(index),
        seasonality: _getSeasonality(index),
        occasion: _getOccasion(index),
        drape: FabricDrape.values[index % FabricDrape.values.length],
        stretch: index % 4 == 0,
        transparency: FabricTransparency.values[index % FabricTransparency.values.length],
        shrinkage: (index % 5) * 0.5,
        colorOptions: List.generate(
          (index % 8) + 3,
          (i) => Color.fromARGB(
            255,
            50 + (i * 25),
            100 + (i * 20),
            150 + (i * 15),
          ),
        ),
        patternOptions: _getPatternOptions(index),
        technicalSpecs: FabricTechnicalSpecs(
          threadCount: 120 + (index * 5),
          gsm: 180 + (index * 8),
          breathability: (index % 10) / 10,
          durability: 0.7 + ((index % 4) * 0.1),
          wrinkleResistance: (index % 8) / 10,
          uvProtection: index % 3 == 0,
          antibacterial: index % 5 == 0,
          moistureWicking: index % 4 == 0,
        ),
        sustainabilityDetails: _getSustainabilityDetails(index),
        certifications: _getCertifications(index),
        isFavorite: index % 7 == 0,
        isNewArrival: index < 8,
        isOnSale: index % 6 == 0,
        salePrice: index % 6 == 0 ? (25.0 + (index * 8.5)) * 0.8 : null,
      ),
    );

    _applyFilters();
    setState(() {});
  }

  String _getFabricName(int index) {
    final names = [
      'Venetian Cotton',
      'Mulberry Silk',
      'Merino Wool',
      'Belgian Linen',
      'Premium Denim',
      'Bamboo Blend',
      'Cashmere Touch',
      'Organic Hemp',
    ];
    return names[index % names.length];
  }

  String _getSubcategory(int index) {
    final subcategories = [
      'Formal',
      'Casual',
      'Evening',
      'Sport',
      'Luxury',
      'Basic',
      'Designer',
      'Vintage',
    ];
    return subcategories[index % subcategories.length];
  }

  Map<String, double> _getComposition(int index) {
    switch (index % 4) {
      case 0:
        return {'Cotton': 100.0};
      case 1:
        return {'Cotton': 70.0, 'Polyester': 30.0};
      case 2:
        return {'Silk': 60.0, 'Cotton': 40.0};
      case 3:
        return {'Wool': 80.0, 'Nylon': 20.0};
      default:
        return {'Cotton': 100.0};
    }
  }

  List<String> _getSustainability(int index) {
    if (index % 3 == 0) return ['Organic', 'GOTS Certified'];
    if (index % 4 == 0) return ['Recycled', 'Eco-Friendly'];
    if (index % 5 == 0) return ['Sustainable', 'Fair Trade'];
    return [];
  }

  List<String> _getTags(int index) {
    final allTags = [
      'Breathable',
      'Durable',
      'Luxury',
      'Comfortable',
      'Wrinkle-Free',
      'Easy Care',
      'Premium',
      'Designer',
      'Seasonal',
      'Trending',
    ];
    return allTags.take((index % 4) + 2).toList();
  }

  String _getSeasonality(int index) {
    return ['Spring/Summer', 'Fall/Winter', 'All Season'][index % 3];
  }

  String _getOccasion(int index) {
    return ['Formal', 'Casual', 'Business', 'Evening', 'Sport'][index % 5];
  }

  List<String> _getPatternOptions(int index) {
    final patterns = [
      'Solid',
      'Striped',
      'Checkered',
      'Floral',
      'Geometric',
      'Abstract',
    ];
    return patterns.take((index % 3) + 1).toList();
  }

  FabricSustainabilityDetails _getSustainabilityDetails(int index) {
    return FabricSustainabilityDetails(
      organicPercentage: index % 3 == 0 ? 100.0 : (index % 5) * 20.0,
      recycledContent: index % 4 == 0 ? (index % 6) * 15.0 : 0.0,
      carbonFootprint: 'Low',
      waterUsage: 'Reduced by ${20 + (index % 5) * 10}%',
      biodegradable: index % 5 == 0,
      ethicalSourcing: index % 3 != 0,
    );
  }

  List<String> _getCertifications(int index) {
    final certs = ['GOTS', 'OEKO-TEX', 'Cradle to Cradle', 'Fair Trade', 'BCI'];
    return certs.take((index % 3) + 1).toList();
  }

  void _loadCollections() {
    _collections = List.generate(
      6,
      (index) => FabricCollection(
        id: 'COL${index + 1}',
        name: '${[
          'Spring',
          'Summer',
          'Fall',
          'Winter',
          'Designer',
          'Eco',
        ][index]} Collection',
        description: 'Curated selection of premium fabrics for the season',
        imageUrl: 'https://picsum.photos/600/400?random=${index + 200}',
        fabricCount: 8 + (index * 3),
        theme: [
          'Floral',
          'Minimalist',
          'Bold',
          'Classic',
          'Modern',
          'Natural',
        ][index],
        isNew: index < 2,
        isFeatured: index % 2 == 0,
      ),
    );
  }

  void _loadSamples() {
    _samples = List.generate(
      5,
      (index) => FabricSample(
        id: 'SAMPLE${index + 1}',
        fabricId: 'FAB${(index + 1).toString().padLeft(3, '0')}',
        sampleType: SampleType.values[index % SampleType.values.length],
        price: 5.0 + (index * 2),
        processingTime: Duration(days: 2 + index),
        includesSwatches: true,
        swatchCount: 3 + index,
        description: 'Physical sample with detailed specifications',
      ),
    );
  }

  void _applyFilters() {
    _filteredFabrics = _fabrics.where((fabric) {
      // Category filter
      final categoryMatch = _selectedCategory == 'All' || fabric.category == _selectedCategory;

      // Price filter
      bool priceMatch = true;
      switch (_selectedPriceRange) {
        case '\$0-\$50':
          priceMatch = fabric.price <= 50;
          break;
        case '\$50-\$100':
          priceMatch = fabric.price > 50 && fabric.price <= 100;
          break;
        case '\$100-\$200':
          priceMatch = fabric.price > 100 && fabric.price <= 200;
          break;
        case '\$200+':
          priceMatch = fabric.price > 200;
          break;
      }

      // Sustainability filter
      final sustainabilityMatch =
          _selectedSustainability == 'All' || fabric.sustainability.contains(_selectedSustainability);

      // Custom price range
      final customPriceMatch = fabric.price >= _priceRange.start && fabric.price <= _priceRange.end;

      return categoryMatch && priceMatch && sustainabilityMatch && customPriceMatch;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'Price: Low to High':
        _filteredFabrics.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Price: High to Low':
        _filteredFabrics.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Best Rating':
        _filteredFabrics.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Newest':
        _filteredFabrics.sort(
          (a, b) => (b.isNewArrival ? 1 : 0).compareTo(a.isNewArrival ? 1 : 0),
        );
        break;
      default: // Popularity
        _filteredFabrics.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
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

          // Quick access collections
          if (!_showFilters && !_isArMode) _buildCollectionsRow(),

          // AR Mode overlay or main content
          Expanded(
            child: _isArMode ? _buildArModeView() : _buildMainContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
      bottomNavigationBar: _selectedFabric != null ? _buildFabricDetailsBottomSheet() : null,
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
        _isArMode ? 'AR Preview' : 'Fabric Studio',
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
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

        // AR mode toggle
        IconButton(
          onPressed: _toggleArMode,
          icon: Icon(
            _isArMode ? Icons.visibility_off : Icons.view_in_ar,
            color: _isArMode ? Colors.purple[600] : Colors.grey[600],
          ),
        ),

        // Shopping cart
        Stack(
          children: [
            IconButton(
              onPressed: _openCart,
              icon: Icon(Icons.shopping_bag_outlined, color: Colors.grey[600]),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // More options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'samples', child: Text('Order Samples')),
            const PopupMenuItem(
              value: 'favorites',
              child: Text('My Favorites'),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Text('Purchase History'),
            ),
            const PopupMenuItem(
              value: 'compare',
              child: Text('Compare Fabrics'),
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
                      hintText: 'Search fabrics by name, material, or style...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _searchFabrics,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: _showFilters ? Colors.blue[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _showFilters ? Colors.blue[200]! : Colors.grey[300]!,
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon: Icon(
                    Icons.tune,
                    color: _showFilters ? Colors.blue[600] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),

          // Advanced filters
          if (_showFilters) ...[
            const SizedBox(height: 16),
            _buildAdvancedFilters(),
          ],
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Column(
      children: [
        // Category and sort filters
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _applyFilters();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: InputDecoration(
                  labelText: 'Sort By',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _sortOptions
                    .map(
                      (sort) => DropdownMenuItem(
                        value: sort,
                        child: Text(sort, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _applyFilters();
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Price range and sustainability
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSustainability,
                decoration: InputDecoration(
                  labelText: 'Sustainability',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _sustainabilityOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(option, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSustainability = value!;
                    _applyFilters();
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Price range slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Range: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            RangeSlider(
              values: _priceRange,
              min: _minPrice,
              max: _maxPrice,
              divisions: 20,
              activeColor: Colors.blue[600],
              onChanged: (values) {
                setState(() {
                  _priceRange = values;
                });
              },
              onChangeEnd: (values) {
                _applyFilters();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectionsRow() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Featured Collections',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                return _buildCollectionCard(_collections[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(FabricCollection collection) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.primaries[collection.hashCode % Colors.primaries.length],
                    Colors.primaries[collection.hashCode % Colors.primaries.length].withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${collection.fabricCount} fabrics',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (collection.isNew)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFabricsTab(),
        _buildSamplesTab(),
        _buildFavoritesTab(),
        _buildTrendsTab(),
        _buildSustainabilityTab(),
      ],
    );
  }

  Widget _buildFabricsTab() {
    if (_filteredFabrics.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[600],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[600],
              isScrollable: true,
              tabs: const [
                Tab(text: 'All Fabrics'),
                Tab(text: 'Samples'),
                Tab(text: 'Favorites'),
                Tab(text: 'Trends'),
                Tab(text: 'Sustainability'),
              ],
            ),
          ),

          // Results count
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  '${_filteredFabrics.length} fabrics found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  'Showing ${_isGridView ? 'grid' : 'list'} view',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Fabric grid/list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadFabrics();
              },
              child: _isGridView ? _buildFabricsGrid() : _buildFabricsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabricsGrid() {
    return GridView.builder(
      controller: _fabricScrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredFabrics.length,
      itemBuilder: (context, index) {
        return _buildFabricCard(_filteredFabrics[index]);
      },
    );
  }

  Widget _buildFabricsList() {
    return ListView.builder(
      controller: _fabricScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFabrics.length,
      itemBuilder: (context, index) {
        return _buildFabricListItem(_filteredFabrics[index]);
      },
    );
  }

  Widget _buildFabricCard(FabricMaterial fabric) {
    return Container(
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
      child: InkWell(
        onTap: () => _selectFabric(fabric),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fabric image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [
                      fabric.colorOptions.first,
                      fabric.colorOptions.first.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Shimmer effect for texture
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [
                                0.0,
                                _shimmerController.value - 0.3,
                                _shimmerController.value,
                                _shimmerController.value + 0.3,
                                1.0,
                              ],
                              colors: [
                                fabric.colorOptions.first,
                                fabric.colorOptions.first,
                                fabric.colorOptions.first.withValues(alpha: 0.5),
                                fabric.colorOptions.first,
                                fabric.colorOptions.first,
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const Center(
                      child: Icon(Icons.texture, color: Colors.white, size: 32),
                    ),

                    // Badges
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Column(
                        children: [
                          if (fabric.isNewArrival)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[600],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (fabric.isOnSale)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(fabric),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            fabric.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: fabric.isFavorite ? Colors.red[600] : Colors.grey[600],
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    // Stock indicator
                    if (!fabric.inStock)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        child: const Center(
                          child: Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Fabric details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fabric.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fabric.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (fabric.isOnSale && fabric.salePrice != null) ...[
                                Text(
                                  '\$${fabric.salePrice!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[600],
                                  ),
                                ),
                                Text(
                                  '\$${fabric.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  '\$${fabric.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'per yard',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  fabric.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '(${fabric.reviewCount})',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (fabric.sustainability.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: fabric.sustainability
                            .take(2)
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFabricListItem(FabricMaterial fabric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        onTap: () => _selectFabric(fabric),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Fabric thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      fabric.colorOptions.first,
                      fabric.colorOptions.first.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.texture, color: Colors.white, size: 24),
                ),
              ),

              const SizedBox(width: 16),

              // Fabric details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fabric.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (fabric.isOnSale && fabric.salePrice != null) ...[
                          Text(
                            '\$${fabric.salePrice!.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[600],
                            ),
                          ),
                        ] else ...[
                          Text(
                            '\$${fabric.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fabric.category} • ${fabric.subcategory}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fabric.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${fabric.rating.toStringAsFixed(1)} (${fabric.reviewCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${fabric.width}cm wide',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (fabric.inStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'In Stock',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red[600],
                                fontWeight: FontWeight.w500,
                              ),
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
                  IconButton(
                    onPressed: () => _toggleFavorite(fabric),
                    icon: Icon(
                      fabric.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: fabric.isFavorite ? Colors.red[600] : Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _addToCart(fabric),
                    icon: Icon(Icons.add_shopping_cart, color: Colors.blue[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSamplesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fabric Samples',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Order physical samples to feel the quality and texture',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ..._samples.map((sample) => _buildSampleCard(sample)),
        ],
      ),
    );
  }

  Widget _buildSampleCard(FabricSample sample) {
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.brown[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt, color: Colors.brown[600], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sample.sampleType.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  sample.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Processing: ${sample.processingTime.inDays} days',
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
              Text(
                '\$${sample.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _orderSample(sample),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Order',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final favoriteFabrics = _fabrics.where((fabric) => fabric.isFavorite).toList();

    if (favoriteFabrics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on fabrics to save them here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: favoriteFabrics.length,
      itemBuilder: (context, index) {
        return _buildFabricCard(favoriteFabrics[index]);
      },
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending Now',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Fashion trends and popular fabrics this season',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
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
                Icon(Icons.trending_up, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Fashion Trends Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'AI-powered trend analysis coming soon',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilityTab() {
    final sustainableFabrics = _fabrics.where((fabric) => fabric.sustainability.isNotEmpty).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sustainable & Eco-Friendly',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Responsibly sourced and environmentally conscious fabrics',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
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
              childAspectRatio: 0.75,
            ),
            itemCount: sustainableFabrics.length,
            itemBuilder: (context, index) {
              return _buildFabricCard(sustainableFabrics[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArModeView() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // AR camera view placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.view_in_ar, size: 80, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'AR Fabric Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Camera integration coming soon',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // AR controls
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildArControl(Icons.camera_alt, 'Capture'),
                  _buildArControl(Icons.palette, 'Colors'),
                  _buildArControl(Icons.compare, 'Compare'),
                  _buildArControl(Icons.share, 'Share'),
                ],
              ),
            ),
          ),

          // Close AR mode
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isArMode = false;
                });
                _arController.reverse();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArControl(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFabricDetailsBottomSheet() {
    if (_selectedFabric == null) return const SizedBox.shrink();

    return Container(
      height: 80,
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
            // Fabric thumbnail
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    _selectedFabric!.colorOptions.first,
                    _selectedFabric!.colorOptions.first.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(Icons.texture, color: Colors.white, size: 20),
              ),
            ),

            const SizedBox(width: 12),

            // Fabric info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedFabric!.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${_selectedFabric!.price.toStringAsFixed(2)} per yard',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            ElevatedButton.icon(
              onPressed: () => _addToCart(_selectedFabric!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(
                Icons.add_shopping_cart,
                color: Colors.white,
                size: 16,
              ),
              label: const Text(
                'Add to Cart',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: () => _viewFabricDetails(_selectedFabric!),
              icon: Icon(Icons.info_outline, color: Colors.grey[600]),
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
        if (_selectedFabric != null)
          FloatingActionButton(
            heroTag: 'ar_preview',
            onPressed: _startArPreview,
            backgroundColor: Colors.purple[600],
            child: const Icon(Icons.view_in_ar, color: Colors.white),
          ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: _openSampleOrderDialog,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.local_shipping),
          label: const Text(
            'Order Samples',
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
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No fabrics found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
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
  void _searchFabrics(String query) {
    // Implement fabric search logic
    setState(() {
      if (query.isEmpty) {
        _applyFilters();
      } else {
        _filteredFabrics = _fabrics
            .where(
              (fabric) =>
                  fabric.name.toLowerCase().contains(query.toLowerCase()) ||
                  fabric.category.toLowerCase().contains(query.toLowerCase()) ||
                  fabric.description.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _toggleArMode() {
    setState(() {
      _isArMode = !_isArMode;
    });

    if (_isArMode) {
      _arController.forward();
    } else {
      _arController.reverse();
    }
  }

  void _selectFabric(FabricMaterial fabric) {
    setState(() {
      _selectedFabric = fabric;
    });
  }

  void _toggleFavorite(FabricMaterial fabric) {
    setState(() {
      fabric.isFavorite = !fabric.isFavorite;
    });
  }

  void _addToCart(FabricMaterial fabric) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${fabric.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: _openCart,
        ),
      ),
    );
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Shopping Cart',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Cart functionality will be implemented here'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _orderSample(FabricSample sample) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ordering ${sample.sampleType.name} sample...')),
    );
  }

  void _viewFabricDetails(FabricMaterial fabric) {
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
                  fabric.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(fabric.description),
                const SizedBox(height: 16),
                Text('Price: \$${fabric.price.toStringAsFixed(2)} per yard'),
                Text('Width: ${fabric.width}cm'),
                Text('Weight: ${fabric.weight}gsm'),
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

  void _startArPreview() {
    if (_selectedFabric != null) {
      _toggleArMode();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a fabric first')),
      );
    }
  }

  void _openSampleOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Fabric Samples'),
        content: const Text(
          'Select fabrics and order physical samples to feel the quality.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Order'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'samples':
        _openSampleOrderDialog();
        break;
      case 'favorites':
        _tabController.animateTo(2);
        break;
      case 'history':
        _showPurchaseHistory();
        break;
      case 'compare':
        _showFabricComparison();
        break;
    }
  }

  void _showPurchaseHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase History'),
        content: const Text('Your fabric purchase history will be displayed here.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFabricComparison() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compare Fabrics'),
        content: const Text('Select fabrics to compare side by side.'),
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
class FabricMaterial {
  final String id;
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final double price;
  final double pricePerMeter;
  final String currency;
  final String imageUrl;
  final String textureImageUrl;
  final String supplier;
  final String origin;
  final int weight;
  final int width;
  final Map<String, double> composition;
  final List<String> careInstructions;
  final List<String> sustainability;
  final bool inStock;
  final int stockQuantity;
  final double minimumOrder;
  final Duration leadTime;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final String seasonality;
  final String occasion;
  final FabricDrape drape;
  final bool stretch;
  final FabricTransparency transparency;
  final double shrinkage;
  final List<Color> colorOptions;
  final List<String> patternOptions;
  final FabricTechnicalSpecs technicalSpecs;
  final FabricSustainabilityDetails sustainabilityDetails;
  final List<String> certifications;
  bool isFavorite;
  final bool isNewArrival;
  final bool isOnSale;
  final double? salePrice;

  FabricMaterial({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.price,
    required this.pricePerMeter,
    required this.currency,
    required this.imageUrl,
    required this.textureImageUrl,
    required this.supplier,
    required this.origin,
    required this.weight,
    required this.width,
    required this.composition,
    required this.careInstructions,
    required this.sustainability,
    required this.inStock,
    required this.stockQuantity,
    required this.minimumOrder,
    required this.leadTime,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.seasonality,
    required this.occasion,
    required this.drape,
    required this.stretch,
    required this.transparency,
    required this.shrinkage,
    required this.colorOptions,
    required this.patternOptions,
    required this.technicalSpecs,
    required this.sustainabilityDetails,
    required this.certifications,
    required this.isFavorite,
    required this.isNewArrival,
    required this.isOnSale,
    this.salePrice,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FabricMaterial && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class FabricCollection {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int fabricCount;
  final String theme;
  final bool isNew;
  final bool isFeatured;

  FabricCollection({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.fabricCount,
    required this.theme,
    required this.isNew,
    required this.isFeatured,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FabricCollection && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class FabricSample {
  final String id;
  final String fabricId;
  final SampleType sampleType;
  final double price;
  final Duration processingTime;
  final bool includesSwatches;
  final int swatchCount;
  final String description;

  FabricSample({
    required this.id,
    required this.fabricId,
    required this.sampleType,
    required this.price,
    required this.processingTime,
    required this.includesSwatches,
    required this.swatchCount,
    required this.description,
  });
}

class FabricTechnicalSpecs {
  final int threadCount;
  final int gsm;
  final double breathability;
  final double durability;
  final double wrinkleResistance;
  final bool uvProtection;
  final bool antibacterial;
  final bool moistureWicking;

  FabricTechnicalSpecs({
    required this.threadCount,
    required this.gsm,
    required this.breathability,
    required this.durability,
    required this.wrinkleResistance,
    required this.uvProtection,
    required this.antibacterial,
    required this.moistureWicking,
  });
}

class FabricSustainabilityDetails {
  final double organicPercentage;
  final double recycledContent;
  final String carbonFootprint;
  final String waterUsage;
  final bool biodegradable;
  final bool ethicalSourcing;

  FabricSustainabilityDetails({
    required this.organicPercentage,
    required this.recycledContent,
    required this.carbonFootprint,
    required this.waterUsage,
    required this.biodegradable,
    required this.ethicalSourcing,
  });
}

enum FabricDrape { fluid, structured, crisp, soft }

enum FabricTransparency { opaque, semiTransparent, transparent }

enum SampleType { swatch, yardSample, fullSample }
