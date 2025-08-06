# 🚀 Supabase Database Setup Guide for TailorApp

This guide provides a complete setup for TailorApp using Supabase as a **database-only** backend solution, with authentication removed as requested.

## 📋 Overview

This implementation focuses on:

- ✅ **Database operations** (CRUD)
- ✅ **Real-time data** subscriptions
- ✅ **File storage** management
- ✅ **Business logic** at application level
- ❌ **No authentication** service
- ❌ **No RLS policies** required

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── services/
│   │   ├── supabase_database_service.dart    # Main DB service
│   │   └── service_locator.dart               # DI container
│   ├── repositories/
│   │   ├── supabase_*_repository.dart         # Data access layer
│   └── models/
│       └── *.dart                             # Data models
├── supabase_options.dart                      # DB configuration
└── main.dart                                  # App initialization
```

## 🔧 Setup Steps

### 1. Supabase Project Setup

1. **Create Supabase Project**

   ```bash
   # Go to https://supabase.com
   # Click "New Project"
   # Choose organization and set project details
   ```

2. **Get Project Credentials**

   - Go to Project Settings → API
   - Copy Project URL
   - Copy anon/public key

3. **Update Configuration**
   ```dart
   // lib/supabase_options.dart
   class SupabaseConfig {
     static const String supabaseUrl = 'YOUR_PROJECT_URL';
     static const String supabaseAnonKey = 'YOUR_ANON_KEY';
   }
   ```

### 2. Database Schema Setup

1. **Run Database Schema**

   ```sql
   -- In Supabase SQL Editor, run:
   -- File: supabase_database_schema.sql
   ```

   This creates:

   - 📊 **15+ tables** for complete app functionality
   - 🗂️ **Storage buckets** for file management
   - 📈 **Indexes** for performance
   - 🔄 **Triggers** for auto-timestamps

2. **Key Tables Created:**
   ```
   users              # Base user data
   customers          # Customer profiles
   tailors            # Tailor profiles
   orders             # Order management
   order_items        # Individual garments
   fabrics            # Fabric catalog
   garment_templates  # Design templates
   chat_rooms         # Communications
   notifications      # User notifications
   ```

### 3. Flutter Dependencies

Current `pubspec.yaml` already includes:

```yaml
dependencies:
  supabase_flutter: ^2.9.1 # Database & storage
  get_it: ^8.0.3 # Dependency injection
  flutter_bloc: ^9.1.1 # State management
```

### 4. Service Architecture

#### Database Service

```dart
// lib/core/services/supabase_database_service.dart
class SupabaseDatabaseService {
  // CRUD operations
  Future<List<Map<String, dynamic>>> select({...});
  Future<Map<String, dynamic>> insert({...});
  Future<Map<String, dynamic>> update({...});
  Future<void> delete({...});

  // Real-time subscriptions
  Stream<List<Map<String, dynamic>>> subscribeToTable({...});

  // File storage
  Future<String> uploadFile({...});
  Future<List<int>> downloadFile({...});
}
```

#### Repository Pattern

```dart
// Example: lib/core/repositories/supabase_customer_repository.dart
class SupabaseCustomerRepository implements CustomerRepository {
  final SupabaseDatabaseService _databaseService;

  // Clean data access methods
  Future<CustomerModel?> getCustomer(String id);
  Future<CustomerModel> createCustomer(CustomerModel customer);
  Future<CustomerModel> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}
```

#### Dependency Injection

```dart
// lib/core/services/service_locator.dart
class ServiceLocator {
  static Future<void> setupServiceLocator() async {
    // Database services
    _setupDatabaseServices();
    // Repositories
    _setupRepositories();
    // AI services
    _setupAIServices();
  }
}
```

## 💻 Usage Examples

### Basic CRUD Operations

```dart
// Get database service
final dbService = serviceLocator<SupabaseDatabaseService>();

// Create customer
final customerData = {
  'user_id': 'uuid-here',
  'full_name': 'John Doe',
  'email': 'john@example.com',
  'style_preferences': {'casual': true, 'formal': false}
};

final customer = await dbService.insert(
  table: 'customers',
  data: customerData,
);

// Query customers
final customers = await dbService.select(
  table: 'customers',
  filters: {'is_active': true},
  orderBy: 'created_at',
  limit: 10,
);

// Update customer
await dbService.update(
  table: 'customers',
  data: {'style_preferences': {'casual': false, 'formal': true}},
  filters: {'id': customer['id']},
);
```

### Real-time Data

```dart
// Subscribe to order updates
final orderStream = dbService.subscribeToTable(
  table: 'orders',
  filters: {'customer_id': customerId},
);

// Use in widget
StreamBuilder<List<Map<String, dynamic>>>(
  stream: orderStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final order = snapshot.data![index];
          return OrderCard(order: OrderModel.fromJson(order));
        },
      );
    }
    return CircularProgressIndicator();
  },
);
```

### File Storage

```dart
// Upload garment image
final imageBytes = await imageFile.readAsBytes();
final imageUrl = await dbService.uploadFile(
  bucket: SupabaseConfig.garmentImagesBucket,
  path: 'designs/${DateTime.now().millisecondsSinceEpoch}.jpg',
  fileBytes: imageBytes,
  contentType: 'image/jpeg',
);

// Save image URL to database
await dbService.update(
  table: 'garment_templates',
  data: {'image_urls': [imageUrl]},
  filters: {'id': garmentId},
);
```

### Repository Usage

```dart
// Using repository pattern
final customerRepo = serviceLocator<CustomerRepository>();

// Get customer profile
final customer = await customerRepo.getCustomer(userId);

// Update preferences
final updatedCustomer = customer.copyWith(
  stylePreferences: {'modern': true, 'traditional': false}
);
await customerRepo.updateCustomer(updatedCustomer);

// Get customer orders
final orders = await customerRepo.getCustomerOrders(userId);
```

## 🗂️ Database Tables Overview

### Core Tables

| Table       | Purpose           | Key Features                  |
| ----------- | ----------------- | ----------------------------- |
| `users`     | Base user info    | Email, phone, role, profile   |
| `customers` | Customer profiles | Preferences, measurements     |
| `tailors`   | Tailor profiles   | Skills, ratings, availability |
| `orders`    | Order management  | Status, payment, delivery     |
| `fabrics`   | Fabric catalog    | Types, properties, pricing    |

### Business Tables

| Table               | Purpose             | Key Features                  |
| ------------------- | ------------------- | ----------------------------- |
| `garment_templates` | Design patterns     | Categories, features, pricing |
| `order_items`       | Individual garments | Specifications, measurements  |
| `chat_rooms`        | Communication       | Customer-tailor messaging     |
| `notifications`     | User alerts         | Order updates, reminders      |

### Analytics Tables

| Table                  | Purpose         | Key Features             |
| ---------------------- | --------------- | ------------------------ |
| `order_status_history` | Status tracking | Timeline, transitions    |
| `payment_transactions` | Payment logs    | Gateway, status, amounts |
| `admin_activity_logs`  | Audit trail     | Admin actions, changes   |

## 🔄 Real-time Features

### Order Status Updates

```dart
// Listen to order status changes
final channel = dbService.subscribeToChanges(
  table: 'orders',
  onEvent: (payload) {
    final orderId = payload.newRecord?['id'];
    final newStatus = payload.newRecord?['status'];

    // Update UI or send notifications
    _handleOrderStatusChange(orderId, newStatus);
  },
);
```

### Chat Messaging

```dart
// Real-time chat messages
final chatStream = dbService.subscribeToTable(
  table: 'chat_messages',
  filters: {'chat_room_id': roomId},
);
```

## 📦 Storage Buckets

Configured buckets for file management:

| Bucket             | Purpose             | Public |
| ------------------ | ------------------- | ------ |
| `avatars`          | User profile photos | Yes    |
| `garment-images`   | Design previews     | Yes    |
| `fabric-samples`   | Fabric photos       | Yes    |
| `pattern-files`    | Design patterns     | No     |
| `order-documents`  | Order PDFs          | No     |
| `chat-attachments` | Message files       | No     |

## 🧪 Testing Your Setup

### 1. Database Connection

```dart
final dbService = serviceLocator<SupabaseDatabaseService>();
final isConnected = await dbService.isConnected();
print('Database connected: $isConnected');
```

### 2. CRUD Operations

```dart
// Test create
final testUser = await dbService.insert(
  table: 'users',
  data: {
    'email': 'test@example.com',
    'full_name': 'Test User',
    'role': 'customer',
  },
);

// Test read
final users = await dbService.select(
  table: 'users',
  filters: {'email': 'test@example.com'},
);

// Test update
await dbService.update(
  table: 'users',
  data: {'full_name': 'Updated User'},
  filters: {'id': testUser['id']},
);

// Test delete
await dbService.delete(
  table: 'users',
  filters: {'id': testUser['id']},
);
```

### 3. File Upload

```dart
final testFile = utf8.encode('Hello, Supabase!');
final fileUrl = await dbService.uploadFile(
  bucket: 'avatars',
  path: 'test.txt',
  fileBytes: testFile,
);
print('File uploaded: $fileUrl');
```

## 🚀 Running the App

1. **Clean and get dependencies**

   ```bash
   flutter clean
   flutter pub get
   ```

2. **Run the app**

   ```bash
   flutter run
   ```

3. **Verify setup**
   - Check database connection
   - Test CRUD operations
   - Verify file upload
   - Test real-time features

## 🎯 Key Benefits

### ✅ **Simplified Architecture**

- No auth complexity
- Direct database access
- Clean separation of concerns

### ✅ **Performance**

- Optimized queries with indexes
- Real-time subscriptions
- Efficient file storage

### ✅ **Scalability**

- PostgreSQL reliability
- Horizontal scaling ready
- Modular repository pattern

### ✅ **Development Speed**

- Ready-to-use database schema
- Comprehensive service layer
- Type-safe models

## 🔍 Advanced Usage

### Custom Queries

```dart
// Execute complex SQL
final result = await dbService.executeQuery('''
  SELECT o.*, c.full_name as customer_name, t.business_name as tailor_name
  FROM orders o
  JOIN customers c ON o.customer_id = c.id
  JOIN tailors t ON o.tailor_id = t.id
  WHERE o.status = 'in_progress'
  ORDER BY o.created_at DESC
''');
```

### Batch Operations

```dart
// Multiple inserts
final orderItems = [
  {'order_id': orderId, 'garment_template_id': template1, 'quantity': 1},
  {'order_id': orderId, 'garment_template_id': template2, 'quantity': 2},
];

for (final item in orderItems) {
  await dbService.insert(table: 'order_items', data: item);
}
```

### Analytics Queries

```dart
// Get order statistics
final stats = await dbService.select(
  table: 'orders',
  columns: '''
    status,
    COUNT(*) as count,
    AVG(total_amount) as avg_amount,
    SUM(total_amount) as total_revenue
  ''',
  orderBy: 'status',
);
```

## 🆘 Troubleshooting

### Common Issues

1. **Connection Failed**

   ```
   Error: Failed to connect to Supabase
   Solution: Check URL and API key in supabase_options.dart
   ```

2. **Table Not Found**

   ```
   Error: relation "table_name" does not exist
   Solution: Run supabase_database_schema.sql in SQL Editor
   ```

3. **Permission Denied**

   ```
   Error: permission denied for table
   Solution: Verify anon key has proper permissions
   ```

4. **File Upload Failed**
   ```
   Error: bucket does not exist
   Solution: Check bucket names in schema match config
   ```

## 📚 Next Steps

1. **Customize Models** - Update data models for your specific needs
2. **Add Business Logic** - Implement custom validation and workflows
3. **Optimize Queries** - Add indexes for your most common queries
4. **Setup Backups** - Configure automated database backups
5. **Monitor Performance** - Use Supabase dashboard for analytics

---

## 🎉 You're Ready!

Your TailorApp now has a robust, scalable database backend with:

- ✅ Complete database schema
- ✅ Type-safe repository pattern
- ✅ Real-time subscriptions
- ✅ File storage management
- ✅ Performance optimizations

**Happy coding!** 🚀
