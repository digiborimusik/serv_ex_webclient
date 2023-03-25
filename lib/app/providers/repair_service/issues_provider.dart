import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serv_expert_webclient/data/models/repair_service/issue.dart';
import 'package:serv_expert_webclient/data/reposiotories/repair_service/issues_repository.dart';
import 'package:serv_expert_webclient/global_providers.dart';

final rsIssuesProvider = FutureProvider.autoDispose.family<List<RSIssue>, String>((ref, categoryId) async {
  RSIssuesRepository repository = ref.read(rsIssuesRepositoryProvider);
  return repository.issues(categoryId: categoryId);
});