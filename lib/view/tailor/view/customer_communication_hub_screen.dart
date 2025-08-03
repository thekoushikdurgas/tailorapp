import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/product/enum/route_enum.dart';
import 'package:go_router/go_router.dart';

class CustomerCommunicationHubScreen extends StatefulWidget {
  const CustomerCommunicationHubScreen({super.key});

  @override
  State<CustomerCommunicationHubScreen> createState() => _CustomerCommunicationHubScreenState();
}

class _CustomerCommunicationHubScreenState extends State<CustomerCommunicationHubScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _typingController;

  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  List<CustomerContact> _customers = [];
  CustomerContact? _selectedCustomer;
  List<ChatMessage> _messages = [];
  String _selectedFilter = 'All Customers';
  final bool _isTyping = false;
  bool _isVideoCallActive = false;

  final List<String> _filterOptions = [
    'All Customers',
    'Active Projects',
    'Pending Response',
    'Recent Contacts',
    'Favorites',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadCustomers();
    _loadMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _typingController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _loadCustomers() {
    // Mock data - replace with actual API call
    _customers = List.generate(
      12,
      (index) => CustomerContact(
        id: 'CUST${(index + 1).toString().padLeft(3, '0')}',
        name: 'Customer ${index + 1}',
        email: 'customer${index + 1}@example.com',
        phone: '+1-555-${(1000 + index).toString()}',
        avatar: null,
        isOnline: index % 3 == 0,
        lastSeen: index % 3 == 0 ? DateTime.now() : DateTime.now().subtract(Duration(hours: index)),
        activeProjects: [
          'ORD${(index + 1).toString().padLeft(3, '0')}',
          if (index % 2 == 0) 'ORD${(index + 2).toString().padLeft(3, '0')}',
        ],
        unreadCount: index % 4 == 0 ? index + 1 : 0,
        lastMessage: 'Last message from customer ${index + 1}...',
        lastMessageTime: DateTime.now().subtract(Duration(minutes: index * 15)),
        priority: CustomerPriority.values[index % CustomerPriority.values.length],
        isFavorite: index % 5 == 0,
        communicationPreference: CommunicationPreference.values[index % CommunicationPreference.values.length],
        timezone: 'UTC${index % 12 - 6}',
        tags: ['VIP', 'Regular', 'New Client'][index % 3],
      ),
    );

    // Set first customer as selected
    if (_customers.isNotEmpty) {
      _selectedCustomer = _customers.first;
    }

    setState(() {});
  }

  void _loadMessages() {
    if (_selectedCustomer == null) return;

    // Mock messages
    _messages = List.generate(
      10,
      (index) => ChatMessage(
        id: 'MSG$index',
        senderId: index % 2 == 0 ? 'tailor' : _selectedCustomer!.id,
        senderName: index % 2 == 0 ? 'You' : _selectedCustomer!.name,
        content: index % 2 == 0 ? 'Message from tailor ${index + 1}' : 'Message from customer ${index + 1}',
        timestamp: DateTime.now().subtract(Duration(minutes: index * 10)),
        type: MessageType.values[index % MessageType.values.length],
        status: MessageStatus.values[index % MessageStatus.values.length],
        attachments: index % 4 == 0 ? ['image.jpg', 'document.pdf'] : [],
        isFromTailor: index % 2 == 0,
      ),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Row(
        children: [
          // Customer list sidebar
          Container(
            width: 320,
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
            child: _buildCustomerSidebar(),
          ),

          // Chat area
          Expanded(
            child: _selectedCustomer != null ? _buildChatArea() : _buildEmptyState(),
          ),
        ],
      ),
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
        'Customer Communication',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Search
        IconButton(
          onPressed: _showSearch,
          icon: Icon(Icons.search, color: Colors.grey[600]),
        ),

        // Video call
        if (_selectedCustomer != null)
          IconButton(
            onPressed: _startVideoCall,
            icon: Icon(
              Icons.video_call,
              color: _isVideoCallActive ? Colors.green[600] : Colors.grey[600],
            ),
          ),

        // Phone call
        if (_selectedCustomer != null)
          IconButton(
            onPressed: _startPhoneCall,
            icon: Icon(Icons.phone, color: Colors.grey[600]),
          ),

        // More options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'broadcast',
              child: Text('Broadcast Message'),
            ),
            const PopupMenuItem(
              value: 'templates',
              child: Text('Message Templates'),
            ),
            const PopupMenuItem(
              value: 'auto_replies',
              child: Text('Auto Replies'),
            ),
            const PopupMenuItem(
              value: 'export_chat',
              child: Text('Export Chat'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSidebar() {
    return Column(
      children: [
        // Search and filter
        Container(
          padding: const EdgeInsets.all(16),
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
                    hintText: 'Search customers...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: _searchCustomers,
                ),
              ),

              const SizedBox(height: 12),

              // Filter dropdown
              DropdownButtonFormField<String>(
                value: _selectedFilter,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                items: _filterOptions
                    .map(
                      (filter) => DropdownMenuItem(value: filter, child: Text(filter)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
            ],
          ),
        ),

        // Customer list
        Expanded(
          child: ListView.builder(
            itemCount: _getFilteredCustomers().length,
            itemBuilder: (context, index) {
              final customer = _getFilteredCustomers()[index];
              return _buildCustomerListItem(customer);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerListItem(CustomerContact customer) {
    final isSelected = _selectedCustomer?.id == customer.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: Colors.blue[200]!) : null,
      ),
      child: ListTile(
        onTap: () => _selectCustomer(customer),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue[100],
              child: Text(
                customer.name.substring(0, 1),
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (customer.isOnline)
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
            if (customer.isFavorite)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                customer.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.blue[800] : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (customer.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${customer.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.lastMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _formatTime(customer.lastMessageTime),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(customer.priority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    customer.priority.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(customer.priority),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: customer.activeProjects.isNotEmpty
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${customer.activeProjects.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildChatArea() {
    return Column(
      children: [
        // Chat header
        _buildChatHeader(),

        // Tab bar for different communication modes
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue[600],
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Colors.blue[600],
            tabs: const [
              Tab(text: 'Messages'),
              Tab(text: 'Projects'),
              Tab(text: 'Files'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMessagesTab(),
              _buildProjectsTab(),
              _buildFilesTab(),
            ],
          ),
        ),

        // Message input area
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatHeader() {
    if (_selectedCustomer == null) return const SizedBox.shrink();

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
          // Customer avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[100],
                child: Text(
                  _selectedCustomer!.name.substring(0, 1),
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              if (_selectedCustomer!.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
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

          // Customer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _selectedCustomer!.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_selectedCustomer!.isFavorite) Icon(Icons.star, color: Colors.orange[600], size: 16),
                  ],
                ),
                Text(
                  _selectedCustomer!.isOnline ? 'Online now' : 'Last seen ${_formatTime(_selectedCustomer!.lastSeen)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedCustomer!.isOnline ? Colors.green[600] : Colors.grey[600],
                  ),
                ),
                if (_selectedCustomer!.activeProjects.isNotEmpty)
                  Text(
                    'Active Projects: ${_selectedCustomer!.activeProjects.join(", ")}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Quick actions
          Row(
            children: [
              IconButton(
                onPressed: _startVideoCall,
                icon: Icon(
                  Icons.video_call,
                  color: _isVideoCallActive ? Colors.green[600] : Colors.grey[600],
                ),
              ),
              IconButton(
                onPressed: _startPhoneCall,
                icon: Icon(Icons.phone, color: Colors.grey[600]),
              ),
              IconButton(
                onPressed: () => _showCustomerDetails(_selectedCustomer!),
                icon: Icon(Icons.info_outline, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _chatScrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),

        // Typing indicator
        if (_isTyping)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.person, size: 16, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _typingController,
                  builder: (context, child) {
                    return Text(
                      '${_selectedCustomer?.name} is typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromTailor = message.isFromTailor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isFromTailor ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromTailor) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Text(
                message.senderName.substring(0, 1),
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromTailor ? Colors.blue[600] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isFromTailor ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isFromTailor ? const Radius.circular(4) : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isFromTailor ? Colors.white : Colors.black87,
                    ),
                  ),

                  // Attachments
                  if (message.attachments.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...message.attachments.map(
                      (attachment) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: isFromTailor ? Colors.blue[500] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getFileIcon(attachment),
                              size: 16,
                              color: isFromTailor ? Colors.white : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              attachment,
                              style: TextStyle(
                                fontSize: 12,
                                color: isFromTailor ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Timestamp and status
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isFromTailor ? Colors.blue[100] : Colors.grey[500],
                        ),
                      ),
                      if (isFromTailor) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _getStatusIcon(message.status),
                          size: 12,
                          color: Colors.blue[100],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isFromTailor) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple[100],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.purple[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Project summary
          if (_selectedCustomer?.activeProjects.isNotEmpty ?? false) ...[
            const Text(
              'Active Projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ..._selectedCustomer!.activeProjects.map((projectId) => _buildProjectCard(projectId)),
          ] else
            const Center(
              child: Text(
                'No active projects with this customer',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(String projectId) {
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
              Text(
                projectId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'In Progress',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Custom suit with special measurements',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewProject(projectId),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateProject(projectId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                  ),
                  icon: const Icon(Icons.update, color: Colors.white, size: 16),
                  label: const Text(
                    'Update',
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

  Widget _buildFilesTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Shared Files\n(Document and media sharing)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
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
            // Attachment button
            IconButton(
              onPressed: _showAttachmentOptions,
              icon: Icon(Icons.attach_file, color: Colors.grey[600]),
            ),

            // Message input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  onChanged: _onTyping,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Template button
            IconButton(
              onPressed: _showMessageTemplates,
              icon: Icon(Icons.text_snippet, color: Colors.grey[600]),
            ),

            // Send button
            FloatingActionButton(
              mini: true,
              onPressed: _sendMessage,
              backgroundColor: Colors.blue[600],
              child: const Icon(Icons.send, color: Colors.white),
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
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Select a customer to start chatting',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<CustomerContact> _getFilteredCustomers() {
    return _customers.where((customer) {
      // Apply filters based on selected option
      switch (_selectedFilter) {
        case 'Active Projects':
          return customer.activeProjects.isNotEmpty;
        case 'Pending Response':
          return customer.unreadCount > 0;
        case 'Recent Contacts':
          return customer.lastMessageTime.isAfter(
            DateTime.now().subtract(const Duration(days: 1)),
          );
        case 'Favorites':
          return customer.isFavorite;
        default:
          return true;
      }
    }).toList();
  }

  Color _getPriorityColor(CustomerPriority priority) {
    switch (priority) {
      case CustomerPriority.low:
        return Colors.green[600]!;
      case CustomerPriority.medium:
        return Colors.orange[600]!;
      case CustomerPriority.high:
        return Colors.red[600]!;
      case CustomerPriority.urgent:
        return Colors.purple[600]!;
    }
  }

  IconData _getFileIcon(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.attachment;
    }
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  void _selectCustomer(CustomerContact customer) {
    setState(() {
      _selectedCustomer = customer;
    });
    _loadMessages();
  }

  void _searchCustomers(String query) {
    // Implement customer search
  }

  void _onTyping(String value) {
    // Handle typing indicator
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = ChatMessage(
        id: 'MSG${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'tailor',
        senderName: 'You',
        content: _messageController.text.trim(),
        timestamp: DateTime.now(),
        type: MessageType.text,
        status: MessageStatus.sent,
        attachments: [],
        isFromTailor: true,
      );

      setState(() {
        _messages.insert(0, message);
      });

      _messageController.clear();

      // Scroll to bottom
      _chatScrollController.animateTo(
        _chatScrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _startVideoCall() {
    setState(() {
      _isVideoCallActive = !_isVideoCallActive;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isVideoCallActive ? 'Started video call with ${_selectedCustomer?.name}' : 'Ended video call',
        ),
      ),
    );
  }

  void _startPhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${_selectedCustomer?.name}...'),
      ),
    );
  }

  void _showCustomerDetails(CustomerContact customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${customer.email}'),
            Text('Phone: ${customer.phone}'),
            Text('Priority: ${customer.priority.name}'),
            Text('Active Projects: ${customer.activeProjects.length}'),
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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                context.pop();
                _attachCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                context.pop();
                _attachGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Document'),
              onTap: () {
                context.pop();
                _attachDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageTemplates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message Templates'),
        content: const Text('Quick message templates will be shown here.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Messages'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search in messages...',
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

  void _viewProject(String projectId) {
    context.push('${RouteEnum.orderManagement.rawValue}?project=$projectId');
  }

  void _updateProject(String projectId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating project $projectId...')),
    );
  }

  void _attachCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening camera...')),
    );
  }

  void _attachGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening gallery...')),
    );
  }

  void _attachDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening document picker...')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'broadcast':
        _showBroadcastMessage();
        break;
      case 'templates':
        _showMessageTemplates();
        break;
      case 'auto_replies':
        _showAutoReplies();
        break;
      case 'export_chat':
        _exportChat();
        break;
    }
  }

  void _showBroadcastMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Message'),
        content: const Text('Send a message to multiple customers at once.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: () => context.pop(), child: const Text('Send')),
        ],
      ),
    );
  }

  void _showAutoReplies() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Replies'),
        content: const Text('Configure automatic responses for common questions.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting chat history...')),
    );
  }
}

// Data models
class CustomerContact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final bool isOnline;
  final DateTime lastSeen;
  final List<String> activeProjects;
  final int unreadCount;
  final String lastMessage;
  final DateTime lastMessageTime;
  final CustomerPriority priority;
  final bool isFavorite;
  final CommunicationPreference communicationPreference;
  final String timezone;
  final String tags;

  CustomerContact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.isOnline,
    required this.lastSeen,
    required this.activeProjects,
    required this.unreadCount,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.priority,
    required this.isFavorite,
    required this.communicationPreference,
    required this.timezone,
    required this.tags,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final List<String> attachments;
  final bool isFromTailor;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.status,
    required this.attachments,
    required this.isFromTailor,
  });
}

enum CustomerPriority { low, medium, high, urgent }

enum CommunicationPreference { email, phone, chat, video }

enum MessageType { text, image, document, audio, video }

enum MessageStatus { sent, delivered, read, failed }
