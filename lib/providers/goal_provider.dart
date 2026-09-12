import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../repositories/goal_repository.dart';
import 'transaction_provider.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return GoalRepository(database);
});

final goalsProvider = AsyncNotifierProvider<GoalController, List<SavingsGoal>>(
  GoalController.new,
);

class GoalController extends AsyncNotifier<List<SavingsGoal>> {
  GoalRepository get _repository => ref.read(goalRepositoryProvider);

  @override
  Future<List<SavingsGoal>> build() {
    final repository = ref.watch(goalRepositoryProvider);

    return repository.getGoals();
  }

  Future<void> addGoal(SavingsGoal goal) async {
    await _repository.addGoal(goal);

    await _reload();
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await _repository.updateGoal(goal);

    await _reload();
  }

  Future<void> removeGoal(String id) async {
    await _repository.deleteGoal(id);

    await _reload();
  }

  Future<void> _reload() async {
    state = AsyncData(await _repository.getGoals());
  }
}

final activeGoalsProvider = Provider<List<SavingsGoal>>((ref) {
  final goals = ref.watch(goalsProvider).value ?? const <SavingsGoal>[];

  return goals.where((goal) => !goal.isCompleted).toList();
});

final completedGoalsProvider = Provider<List<SavingsGoal>>((ref) {
  final goals = ref.watch(goalsProvider).value ?? const <SavingsGoal>[];

  return goals.where((goal) => goal.isCompleted).toList();
});
