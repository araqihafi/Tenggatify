class Task {
  final String id;
  final String judul;
  final String deskripsi;
  final bool isCompleted;
  final int priority; // 1: Low, 2: Medium, 3: High
  final DateTime? dueDate;
  final DateTime? reminderDate;
  final bool isRecurring;
  final String? alarmSound;

  Task({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.isCompleted = false,
    this.priority = 1,
    this.dueDate,
    this.reminderDate,
    this.isRecurring = false,
    this.alarmSound,
  });

  Task copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    bool? isCompleted,
    int? priority,
    DateTime? dueDate,
    DateTime? reminderDate,
    bool? isRecurring,
    String? alarmSound,
  }) {
    return Task(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      reminderDate: reminderDate ?? this.reminderDate,
      isRecurring: isRecurring ?? this.isRecurring,
      alarmSound: alarmSound ?? this.alarmSound,
    );
  }

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'isRecurring': isRecurring ? 1 : 0,
      'alarmSound': alarmSound,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      isCompleted: map['isCompleted'] == 1,
      priority: map['priority'] ?? 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      reminderDate: map['reminderDate'] != null ? DateTime.parse(map['reminderDate']) : null,
      isRecurring: map['isRecurring'] == 1,
      alarmSound: map['alarmSound'],
    );
  }
}
