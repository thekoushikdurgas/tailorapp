import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class DesignCollaborationHubScreen extends StatefulWidget {
  const DesignCollaborationHubScreen({super.key});

  @override
  State<DesignCollaborationHubScreen> createState() => _DesignCollaborationHubScreenState();
}

class _DesignCollaborationHubScreenState extends State<DesignCollaborationHubScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late AnimationController _collaborationController;

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _commentsScrollController = ScrollController();

  List<DesignProject> _projects = [];
  DesignProject? _selectedProject;
  List<CollaborationComment> _comments = [];
  List<DesignVersion> _versions = [];
  String _selectedTool = 'select';

  bool _isLiveSession = false;
  List<Collaborator> _activeCollaborators = [];

  final List<String> _designTools = [
    'select',
    'pen',
    'shapes',
    'text',
    'colors',
    'measurements',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _collaborationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _collaborationController.dispose();
    _commentController.dispose();
    _commentsScrollController.dispose();
    super.dispose();
  }

  void _loadProjects() {
    // Mock data - replace with actual API call
    _projects = List.generate(
      8,
      (index) => DesignProject(
        id: 'PROJ${(index + 1).toString().padLeft(3, '0')}',
        name: 'Design Project ${index + 1}',
        description: 'Custom ${[
          'Shirt',
          'Dress',
          'Suit',
          'Jacket',
        ][index % 4]} design project',
        status: ProjectStatus.values[index % ProjectStatus.values.length],
        createdDate: DateTime.now().subtract(Duration(days: index * 3)),
        lastModified: DateTime.now().subtract(Duration(hours: index * 2)),
        tailorId: 'TAILOR${(index % 3) + 1}',
        tailorName: 'Tailor ${(index % 3) + 1}',
        customerId: 'CUSTOMER001',
        customerName: 'You',
        thumbnailUrl: 'https://picsum.photos/300/400?random=$index',
        collaborators: [
          Collaborator(
            'CUSTOMER001',
            'You',
            CollaboratorRole.customer,
            true,
          ),
          Collaborator(
            'TAILOR${(index % 3) + 1}',
            'Tailor ${(index % 3) + 1}',
            CollaboratorRole.tailor,
            index % 2 == 0,
          ),
        ],
        version: index + 1,
        isPublic: index % 4 == 0,
        tags: ['Custom', 'Formal', 'Casual'][index % 3],
      ),
    );

    if (_projects.isNotEmpty) {
      _selectedProject = _projects.first;
      _loadProjectData();
    }

    setState(() {});
  }

  void _loadProjectData() {
    if (_selectedProject == null) return;

    // Load comments
    _comments = List.generate(
      6,
      (index) => CollaborationComment(
        id: 'COMMENT$index',
        authorId: index % 2 == 0 ? 'CUSTOMER001' : _selectedProject!.tailorId,
        authorName: index % 2 == 0 ? 'You' : _selectedProject!.tailorName,
        content: 'Comment ${index + 1}: This looks great! What do you think about adjusting the sleeve length?',
        timestamp: DateTime.now().subtract(Duration(hours: index)),
        position: DesignPosition(50.0 + (index * 20), 100.0 + (index * 15)),
        isResolved: index % 3 == 0,
        replies: index % 4 == 0
            ? [
                CommentReply(
                  'REP$index',
                  _selectedProject!.tailorId,
                  _selectedProject!.tailorName,
                  'I agree! Let me adjust that.',
                  DateTime.now().subtract(Duration(minutes: index * 10)),
                ),
              ]
            : [],
      ),
    );

    // Load versions
    _versions = List.generate(
      4,
      (index) => DesignVersion(
        id: 'VER$index',
        projectId: _selectedProject!.id,
        version: index + 1,
        name: 'Version ${index + 1}',
        description: 'Updated design with ${[
          'collar',
          'sleeves',
          'fit',
          'details',
        ][index]} modifications',
        createdBy: index % 2 == 0 ? 'CUSTOMER001' : _selectedProject!.tailorId,
        createdDate: DateTime.now().subtract(Duration(days: index)),
        thumbnailUrl: 'https://picsum.photos/300/400?random=${index + 10}',
        isActive: index == 0,
        changes: [
          'Modified collar design',
          'Adjusted sleeve length',
          'Updated fit measurements',
        ][index % 3],
      ),
    );

    // Set active collaborators
    _activeCollaborators = _selectedProject!.collaborators.where((c) => c.isOnline).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Projects sidebar
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: _buildProjectsSidebar(),
          ),

          // Main collaboration area
          Expanded(
            child: Column(
              children: [
                // Collaboration header
                if (_selectedProject != null) _buildCollaborationHeader(),

                // Design workspace
                Expanded(
                  child: _selectedProject != null ? _buildDesignWorkspace() : _buildEmptyState(),
                ),
              ],
            ),
          ),

          // Tools and comments panel
          if (_selectedProject != null)
            Container(
              width: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(-2, 0),
                  ),
                ],
              ),
              child: _buildToolsPanel(),
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
      title: Row(
        children: [
          const Text(
            'Design Collaboration',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_isLiveSession) ...[
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[600]!.withValues(alpha: 0.7 + _pulseController.value * 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
      actions: [
        // Active collaborators
        if (_activeCollaborators.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                ..._activeCollaborators.take(3).map(
                      (collaborator) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            collaborator.name.substring(0, 1),
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                if (_activeCollaborators.length > 3)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        '+${_activeCollaborators.length - 3}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Start/Stop collaboration
        IconButton(
          onPressed: _toggleLiveCollaboration,
          icon: Icon(
            _isLiveSession ? Icons.stop : Icons.play_arrow,
            color: _isLiveSession ? Colors.red[600] : Colors.green[600],
          ),
        ),

        // Share project
        IconButton(
          onPressed: _shareProject,
          icon: Icon(Icons.share, color: Colors.grey[600]),
        ),

        // More options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'export', child: Text('Export Design')),
            const PopupMenuItem(
              value: 'duplicate',
              child: Text('Duplicate Project'),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Text('Archive Project'),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Text('Project Settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectsSidebar() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Projects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _createNewProject,
                icon: Icon(Icons.add, color: Colors.blue[600]),
              ),
            ],
          ),
        ),

        // Projects list
        Expanded(
          child: ListView.builder(
            itemCount: _projects.length,
            itemBuilder: (context, index) {
              final project = _projects[index];
              return _buildProjectListItem(project);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProjectListItem(DesignProject project) {
    final isSelected = _selectedProject?.id == project.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: Colors.blue[200]!) : null,
      ),
      child: ListTile(
        onTap: () => _selectProject(project),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [
                Colors.primaries[project.hashCode % Colors.primaries.length],
                Colors.primaries[project.hashCode % Colors.primaries.length].withValues(alpha: 0.7),
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.design_services, color: Colors.white, size: 24),
          ),
        ),
        title: Text(
          project.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.blue[800] : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'with ${project.tailorName}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(project.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    project.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(project.status),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'v${project.version}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: project.collaborators.any((c) => c.isOnline && c.role == CollaboratorRole.tailor)
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCollaborationHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Project info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedProject!.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Collaborating with ${_selectedProject!.tailorName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_selectedProject!.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedProject!.status.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(_selectedProject!.status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Last updated: ${_formatTime(_selectedProject!.lastModified)}',
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

          // Quick actions
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _startVideoCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon: const Icon(Icons.video_call, color: Colors.white, size: 16),
                label: const Text(
                  'Video Call',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _openChat,
                icon: const Icon(Icons.chat, size: 16),
                label: const Text('Chat', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesignWorkspace() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildCanvasTab(),
        _buildVersionsTab(),
        _buildCommentsTab(),
        _buildDetailsTab(),
      ],
    );
  }

  Widget _buildCanvasTab() {
    return Container(
      color: Colors.grey[100],
      child: Stack(
        children: [
          // Design canvas
          Center(
            child: Container(
              width: 400,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Design content
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue[50]!,
                          Colors.purple[50]!,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.design_services,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Design Canvas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Interactive design workspace',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Comments overlay
                  ..._comments.map(
                    (comment) => Positioned(
                      left: comment.position.x,
                      top: comment.position.y,
                      child: _buildCommentMarker(comment),
                    ),
                  ),

                  // Collaboration cursors
                  if (_isLiveSession)
                    ..._activeCollaborators.where((c) => c.id != 'CUSTOMER001').map(
                          (collaborator) => Positioned(
                            left: 100 + (_activeCollaborators.indexOf(collaborator) * 50),
                            top: 200 + (_activeCollaborators.indexOf(collaborator) * 30),
                            child: _buildCollaboratorCursor(collaborator),
                          ),
                        ),
                ],
              ),
            ),
          ),

          // Canvas controls
          Positioned(
            top: 16,
            left: 16,
            child: _buildCanvasControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentMarker(CollaborationComment comment) {
    return GestureDetector(
      onTap: () => _showCommentDetails(comment),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: comment.isResolved ? Colors.green[600] : Colors.orange[600],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${_comments.indexOf(comment) + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollaboratorCursor(Collaborator collaborator) {
    return AnimatedBuilder(
      animation: _collaborationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _collaborationController.value * 20,
            _collaborationController.value * 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  collaborator.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CustomPaint(
                size: const Size(12, 16),
                painter: CursorPainter(Colors.blue[600]!),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCanvasControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () => _zoomIn(),
            icon: const Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: () => _zoomOut(),
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () => _resetZoom(),
            icon: const Icon(Icons.fit_screen),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Design Versions',
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
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _versions.length,
            itemBuilder: (context, index) {
              return _buildVersionCard(_versions[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(DesignVersion version) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: version.isActive ? Colors.blue[600]! : Colors.grey[200]!,
          width: version.isActive ? 2 : 1,
        ),
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
          // Version thumbnail
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  colors: [
                    Colors.primaries[version.hashCode % Colors.primaries.length],
                    Colors.primaries[version.hashCode % Colors.primaries.length].withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.image, color: Colors.white, size: 40),
                  ),
                  if (version.isActive)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ACTIVE',
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

          // Version info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(version.createdDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (!version.isActive)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _activateVersion(version),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      child: const Text(
                        'Activate',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        // Comments list
        Expanded(
          child: ListView.builder(
            controller: _commentsScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              return _buildCommentItem(_comments[index]);
            },
          ),
        ),

        // Add comment input
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentItem(CollaborationComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: comment.isResolved ? Colors.green[200]! : Colors.orange[200]!,
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
          // Comment header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue[100],
                child: Text(
                  comment.authorName.substring(0, 1),
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      _formatTime(comment.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: comment.isResolved ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  comment.isResolved ? 'RESOLVED' : 'OPEN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: comment.isResolved ? Colors.green[600] : Colors.orange[600],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment content
          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          // Replies
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(left: 24),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: comment.replies
                    .map(
                      (reply) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[200],
                              child: Text(
                                reply.authorName.substring(0, 1),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${reply.authorName}: ${reply.content}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(reply.timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Comment actions
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _replyToComment(comment),
                icon: const Icon(Icons.reply, size: 16),
                label: const Text('Reply'),
              ),
              if (!comment.isResolved)
                TextButton.icon(
                  onPressed: () => _resolveComment(comment),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Resolve'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
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
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              mini: true,
              onPressed: _addComment,
              backgroundColor: Colors.blue[600],
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailCard('Project Information', [
            _buildDetailRow('Project ID', _selectedProject!.id),
            _buildDetailRow(
              'Created',
              _formatDate(_selectedProject!.createdDate),
            ),
            _buildDetailRow(
              'Last Modified',
              _formatTime(_selectedProject!.lastModified),
            ),
            _buildDetailRow(
              'Status',
              _selectedProject!.status.name.toUpperCase(),
            ),
            _buildDetailRow('Version', 'v${_selectedProject!.version}'),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard('Collaborators', [
            ..._selectedProject!.collaborators.map((collaborator) => _buildCollaboratorRow(collaborator)),
          ]),
          const SizedBox(height: 16),
          _buildDetailCard('Project Settings', [
            _buildDetailRow(
              'Visibility',
              _selectedProject!.isPublic ? 'Public' : 'Private',
            ),
            _buildDetailRow('Tags', _selectedProject!.tags),
            _buildDetailRow('Comments', '${_comments.length} total'),
            _buildDetailRow('Versions', '${_versions.length} versions'),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> children) {
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorRow(Collaborator collaborator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue[100],
            child: Text(
              collaborator.name.substring(0, 1),
              style: TextStyle(
                color: Colors.blue[600],
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
                  collaborator.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  collaborator.role.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (collaborator.isOnline)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green[600],
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolsPanel() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDesignTools(),
        _buildVersionsTools(),
        _buildCommentsTools(),
        _buildProjectTools(),
      ],
    );
  }

  Widget _buildDesignTools() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Design Tools',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Tool selection
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _designTools.length,
            itemBuilder: (context, index) {
              final tool = _designTools[index];
              final isSelected = _selectedTool == tool;

              return GestureDetector(
                onTap: () => setState(() => _selectedTool = tool),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[600] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getToolIcon(tool),
                        color: isSelected ? Colors.white : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVersionsTools() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Version Control',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createNewVersion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New Version',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _compareVersions,
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Compare'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTools() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments & Feedback',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Total Comments: ${_comments.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unresolved: ${_comments.where((c) => !c.isResolved).length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.orange[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTools() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _exportProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Export', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _duplicateProject,
              icon: const Icon(Icons.copy),
              label: const Text('Duplicate'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.design_services,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a project to start collaborating',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
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
        if (_isLiveSession)
          FloatingActionButton(
            heroTag: 'screen_share',
            onPressed: _shareScreen,
            backgroundColor: Colors.purple[600],
            child: const Icon(Icons.screen_share, color: Colors.white),
          ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          onPressed: _createNewProject,
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'New Project',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.draft:
        return Colors.grey[600]!;
      case ProjectStatus.inProgress:
        return Colors.blue[600]!;
      case ProjectStatus.review:
        return Colors.orange[600]!;
      case ProjectStatus.approved:
        return Colors.green[600]!;
      case ProjectStatus.completed:
        return Colors.purple[600]!;
    }
  }

  IconData _getToolIcon(String tool) {
    switch (tool) {
      case 'select':
        return Icons.mouse;
      case 'pen':
        return Icons.edit;
      case 'shapes':
        return Icons.rectangle;
      case 'text':
        return Icons.text_fields;
      case 'colors':
        return Icons.palette;
      case 'measurements':
        return Icons.straighten;
      default:
        return Icons.help;
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _selectProject(DesignProject project) {
    setState(() {
      _selectedProject = project;
    });
    _loadProjectData();
  }

  void _toggleLiveCollaboration() {
    setState(() {
      _isLiveSession = !_isLiveSession;
    });

    if (_isLiveSession) {
      _collaborationController.repeat();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Live collaboration started'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _collaborationController.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Live collaboration stopped')),
      );
    }
  }

  void _createNewProject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Project'),
        content: const Text('Start a new design collaboration project.'),
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

  void _shareProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing project...')),
    );
  }

  void _startVideoCall() {
    context.push('${RouteEnum.customerCommunicationHub.rawValue}?video=true');
  }

  void _openChat() {
    context.push(RouteEnum.customerCommunicationHub.rawValue);
  }

  void _showCommentDetails(CollaborationComment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Comment #${_comments.indexOf(comment) + 1}'),
        content: Text(comment.content),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {}
  void _zoomOut() {}
  void _resetZoom() {}

  void _activateVersion(DesignVersion version) {
    setState(() {
      for (final v in _versions) {
        v.isActive = v.id == version.id;
      }
    });
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      final newComment = CollaborationComment(
        id: 'COMMENT_${DateTime.now().millisecondsSinceEpoch}',
        authorId: 'CUSTOMER001',
        authorName: 'You',
        content: _commentController.text.trim(),
        timestamp: DateTime.now(),
        position: DesignPosition(150.0, 200.0),
        isResolved: false,
        replies: [],
      );

      setState(() {
        _comments.insert(0, newComment);
      });

      _commentController.clear();
    }
  }

  void _replyToComment(CollaborationComment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Comment'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Write a reply...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Reply'),
          ),
        ],
      ),
    );
  }

  void _resolveComment(CollaborationComment comment) {
    setState(() {
      comment.isResolved = true;
    });
  }

  void _createNewVersion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating new version...')),
    );
  }

  void _compareVersions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compare Versions'),
        content: const Text('Select versions to compare side by side.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting project...')),
    );
  }

  void _duplicateProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duplicating project...')),
    );
  }

  void _shareScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting screen share...')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportProject();
        break;
      case 'duplicate':
        _duplicateProject();
        break;
      case 'archive':
        _archiveProject();
        break;
      case 'settings':
        _showProjectSettings();
        break;
    }
  }

  void _archiveProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Archiving project...')),
    );
  }

  void _showProjectSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Project Settings'),
        content: const Text('Configure project permissions and settings.'),
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

// Custom painter for collaboration cursor
class CursorPainter extends CustomPainter {
  final Color color;

  CursorPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Data models
class DesignProject {
  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final DateTime createdDate;
  final DateTime lastModified;
  final String tailorId;
  final String tailorName;
  final String customerId;
  final String customerName;
  final String thumbnailUrl;
  final List<Collaborator> collaborators;
  final int version;
  final bool isPublic;
  final String tags;

  DesignProject({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdDate,
    required this.lastModified,
    required this.tailorId,
    required this.tailorName,
    required this.customerId,
    required this.customerName,
    required this.thumbnailUrl,
    required this.collaborators,
    required this.version,
    required this.isPublic,
    required this.tags,
  });

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DesignProject && runtimeType == other.runtimeType && id == other.id;
}

class Collaborator {
  final String id;
  final String name;
  final CollaboratorRole role;
  final bool isOnline;

  Collaborator(this.id, this.name, this.role, this.isOnline);
}

class CollaborationComment {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;
  final DesignPosition position;
  bool isResolved;
  final List<CommentReply> replies;

  CollaborationComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    required this.position,
    required this.isResolved,
    required this.replies,
  });
}

class CommentReply {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime timestamp;

  CommentReply(
    this.id,
    this.authorId,
    this.authorName,
    this.content,
    this.timestamp,
  );
}

class DesignVersion {
  final String id;
  final String projectId;
  final int version;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdDate;
  final String thumbnailUrl;
  bool isActive;
  final String changes;

  DesignVersion({
    required this.id,
    required this.projectId,
    required this.version,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdDate,
    required this.thumbnailUrl,
    required this.isActive,
    required this.changes,
  });

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DesignVersion && runtimeType == other.runtimeType && id == other.id;
}

class DesignPosition {
  final double x;
  final double y;

  DesignPosition(this.x, this.y);
}

enum ProjectStatus { draft, inProgress, review, approved, completed }

enum CollaboratorRole { customer, tailor, designer }
