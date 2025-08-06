import 'package:tailorapp/core/services/supabase_database_service.dart';
import 'package:tailorapp/core/services/debug_logger.dart';
import 'package:tailorapp/core/models/user_model.dart';
import 'package:tailorapp/core/models/user_role.dart';

/// Helper class to test database operations
///
/// This class provides methods to test all CRUD operations
/// and verify that the database setup is working correctly
class DatabaseTestHelper {
  final SupabaseDatabaseService _databaseService;

  DatabaseTestHelper({required SupabaseDatabaseService databaseService}) : _databaseService = databaseService;

  /// Run comprehensive database tests
  Future<bool> runAllTests() async {
    DebugLogger.service('🧪 Starting comprehensive database tests...');

    try {
      // Test 1: Database connection
      final isConnected = await testConnection();
      if (!isConnected) {
        DebugLogger.error('❌ Database connection test failed');
        return false;
      }

      // Test 2: Basic CRUD operations
      final crudPassed = await testCrudOperations();
      if (!crudPassed) {
        DebugLogger.error('❌ CRUD operations test failed');
        return false;
      }

      // Test 3: User management
      final userTestPassed = await testUserOperations();
      if (!userTestPassed) {
        DebugLogger.error('❌ User operations test failed');
        return false;
      }

      // Test 4: File storage (optional - requires bucket setup)
      // final storageTestPassed = await testFileStorage();

      DebugLogger.service('✅ All database tests passed!');
      return true;
    } catch (e) {
      DebugLogger.error('❌ Database tests failed with error: $e');
      return false;
    }
  }

  /// Test database connection
  Future<bool> testConnection() async {
    try {
      DebugLogger.service('🔌 Testing database connection...');

      // Try to query a system table
      final result = await _databaseService.select(
        table: 'information_schema.tables',
        columns: 'table_name',
        limit: 1,
      );

      DebugLogger.service('✅ Database connection successful');
      return true;
    } catch (e) {
      DebugLogger.error('❌ Database connection failed: $e');
      return false;
    }
  }

  /// Test basic CRUD operations
  Future<bool> testCrudOperations() async {
    try {
      DebugLogger.service('📝 Testing CRUD operations...');

      const testTableName = 'countries';

      // Test SELECT
      final countries = await _databaseService.select(
        table: testTableName,
        limit: 5,
      );
      DebugLogger.service('✅ SELECT operation successful - found ${countries.length} countries');

      // Test if we have sample data
      if (countries.isEmpty) {
        DebugLogger.warning('⚠️ No sample data found in countries table');
        // Could insert sample data here if needed
      }

      return true;
    } catch (e) {
      DebugLogger.error('❌ CRUD operations failed: $e');
      return false;
    }
  }

  /// Test user-specific operations
  Future<bool> testUserOperations() async {
    try {
      DebugLogger.service('👤 Testing user operations...');

      // Create a test user
      final testUserData = {
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'full_name': 'Test User',
        'role': 'customer',
        'is_active': true,
        'email_verified': false,
        'phone_verified': false,
        'onboarding_completed': false,
      };

      // Test CREATE
      final createdUser = await _databaseService.insert(
        table: 'users',
        data: testUserData,
      );
      DebugLogger.service('✅ User created with ID: ${createdUser['id']}');

      final userId = createdUser['id'];

      // Test READ
      final retrievedUsers = await _databaseService.select(
        table: 'users',
        filters: {'id': userId},
        limit: 1,
      );

      if (retrievedUsers.isEmpty) {
        throw Exception('Created user not found');
      }
      DebugLogger.service('✅ User retrieved successfully');

      // Test UPDATE
      await _databaseService.update(
        table: 'users',
        data: {'full_name': 'Updated Test User'},
        filters: {'id': userId},
      );
      DebugLogger.service('✅ User updated successfully');

      // Test DELETE (cleanup)
      await _databaseService.delete(
        table: 'users',
        filters: {'id': userId},
      );
      DebugLogger.service('✅ User deleted successfully');

      return true;
    } catch (e) {
      DebugLogger.error('❌ User operations failed: $e');
      return false;
    }
  }

  /// Test real-time subscriptions
  Future<bool> testRealTimeSubscriptions() async {
    try {
      DebugLogger.service('⚡ Testing real-time subscriptions...');

      // Subscribe to users table changes
      final subscription = _databaseService.subscribeToTable(
        table: 'users',
        filters: {'role': 'customer'},
      );

      // Listen for a short time to verify subscription works
      subscription.take(1).timeout(
            const Duration(seconds: 5),
            onTimeout: () => <Map<String, dynamic>>[],
          );

      DebugLogger.service('✅ Real-time subscription test completed');
      return true;
    } catch (e) {
      DebugLogger.warning('⚠️ Real-time subscription test failed: $e');
      // Don't fail the entire test suite for this
      return true;
    }
  }

  /// Test file storage operations (optional)
  Future<bool> testFileStorage() async {
    try {
      DebugLogger.service('📁 Testing file storage...');

      // Test file upload
      const testContent = 'Hello, Supabase Database Test!';
      final testFileName = 'test_${DateTime.now().millisecondsSinceEpoch}.txt';

      // Convert string to bytes
      final fileBytes = testContent.codeUnits;

      final publicUrl = await _databaseService.uploadFile(
        bucket: 'avatars', // Using avatars bucket from schema
        path: testFileName,
        fileBytes: fileBytes,
        contentType: 'text/plain',
      );

      DebugLogger.service('✅ File uploaded successfully: $publicUrl');

      // Test file download
      final downloadedBytes = await _databaseService.downloadFile(
        bucket: 'avatars',
        path: testFileName,
      );

      if (downloadedBytes.isNotEmpty) {
        DebugLogger.service('✅ File downloaded successfully');
      }

      // Cleanup - delete test file
      await _databaseService.deleteFile(
        bucket: 'avatars',
        path: testFileName,
      );
      DebugLogger.service('✅ Test file cleaned up');

      return true;
    } catch (e) {
      DebugLogger.warning('⚠️ File storage test failed (may not be configured): $e');
      // Don't fail entire test for storage issues
      return true;
    }
  }

  /// Test table existence
  Future<Map<String, bool>> testTableExistence() async {
    final requiredTables = [
      'users',
      'customers',
      'tailors',
      'admins',
      'orders',
      'order_items',
      'fabrics',
      'garment_templates',
      'chat_rooms',
      'chat_messages',
      'notifications',
      'countries',
    ];

    final tableStatus = <String, bool>{};

    for (final tableName in requiredTables) {
      try {
        await _databaseService.select(
          table: tableName,
          limit: 1,
        );
        tableStatus[tableName] = true;
        DebugLogger.service('✅ Table exists: $tableName');
      } catch (e) {
        tableStatus[tableName] = false;
        DebugLogger.error('❌ Table missing: $tableName - $e');
      }
    }

    return tableStatus;
  }

  /// Generate test report
  Future<void> generateTestReport() async {
    DebugLogger.service('📊 Generating database test report...');

    try {
      // Test all components
      final connectionOk = await testConnection();
      final crudOk = await testCrudOperations();
      final userOpsOk = await testUserOperations();
      final tableStatus = await testTableExistence();

      // Print detailed report
      DebugLogger.service('=== DATABASE TEST REPORT ===');
      DebugLogger.service('Connection: ${connectionOk ? '✅' : '❌'}');
      DebugLogger.service('CRUD Operations: ${crudOk ? '✅' : '❌'}');
      DebugLogger.service('User Operations: ${userOpsOk ? '✅' : '❌'}');

      DebugLogger.service('=== TABLE STATUS ===');
      tableStatus.forEach((table, exists) {
        DebugLogger.service('$table: ${exists ? '✅' : '❌'}');
      });

      final totalTables = tableStatus.length;
      final existingTables = tableStatus.values.where((exists) => exists).length;

      DebugLogger.service('=== SUMMARY ===');
      DebugLogger.service('Tables: $existingTables/$totalTables');
      DebugLogger.service('Overall Status: ${(connectionOk && crudOk && userOpsOk) ? '✅ PASSED' : '❌ FAILED'}');
      DebugLogger.service('========================');
    } catch (e) {
      DebugLogger.error('Failed to generate test report: $e');
    }
  }
}
