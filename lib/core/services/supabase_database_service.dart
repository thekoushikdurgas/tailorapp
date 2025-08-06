import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorapp/core/services/debug_logger.dart';

/// Supabase Database Service for TailorApp
///
/// Provides comprehensive database functionality including:
/// - CRUD operations for all tables
/// - Real-time subscriptions
/// - File storage operations
/// - Database utilities and helpers
class SupabaseDatabaseService {
  final SupabaseClient _client;

  SupabaseDatabaseService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  /// Get the Supabase client instance
  SupabaseClient get client => _client;

  // ==========================================================================
  // CRUD OPERATIONS
  // ==========================================================================

  /// Generic select operation
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      var query = _client.from(table).select(columns);

      // Apply filters
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      DebugLogger.service('Select from $table successful: ${response.length} records');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      DebugLogger.error('Error selecting from $table: $e');
      rethrow;
    }
  }

  /// Generic insert operation
  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _client.from(table).insert(data).select().single();

      DebugLogger.service('Insert into $table successful');
      return response;
    } catch (e) {
      DebugLogger.error('Error inserting into $table: $e');
      rethrow;
    }
  }

  /// Generic update operation
  Future<Map<String, dynamic>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
  }) async {
    try {
      var query = _client.from(table).update(data);

      // Apply filters
      filters.forEach((key, value) {
        if (value != null) {
          query = query.eq(key, value);
        }
      });

      final response = await query.select().single();
      DebugLogger.service('Update in $table successful');
      return response;
    } catch (e) {
      DebugLogger.error('Error updating $table: $e');
      rethrow;
    }
  }

  /// Generic delete operation
  Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  }) async {
    try {
      var query = _client.from(table).delete();

      // Apply filters
      filters.forEach((key, value) {
        if (value != null) {
          query = query.eq(key, value);
        }
      });

      await query;
      DebugLogger.service('Delete from $table successful');
    } catch (e) {
      DebugLogger.error('Error deleting from $table: $e');
      rethrow;
    }
  }

  /// Upsert operation (insert or update)
  Future<Map<String, dynamic>> upsert({
    required String table,
    required Map<String, dynamic> data,
    String? onConflict,
  }) async {
    try {
      final response = await _client.from(table).upsert(data, onConflict: onConflict).select().single();

      DebugLogger.service('Upsert into $table successful');
      return response;
    } catch (e) {
      DebugLogger.error('Error upserting into $table: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // REAL-TIME SUBSCRIPTIONS
  // ==========================================================================

  /// Subscribe to table changes
  Stream<List<Map<String, dynamic>>> subscribeToTable({
    required String table,
    String primaryKey = 'id',
    Map<String, dynamic>? filters,
  }) {
    try {
      var stream = _client.from(table).stream(primaryKey: [primaryKey]);

      // Apply filters if provided
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            stream = stream.eq(key, value);
          }
        });
      }

      DebugLogger.service('Subscribed to real-time updates for $table');
      return stream;
    } catch (e) {
      DebugLogger.error('Error subscribing to $table: $e');
      rethrow;
    }
  }

  /// Subscribe to specific changes (INSERT, UPDATE, DELETE)
  RealtimeChannel subscribeToChanges({
    required String table,
    required Function(PostgresChangePayload) onEvent,
    PostgresChangeEvent event = PostgresChangeEvent.all,
  }) {
    try {
      final channel = _client.channel('changes_$table');

      channel
          .onPostgresChanges(
            event: event,
            schema: 'public',
            table: table,
            callback: onEvent,
          )
          .subscribe();

      DebugLogger.service('Subscribed to $event events for $table');
      return channel;
    } catch (e) {
      DebugLogger.error('Error subscribing to changes for $table: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // STORAGE OPERATIONS
  // ==========================================================================

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            fileBytes,
            fileOptions: FileOptions(
              contentType: contentType,
            ),
          );

      final publicUrl = _client.storage.from(bucket).getPublicUrl(path);

      DebugLogger.service('File uploaded to $bucket/$path');
      return publicUrl;
    } catch (e) {
      DebugLogger.error('Error uploading file to $bucket/$path: $e');
      rethrow;
    }
  }

  /// Download file from storage
  Future<List<int>> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final response = await _client.storage.from(bucket).download(path);

      DebugLogger.service('File downloaded from $bucket/$path');
      return response;
    } catch (e) {
      DebugLogger.error('Error downloading file from $bucket/$path: $e');
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);

      DebugLogger.service('File deleted from $bucket/$path');
    } catch (e) {
      DebugLogger.error('Error deleting file from $bucket/$path: $e');
      rethrow;
    }
  }

  /// Get public URL for file
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Create signed URL for file
  Future<String> createSignedUrl({
    required String bucket,
    required String path,
    int expiresIn = 3600, // 1 hour default
  }) async {
    try {
      final signedUrl = await _client.storage.from(bucket).createSignedUrl(path, expiresIn);

      DebugLogger.service('Signed URL created for $bucket/$path');
      return signedUrl;
    } catch (e) {
      DebugLogger.error('Error creating signed URL for $bucket/$path: $e');
      rethrow;
    }
  }

  // ==========================================================================
  // UTILITY METHODS
  // ==========================================================================

  /// Execute custom SQL query
  Future<List<Map<String, dynamic>>> executeQuery(String query) async {
    try {
      final response = await _client.rpc('execute_sql', params: {'query': query});
      DebugLogger.service('Custom query executed successfully');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      DebugLogger.error('Error executing custom query: $e');
      rethrow;
    }
  }

  /// Check database connection
  Future<bool> isConnected() async {
    try {
      await _client.from('pg_stat_activity').select('*').limit(1);
      DebugLogger.service('Database connection verified');
      return true;
    } catch (e) {
      DebugLogger.error('Database connection failed: $e');
      return false;
    }
  }

  /// Get table information
  Future<List<Map<String, dynamic>>> getTableInfo(String tableName) async {
    try {
      final response = await _client.rpc(
        'get_table_info',
        params: {'table_name': tableName},
      );
      DebugLogger.service('Table info retrieved for $tableName');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      DebugLogger.error('Error getting table info for $tableName: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    DebugLogger.service('SupabaseDatabaseService disposed');
  }
}
