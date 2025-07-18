import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tailorapp/core/init/navigation/navigation_route.dart';
import 'package:tailorapp/core/models/customer_model.dart';
import 'package:tailorapp/core/cubit/auth_cubit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  CustomerModel? _customer;
  bool _isLoading = true;
  bool _isEditing = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerProfile() async {
    setState(() => _isLoading = true);

    // Store scaffold messenger before async call
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Simulate loading customer profile
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock customer data - in real app, this would come from auth service
      _customer = CustomerModel(
        id: 'CUST001',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1 (555) 123-4567',
        profileImageUrl: null,
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Male',
        address: const CustomerAddress(
          street: '123 Main Street',
          apartment: 'Apt 4B',
          city: 'New York',
          state: 'NY',
          postalCode: '10001',
          country: 'USA',
          isDefault: true,
        ),
        measurements: BodyMeasurements(
          height: 175.0,
          weight: 70.0,
          chest: 42.0,
          waist: 34.0,
          hips: 40.0,
          shoulders: 18.0,
          armLength: 24.0,
          neck: 16.0,
          unit: 'cm',
          lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
        ),
        stylePreferences: const StylePreferences(
          preferredStyles: ['Modern', 'Classic', 'Casual'],
          preferredColors: ['Navy', 'White', 'Light Blue', 'Gray'],
          preferredFabrics: ['Cotton', 'Linen', 'Wool'],
          dislikedColors: ['Orange', 'Pink'],
          dislikedFabrics: ['Polyester'],
          fitPreference: 'slim',
          budgetRange: '\$50-\$150',
          occasions: ['Business', 'Casual', 'Formal'],
        ),
        orderHistory: ['ORD001', 'ORD002', 'ORD003'],
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
      );

      _nameController.text = _customer!.name;
      _emailController.text = _customer!.email;
      _phoneController.text = _customer!.phone ?? '';
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    // Store scaffold messenger before async call
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImage = File(image.path);
        });

        // In a real app, upload to cloud storage here
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_customer == null) return;

    // Store scaffold messenger before async call
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final updatedCustomer = _customer!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        updatedAt: DateTime.now(),
      );

      // In a real app, save to backend here
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _customer = updatedCustomer;
          _isEditing = false;
        });

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _nameController.text = _customer?.name ?? '';
                  _emailController.text = _customer?.email ?? '';
                  _phoneController.text = _customer?.phone ?? '';
                });
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
          ] else ...[
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                NavigationRoute.openSettings(context);
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCustomerProfile,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(),
                    const SizedBox(height: 24),

                    // Personal Information
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),

                    // Body Measurements
                    _buildMeasurementsSection(),
                    const SizedBox(height: 24),

                    // Style Preferences
                    _buildStylePreferencesSection(),
                    const SizedBox(height: 24),

                    // Profile Options
                    _buildProfileOptionsSection(),
                    const SizedBox(height: 24),

                    // Support & Settings
                    _buildSupportSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Profile Image
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!) as ImageProvider
                    : _customer?.profileImageUrl != null
                        ? NetworkImage(_customer!.profileImageUrl!)
                            as ImageProvider
                        : null,
                child:
                    _selectedImage == null && _customer?.profileImageUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.blue[600],
                          )
                        : null,
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Name and Email
          if (_isEditing) ...[
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Full Name',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              decoration: const InputDecoration(
                hintText: 'Email Address',
                border: UnderlineInputBorder(),
              ),
            ),
          ] else ...[
            Text(
              _customer?.name ?? 'No Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _customer?.email ?? 'No Email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                  'Orders', _customer?.orderHistory.length.toString() ?? '0'),
              _buildStatCard('Designs', '8'),
              _buildStatCard(
                  'Member Since',
                  _customer != null
                      ? '${DateTime.now().difference(_customer!.createdAt).inDays} days'
                      : 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            _buildInfoRow('Phone', _customer?.phone ?? 'Not provided'),
            _buildInfoRow(
                'Date of Birth',
                _customer?.dateOfBirth != null
                    ? '${_customer!.dateOfBirth!.day}/${_customer!.dateOfBirth!.month}/${_customer!.dateOfBirth!.year}'
                    : 'Not provided'),
            _buildInfoRow('Gender', _customer?.gender ?? 'Not specified'),
            _buildInfoRow(
                'Member Since',
                _customer?.createdAt != null
                    ? '${_customer!.createdAt.day}/${_customer!.createdAt.month}/${_customer!.createdAt.year}'
                    : 'Unknown'),
          ],
        ],
      ),
    );
  }

  Widget _buildMeasurementsSection() {
    final measurements = _customer?.measurements;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Body Measurements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (measurements != null)
                  Text(
                    'Last updated: ${measurements.lastUpdated.day}/${measurements.lastUpdated.month}/${measurements.lastUpdated.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (measurements == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No measurements recorded',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      NavigationRoute.openVirtualFitting(context);
                    },
                    child: const Text('Take Measurements'),
                  ),
                ],
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildMeasurementItem(
                            'Chest', measurements.chest, measurements.unit),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMeasurementItem(
                            'Waist', measurements.waist, measurements.unit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMeasurementItem(
                            'Hips', measurements.hips, measurements.unit),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMeasurementItem('Shoulders',
                            measurements.shoulders, measurements.unit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMeasurementItem(
                            'Height', measurements.height, measurements.unit),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMeasurementItem('Arm Length',
                            measurements.armLength, measurements.unit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        NavigationRoute.openVirtualFitting(context);
                      },
                      icon: const Icon(Icons.straighten),
                      label: const Text('Update Measurements'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStylePreferencesSection() {
    final preferences = _customer?.stylePreferences;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Style Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          if (preferences == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No style preferences set'),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPreferenceChips(
                      'Preferred Colors', preferences.preferredColors),
                  const SizedBox(height: 12),
                  _buildPreferenceChips(
                      'Preferred Fabrics', preferences.preferredFabrics),
                  const SizedBox(height: 12),
                  _buildPreferenceChips('Occasions', preferences.occasions),
                  if (preferences.fitPreference != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow('Fit Preference', preferences.fitPreference!),
                  ],
                  if (preferences.budgetRange != null) ...[
                    _buildInfoRow('Budget Range', preferences.budgetRange!),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildProfileOption(
            icon: Icons.location_on_outlined,
            title: 'Addresses',
            subtitle: 'Shipping and billing addresses',
            onTap: () => _showAddressDialog(),
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.payment_outlined,
            title: 'Payment Methods',
            subtitle: 'Manage payment options',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment methods coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notification settings coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildProfileOption(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with your orders',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support page coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn about our privacy practices',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon!')),
              );
            },
          ),
          _buildDivider(),
          _buildProfileOption(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => _showSignOutDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementItem(String label, double? value, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value != null ? '${value.toStringAsFixed(1)} $unit' : 'N/A',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceChips(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red[600] : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red[600] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 72,
    );
  }

  void _showAddressDialog() {
    final address = _customer?.address;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Shipping Address'),
        content: address != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${address.street}${address.apartment != null ? ', ${address.apartment}' : ''}'),
                  Text(
                      '${address.city}, ${address.state} ${address.postalCode}'),
                  Text(address.country),
                ],
              )
            : const Text('No address on file'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address editing coming soon!')),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[600],
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
