// lib/services/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p; // Use prefix 'p' to avoid name conflicts
import 'package:path_provider/path_provider.dart';
import '../models/chat_message.dart'; // Ensure this path is correct
import 'dart:async'; // For Future

class DatabaseService {
  // Singleton pattern to ensure only one instance of the database is open
  static Database? _database;
  static final DatabaseService instance =
      DatabaseService._init(); // Singleton instance

  // Database and table names
  static const String _dbName =
      'chat_app_history.db'; // Changed name slightly for clarity
  static const String _tableName =
      'chat_messages'; // Changed name slightly for clarity
  static const int _dbVersion = 1; // Database version for migrations

  // Private constructor for singleton
  DatabaseService._init();

  // Getter for the database instance
  Future<Database> get database async {
    // Return the existing database instance if it's already initialized
    if (_database != null) return _database!;

    // Otherwise, initialize the database
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    try {
      // Get the directory path for storing the database specific to the platform
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = p.join(documentsDirectory.path, _dbName); // Use p.join

      print("Database path: $path"); // Log the database path for debugging

      // Open the database. onCreate is called only the first time the DB is created.
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _onCreate,
        // onUpgrade: _onUpgrade, // Add this if you need to handle schema changes later
      );
    } catch (e) {
      print("Error initializing database: $e");
      // Rethrow the error so the calling code knows initialization failed
      rethrow;
    }
  }

  // Create the database table(s)
  Future<void> _onCreate(Database db, int version) async {
    try {
      // SQL command to create the chat messages table
      // Ensure column types match ChatMessage.toMap() output and fromMap() expectations
      await db.execute('''
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT, -- Auto-incrementing primary key
          text TEXT NOT NULL,                   -- The message content
          isUser INTEGER NOT NULL,              -- 1 for true (user), 0 for false (AI)
          timestamp TEXT NOT NULL,              -- Store as ISO8601 String for sorting
          modelUsed TEXT NOT NULL               -- 'user', 'gemini', 'groq', 'error', 'system' etc.
        )
      ''');
      print("Database table '$_tableName' created successfully.");
    } catch (e) {
      print("Error creating database table: $e");
      // Handle or rethrow as appropriate
    }
  }

  /*
  // Example for handling database upgrades (schema changes) in the future
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion");
    if (oldVersion < 2) {
      // Example: Add a new column in version 2
      // await db.execute("ALTER TABLE $_tableName ADD COLUMN new_column TEXT;");
    }
    // Add more upgrade steps as needed for subsequent versions
  }
  */

  // --- CRUD Operations ---

  /// Saves a chat message to the database.
  /// Returns the ID of the newly inserted row.
  Future<int> saveMessage(ChatMessage message) async {
    try {
      final db = await database; // Get database instance
      // The 'id' is handled by auto-increment, so we don't include it in the map for insertion.
      // The `toMap()` method in ChatMessage should handle this correctly if id is nullable.
      Map<String, dynamic> messageMap = message.toMap();
      messageMap.remove('id'); // Ensure ID is not in the map for insertion

      print("Saving message: ${messageMap['text']}");

      // Insert the message map into the table.
      // conflictAlgorithm.replace means if a message with the same PRIMARY KEY (id) somehow exists,
      // it will be replaced. This shouldn't happen with AUTOINCREMENT unless manually setting IDs.
      final id = await db.insert(
        _tableName,
        messageMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Message saved with ID: $id");
      return id;
    } catch (e) {
      print("Error saving message: $e");
      // Return -1 or throw an exception to indicate failure
      return -1;
    }
  }

  /// Loads all chat messages from the database, ordered by timestamp.
  /// Returns a list of ChatMessage objects.
  Future<List<ChatMessage>> loadChatHistory() async {
    try {
      final db = await database; // Get database instance

      // Query the table to get all messages, ordering them by timestamp ascending.
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'timestamp ASC', // Ensure chronological order
      );

      print("Loaded ${maps.length} messages from database.");

      // If no messages are found, return an empty list.
      if (maps.isEmpty) {
        return [];
      }

      // Convert the list of maps into a list of ChatMessage objects.
      // Use List.generate for conciseness.
      return List.generate(maps.length, (i) {
        return ChatMessage.fromMap(maps[i]);
      });
    } catch (e) {
      print("Error loading chat history: $e");
      // Return an empty list or throw an exception on error
      return [];
    }
  }

  /// Deletes all messages from the chat history table.
  Future<void> clearChatHistory() async {
    try {
      final db = await database; // Get database instance
      final count = await db.delete(_tableName); // Delete all rows
      print("Cleared $count messages from chat history.");
    } catch (e) {
      print("Error clearing chat history: $e");
      // Handle or rethrow as needed
    }
  }

  // Optional: Close the database when the app is terminated (though often not strictly necessary)
  // Future<void> close() async {
  //   final db = await database;
  //   await db.close();
  //   _database = null; // Reset the instance
  //   print("Database closed.");
  // }
}
