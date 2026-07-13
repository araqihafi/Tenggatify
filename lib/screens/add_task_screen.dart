import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task.dart';
import '../cubits/task_cubit.dart';
import '../services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDueDate;
  int _selectedPriority = 1;
  DateTime? _selectedReminderDate;
  bool _isRecurring = false;
  String? _selectedAlarmSound;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _judulController.text = widget.taskToEdit!.judul;
      _deskripsiController.text = widget.taskToEdit!.deskripsi;
      _selectedDueDate = widget.taskToEdit!.dueDate;
      _selectedPriority = widget.taskToEdit!.priority;
      _selectedReminderDate = widget.taskToEdit!.reminderDate;
      _isRecurring = widget.taskToEdit!.isRecurring;
      _selectedAlarmSound = widget.taskToEdit!.alarmSound;
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? now),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // Default reminder: 1 hour before due date if not set
          if (_selectedReminderDate == null) {
            _selectedReminderDate = _selectedDueDate!.subtract(const Duration(hours: 1));
          }
        });
      }
    }
  }

  Future<void> _pickReminderDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminderDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedReminderDate ?? now),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedReminderDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickCustomSound() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedAlarmSound = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e')),
        );
      }
    }
  }

  Future<void> _togglePreview() async {
    if (_selectedAlarmSound == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
      } else {
        if (_selectedAlarmSound!.contains('/') || _selectedAlarmSound!.contains('\\')) {
          await _audioPlayer.play(DeviceFileSource(_selectedAlarmSound!));
        } else {
          NotificationService().showPreviewNotification(_selectedAlarmSound!);
          return;
        }
        setState(() => _isPlaying = true);
        
        _audioPlayer.onPlayerComplete.listen((event) {
          if (mounted) setState(() => _isPlaying = false);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memutar suara: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.taskToEdit != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Tugas' : 'Tugas Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _judulController,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    labelText: 'Judul Tugas',
                    hintText: 'Apa yang ingin dikerjakan?',
                    prefixIcon: const Icon(Icons.title),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Harap masukkan judul' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    prefixIcon: const Icon(Icons.description),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Prioritas', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('Rendah'), icon: Icon(Icons.low_priority)),
                    ButtonSegment(value: 2, label: Text('Sedang'), icon: Icon(Icons.priority_high)),
                    ButtonSegment(value: 3, label: Text('Tinggi'), icon: Icon(Icons.warning_amber_rounded)),
                  ],
                  selected: {_selectedPriority},
                  onSelectionChanged: (newSelection) => setState(() => _selectedPriority = newSelection.first),
                ),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Tenggat Waktu'),
                  subtitle: Text(_selectedDueDate == null 
                    ? 'Belum diatur' 
                    : '${_selectedDueDate!.day}/${_selectedDueDate!.month} ${_selectedDueDate!.hour.toString().padLeft(2, '0')}:${_selectedDueDate!.minute.toString().padLeft(2, '0')}'),
                  trailing: TextButton(onPressed: _pickDueDate, child: const Text('Ubah')),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.alarm, color: _selectedPriority == 3 ? Colors.red : null),
                  title: const Text('Alarm Pengingat'),
                  subtitle: Text(_selectedReminderDate == null 
                    ? 'Tidak ada alarm' 
                    : '${_selectedReminderDate!.day}/${_selectedReminderDate!.month} ${_selectedReminderDate!.hour.toString().padLeft(2, '0')}:${_selectedReminderDate!.minute.toString().padLeft(2, '0')}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedReminderDate != null)
                        IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _selectedReminderDate = null)),
                      TextButton(onPressed: _pickReminderDate, child: const Text('Atur')),
                    ],
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pengingat Berulang'),
                  subtitle: const Text('Bunyikan alarm setiap hari di waktu yang sama'),
                  value: _isRecurring,
                  onChanged: (val) => setState(() => _isRecurring = val),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.music_note),
                  title: const Text('Suara Alarm'),
                  subtitle: Text(_selectedAlarmSound == null 
                      ? 'Default (Alarm)' 
                      : (_selectedAlarmSound!.contains('/') || _selectedAlarmSound!.contains('\\') 
                          ? _selectedAlarmSound!.split('/').last.split('\\').last 
                          : _selectedAlarmSound!)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_selectedAlarmSound != null)
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                          tooltip: 'Pratinjau Suara',
                          onPressed: _togglePreview,
                        ),
                      IconButton(
                        onPressed: _pickCustomSound,
                        icon: const Icon(Icons.folder_open, color: Colors.blue),
                        tooltip: 'Pilih dari HP',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final task = Task(
                        id: isEdit ? widget.taskToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                        judul: _judulController.text,
                        deskripsi: _deskripsiController.text,
                        isCompleted: isEdit ? widget.taskToEdit!.isCompleted : false,
                        dueDate: _selectedDueDate,
                        priority: _selectedPriority,
                        reminderDate: _selectedReminderDate,
                        isRecurring: _isRecurring,
                        alarmSound: _selectedAlarmSound,
                      );
                      if (isEdit) {
                        context.read<TaskCubit>().updateTask(task);
                      } else {
                        context.read<TaskCubit>().addTask(task);
                      }
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isEdit ? 'PERBARUI' : 'SIMPAN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
