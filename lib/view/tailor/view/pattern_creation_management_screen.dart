import 'package:flutter/material.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class PatternCreationManagementScreen extends StatefulWidget {
  const PatternCreationManagementScreen({super.key});

  @override
  State<PatternCreationManagementScreen> createState() =>
      _PatternCreationManagementScreenState();
}

class _PatternCreationManagementScreenState
    extends State<PatternCreationManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _createController;

  final TextEditingController _searchController = TextEditingController();
  final PageController _patternPageController = PageController();

  List<DigitalPattern> _patterns = [];
  List<PatternTemplate> _templates = [];
  List<PatternCategory> _categories = [];
  DigitalPattern? _selectedPattern;
  String _selectedFilter = 'All Patterns';
  String _selectedCategory = 'All';
  final String _selectedSize = 'All Sizes';
  bool _isGridView = true;
  bool _isCreatingPattern = false;

  final List<String> _filterOptions = [
    'All Patterns',
    'My Patterns',
    'Recent',
    'Favorites',
    'Shared',
    'Templates',
  ];

  final List<String> _sizeOptions = [
    'All Sizes',
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'Custom',
  ];

  final List<String> _patternTypes = [
    'Shirt',
    'Dress',
    'Pants',
    'Jacket',
    'Skirt',
    'Blouse',
    'Suit',
    'Coat',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _createController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadPatterns();
    _loadTemplates();
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _createController.dispose();
    _searchController.dispose();
    _patternPageController.dispose();
    super.dispose();
  }

  void _loadPatterns() {
    // Mock data - replace with actual API call
    _patterns = List.generate(
      20,
      (index) => DigitalPattern(
        id: 'PAT${(index + 1).toString().padLeft(3, '0')}',
        name:
            '${_patternTypes[index % _patternTypes.length]} Pattern ${index + 1}',
        description:
            'Professional ${_patternTypes[index % _patternTypes.length].toLowerCase()} pattern with detailed instructions',
        type: _patternTypes[index % _patternTypes.length],
        category: PatternCategory(
          id: 'CAT${(index % 4) + 1}',
          name: ['Formal', 'Casual', 'Evening', 'Business'][index % 4],
          color: [
            Colors.blue,
            Colors.green,
            Colors.purple,
            Colors.orange,
          ][index % 4],
        ),
        difficulty:
            PatternDifficulty.values[index % PatternDifficulty.values.length],
        sizes: ['S', 'M', 'L', 'XL'],
        materials: ['Cotton', 'Silk', 'Wool', 'Linen'][index % 4],
        estimatedTime: Duration(hours: 2 + (index % 6)),
        createdDate: DateTime.now().subtract(Duration(days: index * 2)),
        modifiedDate: DateTime.now().subtract(Duration(hours: index)),
        thumbnailUrl: 'https://picsum.photos/300/400?random=$index',
        authorId: 'TAILOR001',
        authorName: 'Your Patterns',
        isPublic: index % 3 == 0,
        isFavorite: index % 5 == 0,
        downloadCount: index * 10,
        rating: 4.0 + (index % 2),
        tags: ['Professional', 'Modern', 'Classic', 'Trendy'][index % 4],
        instructions: List.generate(
          5,
          (i) => PatternInstruction(
            step: i + 1,
            title: 'Step ${i + 1}',
            description: 'Detailed instruction for step ${i + 1}',
            imageUrl: null,
            estimatedTime: Duration(minutes: 15 + (i * 5)),
          ),
        ),
        measurements: {
          'Chest': 96.0,
          'Waist': 76.0,
          'Hips': 100.0,
          'Shoulder': 42.0,
        },
        pieces: List.generate(
          4,
          (i) => PatternPiece(
            id: 'PIECE$i',
            name: 'Pattern Piece ${i + 1}',
            quantity: i + 1,
            fabricUsage: '${0.5 + (i * 0.2)}m',
            cuttingInstructions: 'Cut ${i + 1} piece(s) on fold',
          ),
        ),
      ),
    );
    setState(() {});
  }

  void _loadTemplates() {
    _templates = List.generate(
      8,
      (index) => PatternTemplate(
        id: 'TEMP${(index + 1).toString().padLeft(3, '0')}',
        name: 'Template ${index + 1}',
        description: 'Ready-to-use pattern template',
        type: _patternTypes[index % _patternTypes.length],
        thumbnailUrl: 'https://picsum.photos/200/250?random=${index + 100}',
        difficulty:
            PatternDifficulty.values[index % PatternDifficulty.values.length],
        isPremium: index % 3 == 0,
        price: index % 3 == 0 ? 15.99 : 0.0,
        rating: 4.0 + (index % 2),
        downloadCount: (index + 1) * 50,
      ),
    );
  }

  void _loadCategories() {
    _categories = [
      PatternCategory(id: 'CAT1', name: 'Formal', color: Colors.blue),
      PatternCategory(id: 'CAT2', name: 'Casual', color: Colors.green),
      PatternCategory(id: 'CAT3', name: 'Evening', color: Colors.purple),
      PatternCategory(id: 'CAT4', name: 'Business', color: Colors.orange),
    ];
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
                _buildPatternsTab(),
                _buildTemplatesTab(),
                _buildCategoriesTab(),
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
        'Pattern Management',
        style: TextStyle(
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

        // Import patterns
        IconButton(
          onPressed: _importPatterns,
          icon: Icon(Icons.upload_file, color: Colors.grey[600]),
        ),

        // More options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export_all',
              child: Text('Export All Patterns'),
            ),
            const PopupMenuItem(value: 'backup', child: Text('Backup Library')),
            const PopupMenuItem(value: 'sync', child: Text('Sync with Cloud')),
            const PopupMenuItem(
              value: 'settings',
              child: Text('Library Settings'),
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
                      hintText: 'Search patterns...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: _searchPatterns,
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

          // Filter chips
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
                          child: Text(filter),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
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
                  items: ['All', ..._categories.map((cat) => cat.name)]
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    final totalPatterns = _patterns.length;
    final myPatterns = _patterns.where((p) => p.authorId == 'TAILOR001').length;
    final favoritePatterns = _patterns.where((p) => p.isFavorite).length;
    final sharedPatterns = _patterns.where((p) => p.isPublic).length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Patterns',
              '$totalPatterns',
              Icons.library_books,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'My Patterns',
              '$myPatterns',
              Icons.person,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Favorites',
              '$favoritePatterns',
              Icons.favorite,
              Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Shared',
              '$sharedPatterns',
              Icons.share,
              Colors.purple,
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
          Tab(text: 'Patterns'),
          Tab(text: 'Templates'),
          Tab(text: 'Categories'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildPatternsTab() {
    final filteredPatterns = _getFilteredPatterns();

    return RefreshIndicator(
      onRefresh: () async {
        _loadPatterns();
      },
      child: _isGridView
          ? _buildPatternsGrid(filteredPatterns)
          : _buildPatternsList(filteredPatterns),
    );
  }

  Widget _buildPatternsGrid(List<DigitalPattern> patterns) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        return _buildPatternCard(patterns[index]);
      },
    );
  }

  Widget _buildPatternsList(List<DigitalPattern> patterns) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: patterns.length,
      itemBuilder: (context, index) {
        return _buildPatternListItem(patterns[index]);
      },
    );
  }

  Widget _buildPatternCard(DigitalPattern pattern) {
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
        onTap: () => _viewPatternDetails(pattern),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pattern image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [
                      pattern.category.color,
                      pattern.category.color.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.design_services,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),

                    // Badges
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(pattern.difficulty),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pattern.difficulty.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(pattern),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            pattern.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: pattern.isFavorite
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

            // Pattern details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pattern.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pattern.estimatedTime.inHours}h',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              pattern.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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

  Widget _buildPatternListItem(DigitalPattern pattern) {
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
        onTap: () => _viewPatternDetails(pattern),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pattern thumbnail
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      pattern.category.color,
                      pattern.category.color.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.design_services,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Pattern details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pattern.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(pattern.difficulty)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pattern.difficulty.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getDifficultyColor(pattern.difficulty),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pattern.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                pattern.category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            pattern.category.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: pattern.category.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sizes: ${pattern.sizes.join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${pattern.estimatedTime.inHours}h',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pattern.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.download,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${pattern.downloadCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(pattern.modifiedDate),
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
                  IconButton(
                    onPressed: () => _toggleFavorite(pattern),
                    icon: Icon(
                      pattern.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: pattern.isFavorite
                          ? Colors.red[600]
                          : Colors.grey[600],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (action) =>
                        _handlePatternAction(pattern, action),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Pattern'),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('Duplicate'),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('Export'),
                      ),
                      const PopupMenuItem(value: 'share', child: Text('Share')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
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

  Widget _buildTemplatesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(_templates[index]);
      },
    );
  }

  Widget _buildTemplateCard(PatternTemplate template) {
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
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.primaries[
                          template.hashCode % Colors.primaries.length],
                      Colors.primaries[
                              template.hashCode % Colors.primaries.length]
                          .withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.article, color: Colors.white, size: 40),
                    ),
                    if (template.isPremium)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PREMIUM',
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
            ),

            // Template details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
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
                    template.type,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (template.isPremium) ...[
                        Text(
                          '\$${template.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
                        ),
                      ] else ...[
                        Text(
                          'FREE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber[600]),
                          const SizedBox(width: 2),
                          Text(
                            template.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pattern Categories',
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
              childAspectRatio: 1.5,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(_categories[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(PatternCategory category) {
    final patternsInCategory =
        _patterns.where((p) => p.category.id == category.id).length;

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
        onTap: () => _filterByCategory(category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color.withValues(alpha: 0.1),
                category.color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: category.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$patternsInCategory',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$patternsInCategory patterns',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
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
            'Pattern Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Usage statistics
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
                Text(
                  'Pattern Usage Analytics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Advanced analytics dashboard\n(Charts and insights)',
                  textAlign: TextAlign.center,
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
        if (_isCreatingPattern)
          FloatingActionButton(
            heroTag: 'cancel_create',
            onPressed: _cancelCreation,
            backgroundColor: Colors.red[600],
            child: const Icon(Icons.close, color: Colors.white),
          )
        else
          FloatingActionButton(
            heroTag: 'quick_scan',
            onPressed: _scanPattern,
            backgroundColor: Colors.purple[600],
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: _createNewPattern,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(
            _isCreatingPattern ? 'Creating...' : 'New Pattern',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Helper methods
  List<DigitalPattern> _getFilteredPatterns() {
    return _patterns.where((pattern) {
      // Apply filters based on selected options
      final filterMatch = _selectedFilter == 'All Patterns' ||
          (_selectedFilter == 'My Patterns' &&
              pattern.authorId == 'TAILOR001') ||
          (_selectedFilter == 'Favorites' && pattern.isFavorite) ||
          (_selectedFilter == 'Shared' && pattern.isPublic);

      final categoryMatch = _selectedCategory == 'All' ||
          pattern.category.name == _selectedCategory;

      return filterMatch && categoryMatch;
    }).toList();
  }

  Color _getDifficultyColor(PatternDifficulty difficulty) {
    switch (difficulty) {
      case PatternDifficulty.beginner:
        return Colors.green[600]!;
      case PatternDifficulty.intermediate:
        return Colors.orange[600]!;
      case PatternDifficulty.advanced:
        return Colors.red[600]!;
      case PatternDifficulty.expert:
        return Colors.purple[600]!;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _searchPatterns(String query) {
    // Implement pattern search
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advanced Filters'),
        content: const Text('Advanced filtering options for patterns.'),
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

  void _toggleFavorite(DigitalPattern pattern) {
    setState(() {
      pattern.isFavorite = !pattern.isFavorite;
    });
  }

  void _viewPatternDetails(DigitalPattern pattern) {
    setState(() {
      _selectedPattern = pattern;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) =>
            _buildPatternDetailsSheet(pattern, scrollController),
      ),
    );
  }

  Widget _buildPatternDetailsSheet(
    DigitalPattern pattern,
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
                Text(
                  pattern.name,
                  style: const TextStyle(
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

            // Pattern info
            Text(
              pattern.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editPattern(pattern),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Edit Pattern',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _duplicatePattern(pattern),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.copy),
                    label: const Text('Duplicate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _useTemplate(PatternTemplate template) {
    if (template.isPremium) {
      _showPurchaseDialog(template);
    } else {
      _createPatternFromTemplate(template);
    }
  }

  void _showPurchaseDialog(PatternTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Template'),
        content: Text(
          'This template costs \$${template.price.toStringAsFixed(2)}. Purchase to use?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              _purchaseTemplate(template);
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _createPatternFromTemplate(PatternTemplate template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Creating pattern from ${template.name}...')),
    );
  }

  void _purchaseTemplate(PatternTemplate template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchasing ${template.name}...')),
    );
  }

  void _filterByCategory(PatternCategory category) {
    setState(() {
      _selectedCategory = category.name;
      _tabController.animateTo(0); // Switch to patterns tab
    });
  }

  void _createNewPattern() {
    setState(() {
      _isCreatingPattern = !_isCreatingPattern;
    });

    if (_isCreatingPattern) {
      _createController.forward();
      // Navigate to pattern creation screen
      context.push('${RouteEnum.patternCreationManagement.rawValue}/create');
    }
  }

  void _cancelCreation() {
    setState(() {
      _isCreatingPattern = false;
    });
    _createController.reverse();
  }

  void _scanPattern() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting pattern scanner...')),
    );
  }

  void _editPattern(DigitalPattern pattern) {
    context.push(
      '${RouteEnum.patternCreationManagement.rawValue}/edit/${pattern.id}',
    );
  }

  void _duplicatePattern(DigitalPattern pattern) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Duplicating ${pattern.name}...')),
    );
  }

  void _handlePatternAction(DigitalPattern pattern, String action) {
    switch (action) {
      case 'edit':
        _editPattern(pattern);
        break;
      case 'duplicate':
        _duplicatePattern(pattern);
        break;
      case 'export':
        _exportPattern(pattern);
        break;
      case 'share':
        _sharePattern(pattern);
        break;
      case 'delete':
        _deletePattern(pattern);
        break;
    }
  }

  void _exportPattern(DigitalPattern pattern) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exporting ${pattern.name}...')),
    );
  }

  void _sharePattern(DigitalPattern pattern) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${pattern.name}...')),
    );
  }

  void _deletePattern(DigitalPattern pattern) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pattern'),
        content: Text('Are you sure you want to delete "${pattern.name}"?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              setState(() {
                _patterns.remove(pattern);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pattern deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _importPatterns() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Importing patterns...')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export_all':
        _exportAllPatterns();
        break;
      case 'backup':
        _backupLibrary();
        break;
      case 'sync':
        _syncWithCloud();
        break;
      case 'settings':
        _showLibrarySettings();
        break;
    }
  }

  void _exportAllPatterns() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting all patterns...')),
    );
  }

  void _backupLibrary() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating backup...')),
    );
  }

  void _syncWithCloud() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing with cloud...')),
    );
  }

  void _showLibrarySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Library Settings'),
        content: const Text('Configure your pattern library preferences.'),
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
class DigitalPattern {
  final String id;
  final String name;
  final String description;
  final String type;
  final PatternCategory category;
  final PatternDifficulty difficulty;
  final List<String> sizes;
  final String materials;
  final Duration estimatedTime;
  final DateTime createdDate;
  final DateTime modifiedDate;
  final String thumbnailUrl;
  final String authorId;
  final String authorName;
  final bool isPublic;
  bool isFavorite;
  final int downloadCount;
  final double rating;
  final String tags;
  final List<PatternInstruction> instructions;
  final Map<String, double> measurements;
  final List<PatternPiece> pieces;

  DigitalPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.sizes,
    required this.materials,
    required this.estimatedTime,
    required this.createdDate,
    required this.modifiedDate,
    required this.thumbnailUrl,
    required this.authorId,
    required this.authorName,
    required this.isPublic,
    required this.isFavorite,
    required this.downloadCount,
    required this.rating,
    required this.tags,
    required this.instructions,
    required this.measurements,
    required this.pieces,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DigitalPattern && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PatternTemplate {
  final String id;
  final String name;
  final String description;
  final String type;
  final String thumbnailUrl;
  final PatternDifficulty difficulty;
  final bool isPremium;
  final double price;
  final double rating;
  final int downloadCount;

  PatternTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.thumbnailUrl,
    required this.difficulty,
    required this.isPremium,
    required this.price,
    required this.rating,
    required this.downloadCount,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatternTemplate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PatternCategory {
  final String id;
  final String name;
  final Color color;

  PatternCategory({
    required this.id,
    required this.name,
    required this.color,
  });
}

class PatternInstruction {
  final int step;
  final String title;
  final String description;
  final String? imageUrl;
  final Duration estimatedTime;

  PatternInstruction({
    required this.step,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.estimatedTime,
  });
}

class PatternPiece {
  final String id;
  final String name;
  final int quantity;
  final String fabricUsage;
  final String cuttingInstructions;

  PatternPiece({
    required this.id,
    required this.name,
    required this.quantity,
    required this.fabricUsage,
    required this.cuttingInstructions,
  });
}

enum PatternDifficulty { beginner, intermediate, advanced, expert }
