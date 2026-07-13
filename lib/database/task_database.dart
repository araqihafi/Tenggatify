import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE tasks ( 
  id $idType, 
  judul $textType,
  deskripsi $textType,
  isCompleted $boolType,
  priority $intType,
  dueDate TEXT,
  reminderDate TEXT,
  isRecurring $boolType,
  alarmSound TEXT
  )
''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    var tableInfo = await db.rawQuery('PRAGMA table_info(tasks)');
    
    if (oldVersion < 2) {
      bool hasPriority = tableInfo.any((column) => column['name'] == 'priority');
      bool hasDueDate = tableInfo.any((column) => column['name'] == 'dueDate');

      if (!hasPriority) {
        await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 1');
      }
      if (!hasDueDate) {
        await db.execute('ALTER TABLE tasks ADD COLUMN dueDate TEXT');
      }
    }

    if (oldVersion < 4) {
      bool hasAlarmSound = tableInfo.any((column) => column['name'] == 'alarmSound');
      if (!hasAlarmSound) {
        await db.execute('ALTER TABLE tasks ADD COLUMN alarmSound TEXT');
      }
    }
  }

  Future<void> insertTask(Task task) async {
    final db = await instance.database;
    await db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> readAllTasks({String? sortBy, String? filterStatus}) async {
    final db = await instance.database;
    
    String? whereClause;
    if (filterStatus == 'Completed') {
      whereClause = 'isCompleted = 1';
    } else if (filterStatus == 'Pending') {
      whereClause = 'isCompleted = 0';
    }

    String orderBy;
    switch (sortBy) {
      case 'deadline':
        orderBy = 'dueDate ASC, priority DESC, id DESC';
        break;
      case 'newest':
        orderBy = 'id DESC';
        break;
      case 'priority':
      default:
        // Default: Urgency (Level paling tinggi ke rendah)
        orderBy = 'priority DESC, dueDate ASC, id DESC';
    }

    final result = await db.query('tasks', where: whereClause, orderBy: orderBy);
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await instance.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(String id) async {
    final db = await instance.database;
    await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Quick Action: Hapus semua tugas yang selesai
  Future<void> deleteCompletedTasks() async {
    final db = await instance.database;
    await db.delete(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [1],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
