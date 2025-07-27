import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:tailorapp/core/models/user_role.dart';
import 'package:go_router/go_router.dart';

class UniversalSupportScreen extends StatefulWidget {
  const UniversalSupportScreen({super.key});

  @override
  State<UniversalSupportScreen> createState() => _UniversalSupportScreenState();
}

class _UniversalSupportScreenState extends State<UniversalSupportScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _chatBotController;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  UserRole? _userRole;
  String _selectedCategory = 'General';
  bool _isChatBotActive = false;
  final List<SupportMessage> _chatMessages = [];
  List<FAQItem> _faqItems = [];
  List<SupportTicket> _tickets = [];

  final List<String> _supportCategories = [
    'General',
    'Account',
    'Orders',
    'Technical',
    'Billing',
    'Design',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _chatBotController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadUserRole();
    _loadSupportData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatBotController.dispose();
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _loadUserRole() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _userRole = authState.userRole;
      });
    }
  }

  void _loadSupportData() {
    _loadFAQData();
    _loadTickets();
  }

  void _loadFAQData() {
    // Role-specific FAQ data
    final baseFAQs = [
      FAQItem(
        'How do I get started?',
        'Welcome! Follow our quick setup guide to get started with your account.',
        'General',
        ['Getting Started', 'Setup'],
      ),
      FAQItem(
        'How do I reset my password?',
        'Go to Settings > Account > Change Password to reset your password.',
        'Account',
        ['Password', 'Security'],
      ),
    ];

    final roleFAQs = <FAQItem>[];
    switch (_userRole) {
      case UserRole.customer:
        roleFAQs.addAll([
          FAQItem(
            'How do I place an order?',
            'Navigate to Design Studio, create your design, and follow the checkout process.',
            'Orders',
            ['Orders', 'Checkout'],
          ),
          FAQItem(
            'Can I track my order?',
            'Yes! Go to your Order Timeline to see real-time progress updates.',
            'Orders',
            ['Tracking', 'Timeline'],
          ),
          FAQItem(
            'How does virtual fitting work?',
            'Our AR technology allows you to see how garments will look on you before ordering.',
            'Design',
            ['Virtual Fitting', 'AR'],
          ),
        ]);
        break;
      case UserRole.tailor:
        roleFAQs.addAll([
          FAQItem(
            'How do I manage my orders?',
            'Use the Order Management dashboard to track all your active projects.',
            'Orders',
            ['Management', 'Projects'],
          ),
          FAQItem(
            'How do I communicate with customers?',
            'Use the Customer Communication Hub for real-time chat and video calls.',
            'General',
            ['Communication', 'Customers'],
          ),
          FAQItem(
            'How do I update my portfolio?',
            'Go to Portfolio Profile to add new work samples and update your information.',
            'General',
            ['Portfolio', 'Profile'],
          ),
        ]);
        break;
      case UserRole.admin:
        roleFAQs.addAll([
          FAQItem(
            'How do I manage users?',
            'Use the User Management screen to view, edit, and manage all platform users.',
            'General',
            ['Users', 'Management'],
          ),
          FAQItem(
            'How do I view analytics?',
            'Access Platform Analytics for comprehensive business intelligence and insights.',
            'General',
            ['Analytics', 'Reports'],
          ),
        ]);
        break;
      default:
        break;
    }

    setState(() {
      _faqItems = [...baseFAQs, ...roleFAQs];
    });
  }

  void _loadTickets() {
    // Mock support tickets
    _tickets = [
      SupportTicket(
        'TK001',
        'Order delivery question',
        'I need to update my delivery address',
        SupportTicketStatus.open,
        SupportPriority.medium,
        DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SupportTicket(
        'TK002',
        'Payment issue',
        'Payment failed during checkout',
        SupportTicketStatus.inProgress,
        SupportPriority.high,
        DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Role-specific welcome section
          _buildWelcomeSection(),

          // Search bar
          _buildSearchSection(),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFAQTab(),
                _buildChatTab(),
                _buildTicketsTab(),
                _buildCommunityTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildChatBotFAB(),
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
        'Support Center',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _startVideoCall,
          icon: Icon(Icons.video_call, color: Colors.blue[600]),
        ),
        IconButton(
          onPressed: _startPhoneCall,
          icon: Icon(Icons.phone, color: Colors.green[600]),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'emergency',
              child: Text('Emergency Contact'),
            ),
            const PopupMenuItem(
              value: 'feedback',
              child: Text('Submit Feedback'),
            ),
            const PopupMenuItem(value: 'report_bug', child: Text('Report Bug')),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final roleSpecificGreeting = _getRoleSpecificGreeting();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[50]!, Colors.purple[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roleSpecificGreeting,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We\'re here to help 24/7',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search for help...',
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: _searchFAQ,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[600],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[600],
        tabs: const [
          Tab(text: 'FAQ'),
          Tab(text: 'Chat'),
          Tab(text: 'Tickets'),
          Tab(text: 'Community'),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category filter
          _buildCategoryFilter(),
          const SizedBox(height: 16),

          // FAQ items
          ..._getFilteredFAQs().map(_buildFAQItem),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _supportCategories.length,
        itemBuilder: (context, index) {
          final category = _supportCategories[index];
          final isSelected = _selectedCategory == category;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[600],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq.answer,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: faq.tags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.grey[100],
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Was this helpful?',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _rateFAQ(faq, true),
                      icon: const Icon(Icons.thumb_up, size: 16),
                    ),
                    IconButton(
                      onPressed: () => _rateFAQ(faq, false),
                      icon: const Icon(Icons.thumb_down, size: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) =>
                _buildChatMessage(_chatMessages[index]),
          ),
        ),

        // Message input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatMessage(SupportMessage message) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue[100],
              child: Icon(
                Icons.support_agent,
                size: 16,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue[600] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[200],
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
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
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
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
              onPressed: _sendMessage,
              backgroundColor: Colors.blue[600],
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create ticket button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createNewTicket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: const EdgeInsets.all(16),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create New Ticket',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tickets list
          const Text(
            'Your Support Tickets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          ..._tickets.map(_buildTicketItem),
        ],
      ),
    );
  }

  Widget _buildTicketItem(SupportTicket ticket) {
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
          Row(
            children: [
              Text(
                ticket.id,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(ticket.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(ticket.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.subject,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _getPriorityIcon(ticket.priority),
                size: 16,
                color: _getPriorityColor(ticket.priority),
              ),
              const SizedBox(width: 4),
              Text(
                ticket.priority.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getPriorityColor(ticket.priority),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(ticket.createdAt),
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

  Widget _buildCommunityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Community Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Community features
          _buildCommunityFeature(
            'Discussion Forums',
            'Join conversations with other users',
            Icons.forum,
            Colors.blue,
            () {},
          ),
          _buildCommunityFeature(
            'Knowledge Base',
            'Browse detailed guides and tutorials',
            Icons.library_books,
            Colors.green,
            () {},
          ),
          _buildCommunityFeature(
            'Video Tutorials',
            'Watch step-by-step guides',
            Icons.play_circle,
            Colors.red,
            () {},
          ),
          _buildCommunityFeature(
            'User Guides',
            'Download comprehensive manuals',
            Icons.description,
            Colors.orange,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFeature(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildChatBotFAB() {
    return FloatingActionButton.extended(
      onPressed: _toggleChatBot,
      backgroundColor: _isChatBotActive ? Colors.red[600] : Colors.blue[600],
      foregroundColor: Colors.white,
      icon: AnimatedRotation(
        turns: _isChatBotActive ? 0.125 : 0,
        duration: const Duration(milliseconds: 200),
        child: Icon(_isChatBotActive ? Icons.close : Icons.smart_toy),
      ),
      label: Text(
        _isChatBotActive ? 'Close AI' : 'AI Assistant',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  // Helper methods
  String _getRoleSpecificGreeting() {
    switch (_userRole) {
      case UserRole.customer:
        return 'Customer Support';
      case UserRole.tailor:
        return 'Tailor Support Center';
      case UserRole.admin:
        return 'Admin Support Hub';
      default:
        return 'Support Center';
    }
  }

  List<FAQItem> _getFilteredFAQs() {
    return _faqItems
        .where(
          (faq) =>
              _selectedCategory == 'General' ||
              faq.category == _selectedCategory,
        )
        .toList();
  }

  Color _getStatusColor(SupportTicketStatus status) {
    switch (status) {
      case SupportTicketStatus.open:
        return Colors.blue[600]!;
      case SupportTicketStatus.inProgress:
        return Colors.orange[600]!;
      case SupportTicketStatus.resolved:
        return Colors.green[600]!;
      case SupportTicketStatus.closed:
        return Colors.grey[600]!;
    }
  }

  Color _getPriorityColor(SupportPriority priority) {
    switch (priority) {
      case SupportPriority.low:
        return Colors.green[600]!;
      case SupportPriority.medium:
        return Colors.orange[600]!;
      case SupportPriority.high:
        return Colors.red[600]!;
      case SupportPriority.urgent:
        return Colors.purple[600]!;
    }
  }

  IconData _getPriorityIcon(SupportPriority priority) {
    switch (priority) {
      case SupportPriority.low:
        return Icons.low_priority;
      case SupportPriority.medium:
        return Icons.priority_high;
      case SupportPriority.high:
        return Icons.priority_high;
      case SupportPriority.urgent:
        return Icons.warning;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _searchFAQ(String query) {
    // Implement FAQ search functionality
  }

  void _rateFAQ(FAQItem faq, bool helpful) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          helpful ? 'Thanks for your feedback!' : 'We\'ll improve this answer',
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add(
          SupportMessage(
            _messageController.text.trim(),
            true,
            DateTime.now(),
          ),
        );
      });
      _messageController.clear();

      // Simulate bot response
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _chatMessages.add(
            SupportMessage(
              'Thanks for your message! A support agent will respond shortly.',
              false,
              DateTime.now(),
            ),
          );
        });
      });
    }
  }

  void _createNewTicket() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Support Ticket'),
        content: const Text('Ticket creation form will be implemented here.'),
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

  void _toggleChatBot() {
    setState(() {
      _isChatBotActive = !_isChatBotActive;
    });

    if (_isChatBotActive) {
      _chatBotController.forward();
      // Initialize chat bot
      setState(() {
        _chatMessages.add(
          SupportMessage(
            'Hello! I\'m your AI assistant. How can I help you today?',
            false,
            DateTime.now(),
          ),
        );
      });
    } else {
      _chatBotController.reverse();
    }
  }

  void _startVideoCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting video call with support...')),
    );
  }

  void _startPhoneCall() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling support: +1-800-TAILOR')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'emergency':
        _showEmergencyContact();
        break;
      case 'feedback':
        _submitFeedback();
        break;
      case 'report_bug':
        _reportBug();
        break;
    }
  }

  void _showEmergencyContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Contact'),
        content: const Text(
          'For urgent issues, call us at +1-800-EMERGENCY or email emergency@tailorapp.com',
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

  void _submitFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Feedback'),
        content: const Text(
          'Your feedback helps us improve. What would you like to share?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _reportBug() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Bug'),
        content:
            const Text('Describe the issue you encountered so we can fix it.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

// Support models
class FAQItem {
  final String question;
  final String answer;
  final String category;
  final List<String> tags;

  FAQItem(this.question, this.answer, this.category, this.tags);
}

class SupportMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  SupportMessage(this.content, this.isUser, this.timestamp);
}

class SupportTicket {
  final String id;
  final String subject;
  final String description;
  final SupportTicketStatus status;
  final SupportPriority priority;
  final DateTime createdAt;

  SupportTicket(
    this.id,
    this.subject,
    this.description,
    this.status,
    this.priority,
    this.createdAt,
  );
}

enum SupportTicketStatus { open, inProgress, resolved, closed }

enum SupportPriority { low, medium, high, urgent }
