import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class VirtualWardrobeScreen extends StatefulWidget {
  const VirtualWardrobeScreen({super.key});

  @override
  State<VirtualWardrobeScreen> createState() => _VirtualWardrobeScreenState();
}

class _VirtualWardrobeScreenState extends State<VirtualWardrobeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  String _selectedCategory = 'All';
  String _selectedSeason = 'All Seasons';
  bool _is3DView = true;
  bool _isAIMode = false;
  List<WardrobeItem> _wardrobeItems = [];
  final List<WardrobeItem> _selectedOutfit = [];
  OutfitSuggestion? _currentSuggestion;

  final List<String> _categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Suits',
    'Accessories',
    'Shoes',
  ];

  final List<String> _seasons = [
    'All Seasons',
    'Spring',
    'Summer',
    'Fall',
    'Winter',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _loadWardrobeItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _loadWardrobeItems() {
    // Mock data - replace with actual API call
    _wardrobeItems = List.generate(
      30,
      (index) => WardrobeItem(
        id: 'item_$index',
        name: 'Item ${index + 1}',
        category: _categories[(index % (_categories.length - 1)) + 1],
        color: Colors.primaries[index % Colors.primaries.length],
        season: _seasons[(index % (_seasons.length - 1)) + 1],
        wearCount: index * 2,
        lastWorn: DateTime.now().subtract(Duration(days: index)),
        tags: ['Casual', 'Comfortable', 'Stylish'],
        compatibilityScore: 0.8 + (index % 3) * 0.1,
        sustainabilityRating: 3 + (index % 3),
        price: 50 + (index * 10),
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
          // View toggle and filters
          _buildTopControls(),

          // Main content
          Expanded(
            child: _is3DView ? _build3DView() : _buildGridView(),
          ),

          // Bottom controls
          if (_selectedOutfit.isNotEmpty) _buildOutfitControls(),
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
        'Virtual Wardrobe',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _toggleAIMode,
          icon: Icon(
            Icons.auto_awesome,
            color: _isAIMode ? Colors.purple[600] : Colors.grey[600],
          ),
        ),
        IconButton(
          onPressed: () {
            context.push(RouteEnum.styleConsultationBooking.rawValue);
          },
          icon: Icon(Icons.video_call, color: Colors.grey[600]),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'analytics',
              child: Text('Wardrobe Analytics'),
            ),
            const PopupMenuItem(
              value: 'challenges',
              child: Text('Style Challenges'),
            ),
            const PopupMenuItem(
              value: 'sustainability',
              child: Text('Sustainability Report'),
            ),
            const PopupMenuItem(value: 'share', child: Text('Share Wardrobe')),
          ],
        ),
      ],
    );
  }

  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // View toggle
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _is3DView = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _is3DView
                                  ? Colors.blue[600]
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.view_in_ar,
                                  color: _is3DView
                                      ? Colors.white
                                      : Colors.grey[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '3D View',
                                  style: TextStyle(
                                    color: _is3DView
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _is3DView = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_is3DView
                                  ? Colors.blue[600]
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view,
                                  color: !_is3DView
                                      ? Colors.white
                                      : Colors.grey[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Grid View',
                                  style: TextStyle(
                                    color: !_is3DView
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
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
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSeason,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  items: _seasons
                      .map(
                        (season) => DropdownMenuItem(
                          value: season,
                          child: Text(season),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSeason = value!;
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

  Widget _build3DView() {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          // 3D Wardrobe Visualization
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  // 3D Wardrobe Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey[200]!,
                          Colors.grey[100]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _rotationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _rotationController.value * 2 * 3.14159,
                                child: Icon(
                                  Icons.view_in_ar,
                                  size: 80,
                                  color: Colors.blue[300],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '3D Virtual Wardrobe',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AR visualization coming soon',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3D Controls
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        _build3DControlButton(
                          Icons.rotate_90_degrees_ccw,
                          'Rotate',
                        ),
                        const SizedBox(height: 8),
                        _build3DControlButton(Icons.zoom_in, 'Zoom'),
                        const SizedBox(height: 8),
                        _build3DControlButton(Icons.fullscreen, 'Fullscreen'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // AI Outfit Suggestions
          if (_isAIMode) _buildAIOutfitSuggestions(),

          // Item Categories Tabs
          _buildCategoryTabs(),
        ],
      ),
    );
  }

  Widget _build3DControlButton(IconData icon, String tooltip) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          // Implement 3D control action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$tooltip control activated')),
          );
        },
        icon: Icon(icon, size: 20, color: Colors.grey[600]),
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildAIOutfitSuggestions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple[50]!, Colors.blue[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Styling Assistant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[800],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _generateNewOutfit,
                child: const Text('Generate New'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_currentSuggestion != null) ...[
            Text(
              _currentSuggestion!.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentSuggestion!.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Match Score: ${(_currentSuggestion!.matchScore * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Occasion: ${_currentSuggestion!.occasion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ] else
            Text(
              'Tap "Generate New" to get AI outfit suggestions',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.blue[600],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue[600],
            tabs: const [
              Tab(text: 'Tops'),
              Tab(text: 'Bottoms'),
              Tab(text: 'Dresses'),
              Tab(text: 'Accessories'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItemGrid('Tops'),
                _buildItemGrid('Bottoms'),
                _buildItemGrid('Dresses'),
                _buildItemGrid('Accessories'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(String category) {
    final items =
        _wardrobeItems.where((item) => item.category == category).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildWardrobeItemCard(items[index]);
      },
    );
  }

  Widget _buildGridView() {
    final filteredItems = _getFilteredItems();

    return RefreshIndicator(
      onRefresh: () async {
        _loadWardrobeItems();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          return _buildWardrobeItemCard(filteredItems[index]);
        },
      ),
    );
  }

  Widget _buildWardrobeItemCard(WardrobeItem item) {
    final isSelected = _selectedOutfit.contains(item);

    return GestureDetector(
      onTap: () => _toggleItemSelection(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue[600]! : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
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
            // Item image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.3),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _getCategoryIcon(item.category),
                        size: 40,
                        color: item.color,
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSustainabilityColor(
                            item.sustainabilityRating,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.sustainabilityRating}/5',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Item details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 12,
                          color: Colors.red[300],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.wearCount}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${item.price}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
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
      ),
    );
  }

  Widget _buildOutfitControls() {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Current Outfit (${_selectedOutfit.length} items)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearOutfit,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _tryOnOutfit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.view_in_ar, color: Colors.white),
                    label: const Text(
                      'Try On',
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
                    onPressed: _saveOutfit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Save Outfit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareOutfit,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
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
          heroTag: 'add_item',
          onPressed: _addNewItem,
          backgroundColor: Colors.green[600],
          child: const Icon(Icons.add, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'style_challenge',
          onPressed: _joinStyleChallenge,
          backgroundColor: Colors.orange[600],
          child: const Icon(Icons.emoji_events, color: Colors.white),
        ),
      ],
    );
  }

  // Helper methods
  List<WardrobeItem> _getFilteredItems() {
    return _wardrobeItems.where((item) {
      final categoryMatch =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final seasonMatch =
          _selectedSeason == 'All Seasons' || item.season == _selectedSeason;
      return categoryMatch && seasonMatch;
    }).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Tops':
        return Icons.checkroom;
      case 'Bottoms':
        return Icons.dry_cleaning;
      case 'Dresses':
        return Icons.woman;
      case 'Suits':
        return Icons.business_center;
      case 'Accessories':
        return Icons.watch;
      case 'Shoes':
        return Icons.directions_walk;
      default:
        return Icons.checkroom;
    }
  }

  Color _getSustainabilityColor(int rating) {
    if (rating >= 4) return Colors.green[600]!;
    if (rating >= 3) return Colors.orange[600]!;
    return Colors.red[600]!;
  }

  void _toggleItemSelection(WardrobeItem item) {
    setState(() {
      if (_selectedOutfit.contains(item)) {
        _selectedOutfit.remove(item);
      } else {
        _selectedOutfit.add(item);
      }
    });
  }

  void _toggleAIMode() {
    setState(() {
      _isAIMode = !_isAIMode;
      if (_isAIMode) {
        _generateNewOutfit();
      }
    });
  }

  void _generateNewOutfit() {
    // AI outfit generation logic
    setState(() {
      _currentSuggestion = OutfitSuggestion(
        name: 'Smart Casual Look',
        description: 'Perfect for a casual day out with friends',
        matchScore: 0.9,
        occasion: 'Casual',
        items: _wardrobeItems.take(3).toList(),
      );
    });
  }

  void _clearOutfit() {
    setState(() {
      _selectedOutfit.clear();
    });
  }

  void _tryOnOutfit() {
    context.push(RouteEnum.virtualFitting.rawValue);
  }

  void _saveOutfit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Outfit saved to your collection!')),
    );
  }

  void _shareOutfit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing outfit...')),
    );
  }

  void _addNewItem() {
    context.push(RouteEnum.designCanvas.rawValue);
  }

  void _joinStyleChallenge() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Style Challenge'),
        content: const Text(
          'Join the weekly style challenge and compete with friends!',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Join Now'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'analytics':
        _showWardrobeAnalytics();
        break;
      case 'challenges':
        _showStyleChallenges();
        break;
      case 'sustainability':
        _showSustainabilityReport();
        break;
      case 'share':
        _shareWardrobe();
        break;
    }
  }

  void _showWardrobeAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wardrobe Analytics'),
        content: const Text('Your wardrobe insights and usage patterns.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStyleChallenges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Style Challenges'),
        content: const Text(
          'Participate in weekly style challenges and win rewards!',
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

  void _showSustainabilityReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sustainability Report'),
        content: const Text(
          'Your environmental impact and sustainable fashion choices.',
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

  void _shareWardrobe() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing wardrobe...')),
    );
  }
}

class WardrobeItem {
  final String id;
  final String name;
  final String category;
  final Color color;
  final String season;
  final int wearCount;
  final DateTime lastWorn;
  final List<String> tags;
  final double compatibilityScore;
  final int sustainabilityRating;
  final int price;

  WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.season,
    required this.wearCount,
    required this.lastWorn,
    required this.tags,
    required this.compatibilityScore,
    required this.sustainabilityRating,
    required this.price,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardrobeItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class OutfitSuggestion {
  final String name;
  final String description;
  final double matchScore;
  final String occasion;
  final List<WardrobeItem> items;

  OutfitSuggestion({
    required this.name,
    required this.description,
    required this.matchScore,
    required this.occasion,
    required this.items,
  });
}
