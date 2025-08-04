import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class DesignWishlistScreen extends StatefulWidget {
  const DesignWishlistScreen({super.key});

  @override
  State<DesignWishlistScreen> createState() => _DesignWishlistScreenState();
}

class _DesignWishlistScreenState extends State<DesignWishlistScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _selectedCategories = [];
  String _selectedPriceRange = 'All';
  String _selectedSortBy = 'Recent';
  bool _isGridView = true;
  bool _isFilterExpanded = false;
  List<WishlistItem> _wishlistItems = [];
  List<WishlistItem> _selectedItems = [];
  bool _isSelectionMode = false;

  final List<String> _categories = [
    'Shirts',
    'Dresses',
    'Suits',
    'Casual',
    'Formal',
    'Vintage',
    'Modern',
  ];

  final List<String> _priceRanges = [
    'All',
    'Under \$100',
    '\$100-\$300',
    '\$300-\$500',
    '\$500+',
  ];

  final List<String> _sortOptions = [
    'Recent',
    'Price: Low to High',
    'Price: High to Low',
    'Popularity',
    'AI Recommended',
  ];

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadWishlistItems() {
    // Mock data - replace with actual API call
    _wishlistItems = List.generate(
      20,
      (index) => WishlistItem(
        id: 'item_$index',
        title: 'Design ${index + 1}',
        designer: 'Designer ${(index % 5) + 1}',
        price: 100 + (index * 25),
        originalPrice: index % 3 == 0 ? 150 + (index * 25) : null,
        imageUrl: 'https://picsum.photos/300/400?random=$index',
        category: _categories[index % _categories.length],
        isOnSale: index % 3 == 0,
        rating: 4.0 + (index % 2),
        isFavorite: true,
        addedDate: DateTime.now().subtract(Duration(days: index)),
        tags: ['Elegant', 'Professional', 'Modern'],
      ),
    );
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    // Simulate loading more items
    final startIndex = _wishlistItems.length;
    final newItems = List.generate(
      10,
      (index) => WishlistItem(
        id: 'item_${startIndex + index}',
        title: 'Design ${startIndex + index + 1}',
        designer: 'Designer ${((startIndex + index) % 5) + 1}',
        price: 100 + ((startIndex + index) * 25),
        originalPrice: (startIndex + index) % 3 == 0
            ? 150 + ((startIndex + index) * 25)
            : null,
        imageUrl: 'https://picsum.photos/300/400?random=${startIndex + index}',
        category: _categories[(startIndex + index) % _categories.length],
        isOnSale: (startIndex + index) % 3 == 0,
        rating: 4.0 + ((startIndex + index) % 2),
        isFavorite: true,
        addedDate: DateTime.now().subtract(Duration(days: startIndex + index)),
        tags: ['Elegant', 'Professional', 'Modern'],
      ),
    );

    setState(() {
      _wishlistItems.addAll(newItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search and filter section
          _buildSearchAndFilterSection(),

          // Filter chips (when expanded)
          if (_isFilterExpanded) _buildFilterChips(),

          // View toggle and sort
          _buildViewControls(),

          // Wishlist content
          Expanded(
            child: _buildWishlistContent(),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? null : _buildAddToWishlistFAB(),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
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
      title: _isSelectionMode
          ? Text(
              '${_selectedItems.length} selected',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            )
          : const Text(
              'My Wishlist',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
      actions: [
        if (_isSelectionMode)
          TextButton(
            onPressed: _exitSelectionMode,
            child: const Text('Cancel'),
          )
        else ...[
          IconButton(
            onPressed: _toggleSelectionMode,
            icon: const Icon(Icons.checklist, color: Colors.black54),
          ),
          IconButton(
            onPressed: _shareWishlist,
            icon: const Icon(Icons.share, color: Colors.black54),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create_collection',
                child: Text('Create Collection'),
              ),
              const PopupMenuItem(
                value: 'import_designs',
                child: Text('Import Designs'),
              ),
              const PopupMenuItem(
                value: 'export_wishlist',
                child: Text('Export Wishlist'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
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
                  hintText: 'Search designs...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isFilterExpanded ? Colors.blue[600] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.tune,
                color: _isFilterExpanded ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories
          const Text(
            'Categories',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _categories.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
                selectedColor: Colors.blue[100],
                checkmarkColor: Colors.blue[600],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Price Range and Sort
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price Range',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedPriceRange,
                      items: _priceRanges
                          .map(
                            (range) => DropdownMenuItem(
                              value: range,
                              child: Text(range),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPriceRange = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sort By',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _selectedSortBy,
                      items: _sortOptions
                          .map(
                            (option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSortBy = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_wishlistItems.length} designs',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = true;
                  });
                },
                icon: Icon(
                  Icons.grid_view,
                  color: _isGridView ? Colors.blue[600] : Colors.grey[400],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = false;
                  });
                },
                icon: Icon(
                  Icons.list,
                  color: !_isGridView ? Colors.blue[600] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistContent() {
    if (_wishlistItems.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildEmptyState() {
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
            'Your wishlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding designs you love!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.push(RouteEnum.designCanvas.rawValue);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Explore Designs',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadWishlistItems();
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: _wishlistItems.length,
        itemBuilder: (context, index) {
          return _buildWishlistGridItem(_wishlistItems[index]);
        },
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadWishlistItems();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _wishlistItems.length,
        itemBuilder: (context, index) {
          return _buildWishlistListItem(_wishlistItems[index]);
        },
      ),
    );
  }

  Widget _buildWishlistGridItem(WishlistItem item) {
    final isSelected = _selectedItems.contains(item);

    return GestureDetector(
      onTap: () => _isSelectionMode
          ? _toggleItemSelection(item)
          : _viewDesignDetails(item),
      onLongPress: () => _startSelectionMode(item),
      child: Container(
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey[200],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.primaries[
                                    item.hashCode % Colors.primaries.length],
                                Colors.primaries[
                                        item.hashCode % Colors.primaries.length]
                                    .withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.checkroom,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        if (item.isOnSale)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[600],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SALE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () => _toggleFavorite(item),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: item.isFavorite
                                    ? Colors.red[600]
                                    : Colors.grey[600],
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.designer,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            if (item.originalPrice != null) ...[
                              Text(
                                '\$${item.originalPrice}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '\$${item.price}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: item.isOnSale
                                    ? Colors.red[600]
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Selection overlay
            if (_isSelectionMode)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[600] : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistListItem(WishlistItem item) {
    final isSelected = _selectedItems.contains(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        onTap: () => _isSelectionMode
            ? _toggleItemSelection(item)
            : _viewDesignDetails(item),
        onLongPress: () => _startSelectionMode(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection checkbox
              if (_isSelectionMode) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[600] : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 16),
              ],

              // Image
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.primaries[item.hashCode % Colors.primaries.length],
                      Colors.primaries[item.hashCode % Colors.primaries.length]
                          .withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.checkroom, color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.designer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (item.originalPrice != null) ...[
                          Text(
                            '\$${item.originalPrice}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          '\$${item.price}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.isOnSale
                                ? Colors.red[600]
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Added ${_formatDate(item.addedDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    onPressed: () => _toggleFavorite(item),
                    icon: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          item.isFavorite ? Colors.red[600] : Colors.grey[600],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shareDesign(item),
                    icon: Icon(Icons.share, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBottomBar() {
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
                onPressed: _selectedItems.isNotEmpty ? _compareSelected : null,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Compare'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _selectedItems.isNotEmpty ? _shareSelected : null,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedItems.isNotEmpty ? _removeSelected : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                ),
                icon: const Icon(Icons.delete, color: Colors.white),
                label:
                    const Text('Remove', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToWishlistFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        context.push(RouteEnum.designCanvas.rawValue);
      },
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Add Design'),
    );
  }

  // Helper methods
  void _onSearchChanged(String query) {
    // Implement search logic
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _startSelectionMode(WishlistItem item) {
    setState(() {
      _isSelectionMode = true;
      _selectedItems = [item];
    });
  }

  void _toggleItemSelection(WishlistItem item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  void _toggleFavorite(WishlistItem item) {
    setState(() {
      item.isFavorite = !item.isFavorite;
    });
  }

  void _viewDesignDetails(WishlistItem item) {
    // Navigate to design details
    context.push('${RouteEnum.designCanvas.rawValue}?id=${item.id}');
  }

  void _shareDesign(WishlistItem item) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${item.title}...')),
    );
  }

  void _shareWishlist() {
    // Implement wishlist sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing wishlist...')),
    );
  }

  void _compareSelected() {
    // Navigate to comparison screen
    context.push('/compare?items=${_selectedItems.map((i) => i.id).join(',')}');
  }

  void _shareSelected() {
    // Share selected items
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${_selectedItems.length} designs...')),
    );
  }

  void _removeSelected() {
    setState(() {
      _wishlistItems.removeWhere((item) => _selectedItems.contains(item));
      _selectedItems.clear();
      _isSelectionMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from wishlist')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'create_collection':
        _showCreateCollectionDialog();
        break;
      case 'import_designs':
        _showImportDialog();
        break;
      case 'export_wishlist':
        _exportWishlist();
        break;
    }
  }

  void _showCreateCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Collection'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Collection name',
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    // Implement import functionality
  }

  void _exportWishlist() {
    // Implement export functionality
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class WishlistItem {
  final String id;
  final String title;
  final String designer;
  final int price;
  final int? originalPrice;
  final String imageUrl;
  final String category;
  final bool isOnSale;
  final double rating;
  bool isFavorite;
  final DateTime addedDate;
  final List<String> tags;

  WishlistItem({
    required this.id,
    required this.title,
    required this.designer,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.category,
    this.isOnSale = false,
    required this.rating,
    this.isFavorite = false,
    required this.addedDate,
    required this.tags,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
