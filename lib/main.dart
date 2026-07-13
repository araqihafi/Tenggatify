import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart'; // Tambahkan ini
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/task_list_screen.dart';
import 'cubits/task_cubit.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint("--- Booting Aplikasi Tenggatify ---");
  
  // Jalankan inisialisasi
  await _initServices();
  
  runApp(const TenggatifyApp());
}

Future<void> _initServices() async {
  try {
    await NotificationService().init();
    debugPrint("Status: Notifikasi Siap");
  } catch (e) {
    debugPrint("Status: Gagal Notifikasi: $e");
  }

  // Inisialisasi database untuk Windows
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    debugPrint("Status: Database Desktop Siap");
  }
}

class TenggatifyApp extends StatelessWidget {
  const TenggatifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskCubit()..loadTasks(),
      child: MaterialApp(
        title: 'Tenggatify',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blueAccent,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const TaskListScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
