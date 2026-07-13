import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task.dart';
import '../database/task_database.dart';
import 'task_state.dart';
import '../services/notification_service.dart';

class TaskCubit extends Cubit<TaskState> {
  final NotificationService _notificationService = NotificationService();
  
  TaskCubit() : super(TaskInitial());

  String _currentSortBy = 'priority';
  String _currentFilterStatus = 'All';

  String get currentSortBy => _currentSortBy;
  String get currentFilterStatus => _currentFilterStatus;

  // Memuat tugas dari database Sqflite
  Future<void> loadTasks({String? sortBy, String? filterStatus}) async {
    try {
      final currentTasks = state.tasks;
      emit(TaskLoading(tasks: currentTasks));
      
      _currentSortBy = sortBy ?? _currentSortBy;
      _currentFilterStatus = filterStatus ?? _currentFilterStatus;
      
      final tasks = await TaskDatabase.instance.readAllTasks(
        sortBy: _currentSortBy,
        filterStatus: _currentFilterStatus,
      );
      
      emit(TaskLoaded(tasks));
    } catch (e) {
      final currentTasks = state.tasks;
      emit(TaskError("Gagal memuat tugas: ${e.toString()}", tasks: currentTasks));
    }
  }

  // Menambah tugas ke database
  Future<void> addTask(Task task) async {
    final currentTasks = state.tasks;
    try {
      await TaskDatabase.instance.insertTask(task);
      try {
        if (task.reminderDate != null) {
          await _notificationService.scheduleTaskNotification(task);
        }
      } catch (e) {
        // Abaikan error notifikasi agar tidak menggagalkan penyimpanan tugas (terutama di Desktop)
        print("Notification Error: $e");
      }
      await loadTasks(); 
    } catch (e) {
      emit(TaskError("Gagal menyimpan tugas: ${e.toString()}", tasks: currentTasks));
    }
  }

  // Memperbarui tugas di database
  Future<void> updateTask(Task updatedTask) async {
    final currentTasks = state.tasks;
    try {
      await TaskDatabase.instance.updateTask(updatedTask);
      try {
        if (updatedTask.reminderDate != null) {
          await _notificationService.scheduleTaskNotification(updatedTask);
        } else {
          await _notificationService.cancelNotification(updatedTask.id);
        }
      } catch (e) {
        print("Notification Error: $e");
      }
      await loadTasks();
    } catch (e) {
      emit(TaskError("Gagal memperbarui tugas: ${e.toString()}", tasks: currentTasks));
    }
  }

  // Menghapus tugas dari database
  Future<void> deleteTask(String id) async {
    final currentTasks = state.tasks;
    try {
      // Optimistic update: hapus dari UI dulu agar responsif
      if (currentTasks != null) {
        emit(TaskLoaded(currentTasks.where((t) => t.id != id).toList()));
      }
      
      await TaskDatabase.instance.deleteTask(id);
      try {
        await _notificationService.cancelNotification(id);
      } catch (e) {
        print("Notification Cancel Error: $e");
      }
      await loadTasks();
    } catch (e) {
      emit(TaskError("Gagal menghapus tugas: ${e.toString()}", tasks: currentTasks));
    }
  }

  // Mengubah status selesai tugas di database
  Future<void> toggleTaskCompletion(String id) async {
    if (state is TaskLoaded) {
      final tasks = (state as TaskLoaded).tasks;
      final index = tasks.indexWhere((t) => t.id == id);
      
      if (index != -1) {
        final task = tasks[index];
        final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
        await updateTask(updatedTask);
      }
    }
  }

  // Quick Action: Hapus semua tugas yang selesai
  Future<void> clearCompletedTasks() async {
    final currentTasks = state.tasks;
    try {
      // Ambil tugas yang selesai dulu untuk membatalkan notifikasinya
      final completedTasks = currentTasks?.where((t) => t.isCompleted).toList() ?? [];
      await TaskDatabase.instance.deleteCompletedTasks();
      for (var task in completedTasks) {
        try {
          await _notificationService.cancelNotification(task.id);
        } catch (e) {
          print("Notification Cancel Error: $e");
        }
      }
      await loadTasks();
    } catch (e) {
      emit(TaskError("Gagal menghapus tugas selesai: ${e.toString()}", tasks: currentTasks));
    }
  }

  // Quick Action: Tandai semua sebagai selesai
  Future<void> markAllCompleted() async {
    final currentTasks = state.tasks;
    try {
      final tasksToUpdate = currentTasks?.where((t) => !t.isCompleted).toList() ?? [];
      for (var task in tasksToUpdate) {
        final updatedTask = task.copyWith(isCompleted: true);
        await TaskDatabase.instance.updateTask(updatedTask);
        try {
          await _notificationService.cancelNotification(task.id);
        } catch (e) {
          print("Notification Cancel Error: $e");
        }
      }
      await loadTasks();
    } catch (e) {
      emit(TaskError("Gagal memperbarui semua tugas: ${e.toString()}", tasks: currentTasks));
    }
  }
}
