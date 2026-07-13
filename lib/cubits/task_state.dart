import 'package:equatable/equatable.dart';
import '../models/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  List<Task>? get tasks => null;

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {
  @override
  final List<Task>? tasks;
  const TaskLoading({this.tasks});

  @override
  List<Object?> get props => [tasks];
}

class TaskLoaded extends TaskState {
  @override
  final List<Task> tasks;
  const TaskLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  @override
  final List<Task>? tasks;
  const TaskError(this.message, {this.tasks});

  @override
  List<Object?> get props => [message, tasks];
}
