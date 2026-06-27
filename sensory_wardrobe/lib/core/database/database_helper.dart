import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Manages the local SQLite database.
/// Corresponds to DS1–DS5 from the Level 0 DFD.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sensory_wardrobe.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // DS1: User Profiles
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        display_name TEXT NOT NULL,
        email TEXT,
        is_dependent INTEGER NOT NULL DEFAULT 0,
        caregiver_id TEXT,
        accessibility_settings TEXT,
        sensory_preferences TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // DS2: Wardrobe Catalog
    await db.execute('''
      CREATE TABLE wardrobe_items (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        color TEXT,
        fabric TEXT,
        sensory_tags TEXT,
        warmth_level INTEGER,
        photo_path TEXT,
        notes TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles(id)
      )
    ''');

    // DS3: Outfit Logs
    await db.execute('''
      CREATE TABLE outfit_logs (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        logged_date TEXT NOT NULL,
        item_ids TEXT NOT NULL,
        weather_snapshot_id TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profiles(id),
        FOREIGN KEY (weather_snapshot_id) REFERENCES weather_snapshots(id)
      )
    ''');

    // DS4: Comfort Ratings
    await db.execute('''
      CREATE TABLE comfort_ratings (
        id TEXT PRIMARY KEY,
        outfit_log_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        overall_score INTEGER NOT NULL,
        texture_score INTEGER,
        pressure_score INTEGER,
        temperature_score INTEGER,
        notes TEXT,
        rated_at TEXT NOT NULL,
        FOREIGN KEY (outfit_log_id) REFERENCES outfit_logs(id),
        FOREIGN KEY (user_id) REFERENCES user_profiles(id)
      )
    ''');

    // DS5: Weather Snapshots
    await db.execute('''
      CREATE TABLE weather_snapshots (
        id TEXT PRIMARY KEY,
        location_lat REAL,
        location_lon REAL,
        location_name TEXT,
        temperature_c REAL,
        feels_like_c REAL,
        humidity INTEGER,
        condition TEXT,
        condition_icon TEXT,
        wind_speed_kph REAL,
        fetched_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle schema migrations here as the app evolves
  }
}
