import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/task_cubit.dart';
import '../cubits/task_state.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  void _showDeleteConfirmDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('Apakah Anda yakin ingin menghapus "${task.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskCubit>().deleteTask(task.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tenggatify',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            tooltip: 'Tes Notifikasi',
            onPressed: () async {
              await NotificationService().showInstantTestNotification();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: 'Urutkan',
            onSelected: (value) {
              context.read<TaskCubit>().loadTasks(sortBy: value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'priority', child: Text('Urgensi (Default)')),
              const PopupMenuItem(value: 'deadline', child: Text('Tenggat Waktu')),
              const PopupMenuItem(value: 'newest', child: Text('Terbaru')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            tooltip: 'Opsi Lainnya',
            onSelected: (value) {
              if (value == 'clear_completed') {
                context.read<TaskCubit>().clearCompletedTasks();
              } else if (value == 'mark_all_done') {
                context.read<TaskCubit>().markAllCompleted();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_done',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Colors.blueAccent),
                    SizedBox(width: 10),
                    Text('Tandai Semua Selesai'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_completed',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.redAccent),
                    SizedBox(width: 10),
                    Text('Hapus Yang Selesai'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueAccent,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  final currentFilter = context.read<TaskCubit>().currentFilterStatus;
                  return Row(
                    children: ['All', 'Pending', 'Completed'].map((filter) {
                      final isSelected = currentFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter == 'All' ? 'Semua' : (filter == 'Pending' ? 'Belum Selesai' : 'Selesai')),
                          selected: isSelected,
                          onSelected: (_) {
                            context.read<TaskCubit>().loadTasks(filterStatus: filter);
                          },
                          selectedColor: Colors.white,
                          checkmarkColor: Colors.blueAccent,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blueAccent : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white.withAlpha(51),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<TaskCubit, TaskState>(
              listener: (context, state) {
                if (state is TaskError && state.tasks != null && state.tasks!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final tasks = state.tasks;

                if (tasks != null && tasks.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TaskCubit>().loadTasks();
                    },
                    child: Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 80),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final bool isOverdue = task.isOverdue;
                            Color priorityColor;
                            switch (task.priority) {
                              case 3: priorityColor = Colors.red; break;
                              case 2: priorityColor = Colors.orange; break;
                              default: priorityColor = Colors.green;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Dismissible(
                                key: Key(task.id),
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: task.isCompleted ? Colors.orange : Colors.green,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(task.isCompleted ? Icons.undo : Icons.check, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  if (direction == DismissDirection.endToStart) {
                                    context.read<TaskCubit>().deleteTask(task.id);
                                  } else {
                                    context.read<TaskCubit>().toggleTaskCompletion(task.id);
                                  }
                                },
                                child: Card(
                                  elevation: 2,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: isOverdue ? const BorderSide(color: Colors.redAccent, width: 1) : BorderSide.none,
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: IconButton(
                                      icon: Icon(
                                        task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: task.isCompleted ? Colors.green : (isOverdue ? Colors.redAccent : Colors.blueAccent),
                                        size: 30,
                                      ),
                                      onPressed: () => context.read<TaskCubit>().toggleTaskCompletion(task.id),
                                    ),
                                    title: Text(
                                      task.judul,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                        color: task.isCompleted ? Colors.grey : Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(task.deskripsi, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskScreen(taskToEdit: task)));
                                        } else {
                                          _showDeleteConfirmDialog(context, task);
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                        const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task))),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (state is TaskLoading)
                          const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
                      ],
                    ),
                  );
                }

                if (state is TaskLoading) return const Center(child: CircularProgressIndicator());
                
                if (state is TaskError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        ElevatedButton(onPressed: () => context.read<TaskCubit>().loadTasks(), child: const Text('Coba Lagi')),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('Belum ada tugas. Klik + untuk menambah.'));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
